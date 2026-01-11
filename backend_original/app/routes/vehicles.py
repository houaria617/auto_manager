from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from datetime import date
from .auth import token_required

vehicle_bp = Blueprint('vehicle_bp', __name__)


# creates a new vehicle in firestore under the authenticated users agency
@vehicle_bp.route('/', methods=['POST'])
@token_required
def create_vehicle():
    data = request.json
    data['agency_id'] = request.current_user.get('user_id')

    db = firestore.client()
    _, doc_ref = db.collection('cars').add(data)

    # log this action to the activity feed
    try:
        agency_id = data.get('agency_id')
        today_str = date.today().isoformat()
        car_name = data.get('name', 'Unknown')
        
        db.collection('activity').add({
            'agency_id': agency_id,
            'description': f"New vehicle added: {car_name}",
            'activity_date': today_str,
            'type': 'vehicle_added',
            'car_id': doc_ref.id,
        })
    except Exception:
        pass

    return jsonify({"id": doc_ref.id}), 201


# returns all vehicles belonging to the authenticated user
@vehicle_bp.route('/', methods=['GET'])
@token_required
def get_all_vehicles():
    agency_id = request.current_user.get('user_id')
    
    db = firestore.client()

    docs = db.collection('cars').where('agency_id', '==', agency_id).stream()

    vehicles = []
    for doc in docs:
        item = doc.to_dict()
        item['id'] = doc.id
        vehicles.append(item)

    return jsonify(vehicles), 200


# fetches a single vehicle by id, checks ownership before returning
@vehicle_bp.route('/<vehicle_id>', methods=['GET'])
@token_required
def get_vehicle(vehicle_id):
    db = firestore.client()
    doc_ref = db.collection('cars').document(vehicle_id)
    doc = doc_ref.get()
    
    if not doc.exists:
        return jsonify({"error": "Vehicle not found"}), 404
    
    data = doc.to_dict()
    agency_id = request.current_user.get('user_id')
    if data.get('agency_id') != agency_id:
        return jsonify({"error": "Forbidden"}), 403
    data['id'] = doc.id
    return jsonify(data), 200


# handles updates and deletes for a vehicle, enforces ownership
@vehicle_bp.route('/<vehicle_id>', methods=['PUT', 'DELETE'])
@token_required
def handle_vehicle(vehicle_id):
    db = firestore.client()
    doc_ref = db.collection('cars').document(vehicle_id)
    doc = doc_ref.get()

    if not doc.exists:
        return jsonify({"error": "Vehicle not found"}), 404

    data = doc.to_dict()
    agency_id = request.current_user.get('user_id')
    if data.get('agency_id') != agency_id:
        return jsonify({"error": "Forbidden"}), 403

    if request.method == 'DELETE':
        doc_ref.delete()
        return jsonify({"message": "Deleted"}), 204

    # handle put requests for updating vehicle fields
    if request.method == 'PUT':
        payload = dict(request.json or {})
        # prevent tampering with ownership or id fields
        payload.pop('agency_id', None)
        payload.pop('id', None)
        if not payload:
            return jsonify({"message": "No changes"}), 200
        doc_ref.update(payload)
        return jsonify({"message": "Updated"}), 200
