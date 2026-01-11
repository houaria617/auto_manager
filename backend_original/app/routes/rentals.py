from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from datetime import date
from app.models.models import Rental
from .auth import token_required

rental_bp = Blueprint('rental_bp', __name__)


# creates a new rental and logs the activity
@rental_bp.route('/', methods=['POST'])
@token_required
def create_rental():
    data = request.json

    # set agency from the authenticated user's token
    data['agency_id'] = request.current_user.get('user_id')

    # save the rental to firestore
    db = firestore.client()
    _, doc_ref = db.collection('rental').add(data)

    # try to log this as an activity for the dashboard timeline
    try:
        agency_id = data.get('agency_id')
        today_str = date.today().isoformat()
        description = "New rental created"

        # add some context to the description if we have car or client info
        car_id = data.get('car_id')
        client_id = data.get('client_id')
        if car_id or client_id:
            extras = []
            if car_id:
                extras.append(f"car:{car_id}")
            if client_id:
                extras.append(f"client:{client_id}")
            description = f"New rental created ({', '.join(extras)})"

        # log the activity
        db.collection('activity').add({
            'agency_id': agency_id,
            'description': description,
            'activity_date': today_str,
            'type': 'rental_created',
            'rental_id': doc_ref.id,
        })
    except Exception:
        # don't fail the rental if activity logging breaks
        pass

    return jsonify({"id": doc_ref.id}), 201


# returns all rentals for the logged-in agency
@rental_bp.route('/', methods=['GET'])
@token_required
def get_all_rentals():
    agency_id = request.current_user.get('user_id')
    db = firestore.client()

    # fetch all rentals belonging to this agency
    docs = db.collection('rental').where('agency_id', '==', agency_id).stream()

    # transform docs and include remote_id for sync purposes
    rentals = []
    for doc in docs:
        item = doc.to_dict()
        item['remote_id'] = doc.id
        rentals.append(item)

    return jsonify(rentals), 200


# handles update or delete for a specific rental
@rental_bp.route('/<rental_id>', methods=['PUT', 'DELETE'])
@token_required
def handle_rental(rental_id):
    db = firestore.client()
    doc_ref = db.collection('rental').document(rental_id)

    # handle delete request
    if request.method == 'DELETE':
        doc_ref.delete()
        return jsonify({"message": "Deleted"}), 204

    # handle update request
    if request.method == 'PUT':
        # check that the rental actually exists first
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"error": "Rental not found"}), 404

        rental_data = doc.to_dict() or {}

        # make sure this rental belongs to the current user
        agency_id = request.current_user.get('user_id')
        if rental_data.get('agency_id') != agency_id:
            return jsonify({"error": "Forbidden"}), 403

        # apply the updates to the rental
        payload = dict(request.json or {})
        doc_ref.update(payload)

        # if marking as completed, set the car back to available
        try:
            new_state = payload.get('rental_state')
            if new_state == 'completed':
                car_id = rental_data.get('car_id')
                if car_id is not None:
                    # try both collection names since we have some inconsistency
                    try:
                        db.collection('cars').document(str(car_id)).update({'state': 'available'})
                    except Exception:
                        try:
                            db.collection('car').document(str(car_id)).update({'state': 'available'})
                        except Exception:
                            pass
        except Exception:
            # don't block the update if this fails
            pass

        return jsonify({"message": "Rental updated"}), 200
