from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast
from app.models.models import Car

vehicles_bp = Blueprint('vehicles_bp', __name__)


@vehicles_bp.route('/', methods=['POST'])
def create_vehicle():
    try:
        data = request.json
        print(f"DEBUG: Received vehicle data: {data}")
    except Exception as e:
        print(f"DEBUG: JSON Parse Error: {str(e)}")
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    # Mapping frontend field names to backend model field names before validation
    if 'maintenance' in data and 'maintenance_date' not in data:
        data['maintenance_date'] = data.pop('maintenance')
    
    if 'price' in data and 'rent_price' not in data:
        data['rent_price'] = data.pop('price')

    required = ["agency_id", "name", "plate", "rent_price", "state"]
    for field in required:
        if field not in data:
            print(f"DEBUG: Missing required field: {field}")
            return jsonify({"error": f"{field} is required"}), 400
        
    valid_fields = {k: v for k, v in data.items() if k in Car.__dataclass_fields__}
    print(f"DEBUG: Valid fields for Car: {valid_fields}")
    
    try:
        car = Car(**valid_fields)
    except TypeError as e:
         print(f"DEBUG: Dataclass TypeError: {str(e)}")
         return jsonify({"error": f"Invalid arguments: {str(e)}"}), 400

    db = firestore.client()
    doc_ref = db.collection('cars').document()
    doc_ref.set(car.to_dict())

    return jsonify({"id": doc_ref.id}), 201


@vehicles_bp.route('/', methods=['GET'])
def get_all_vehicles():
    db = firestore.client()
    agency_id = request.args.get('agency_id')  # Optional filter
    query = db.collection('cars')
    if agency_id:
        query = query.where('agency_id', '==', int(agency_id) if agency_id.isdigit() else agency_id)

    docs = query.stream()
    vehicles = []
    for doc in docs:
        car_data = doc.to_dict() or {}
        # Explicitly adding ID to the response as it's often needed in frontend lists
        car_data['id'] = doc.id 
        vehicles.append(car_data)

    return jsonify(vehicles), 200


@vehicles_bp.route('/<vehicle_id>', methods=['GET'])
def get_vehicle(vehicle_id):
    db = firestore.client()
    doc = cast(DocumentSnapshot, db.collection(
        'cars').document(vehicle_id).get())

    if not doc.exists:
        return jsonify({"error": "Vehicle not found"}), 404

    car_data = doc.to_dict() or {}
    car_data['id'] = doc.id
    return jsonify(car_data), 200


@vehicles_bp.route('/<vehicle_id>', methods=['PUT'])
def update_vehicle(vehicle_id):
    db = firestore.client()
    data = request.json
    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    doc_ref = db.collection('cars').document(vehicle_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Vehicle not found"}), 404

    # Update only provided fields
    update_data = {k: v for k, v in data.items(
    ) if k in Car.__dataclass_fields__}
    doc_ref.update(update_data)

    return jsonify({"message": "Vehicle updated"}), 200


@vehicles_bp.route('/<vehicle_id>', methods=['DELETE'])
def delete_vehicle(vehicle_id):
    db = firestore.client()
    doc_ref = db.collection('cars').document(vehicle_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Vehicle not found"}), 404

    doc_ref.delete()
    return jsonify({"message": "Vehicle deleted"}), 200
