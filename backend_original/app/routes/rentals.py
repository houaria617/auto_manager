from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from datetime import date
from app.models.models import Rental
# Adjust this import based on where your decorator is
from .auth import token_required

rental_bp = Blueprint('rental_bp', __name__)


@rental_bp.route('/', methods=['POST'])
@token_required
def create_rental():
    data = request.json
    # Inject agency_id from the JWT token for security
    data['agency_id'] = request.current_user.get('user_id')

    db = firestore.client()
    # Add to firestore
    _, doc_ref = db.collection('rental').add(data)

    # Record an activity for the new rental
    try:
        agency_id = data.get('agency_id')
        today_str = date.today().isoformat()
        description = "New rental created"
        # Optionally include some context if available
        car_id = data.get('car_id')
        client_id = data.get('client_id')
        if car_id or client_id:
            extras = []
            if car_id:
                extras.append(f"car:{car_id}")
            if client_id:
                extras.append(f"client:{client_id}")
            description = f"New rental created ({', '.join(extras)})"

        db.collection('activity').add({
            'agency_id': agency_id,
            'description': description,
            'activity_date': today_str,
            'type': 'rental_created',
            'rental_id': doc_ref.id,
        })
    except Exception:
        # Do not fail the rental creation if activity logging fails
        pass

    return jsonify({"id": doc_ref.id}), 201


@rental_bp.route('/', methods=['GET'])
@token_required
def get_all_rentals():
    agency_id = request.current_user.get('user_id')
    db = firestore.client()

    # Filter rentals by the logged-in agency
    docs = db.collection('rental').where('agency_id', '==', agency_id).stream()

    rentals = []
    for doc in docs:
        item = doc.to_dict()
        # Include Firestore ID for future updates/deletes
        item['remote_id'] = doc.id
        rentals.append(item)

    return jsonify(rentals), 200


@rental_bp.route('/<rental_id>', methods=['PUT', 'DELETE'])
@token_required
def handle_rental(rental_id):
    db = firestore.client()
    doc_ref = db.collection('rental').document(rental_id)

    if request.method == 'DELETE':
        doc_ref.delete()
        return jsonify({"message": "Deleted"}), 204

    if request.method == 'PUT':
        # Load existing rental
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"error": "Rental not found"}), 404

        rental_data = doc.to_dict() or {}

        # Enforce ownership
        agency_id = request.current_user.get('user_id')
        if rental_data.get('agency_id') != agency_id:
            return jsonify({"error": "Forbidden"}), 403

        # Update Firestore with the new data
        payload = dict(request.json or {})
        doc_ref.update(payload)

        # If completed, set car to available
        try:
            new_state = payload.get('rental_state')
            if new_state == 'completed':
                car_id = rental_data.get('car_id')
                if car_id is not None:
                        try:
                            db.collection('cars').document(str(car_id)).update({'state': 'available'})
                        except Exception:
                            # Fallback to singular collection name if used elsewhere
                            try:
                                db.collection('car').document(str(car_id)).update({'state': 'available'})
                            except Exception:
                                pass
        except Exception:
            # Ignore errors to not block rental update
            pass

        return jsonify({"message": "Rental updated"}), 200
