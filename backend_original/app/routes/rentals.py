from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast
from app.models.models import Rental

rental_bp = Blueprint('rental_bp', __name__)


@rental_bp.route('/', methods=['POST'])
def create_rental():
    try:
        data = request.json
    except Exception:
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    required = ["client_id", "car_id", "agency_id", "date_from",
                "date_to", "total_amount", "payment_state", "rental_state"]
    for field in required:
        if field not in data:
            return jsonify({"error": f"{field} is required"}), 400

    # Create Rental instance and convert to dict
    rental = Rental(**data)
    db = firestore.client()
    doc_ref = db.collection('rental').document()
    doc_ref.set(rental.to_dict())

    return jsonify({"id": doc_ref.id}), 201


@rental_bp.route('/', methods=['GET'])
def get_all_rentals():
    db = firestore.client()
    agency_id = request.args.get('agency_id')  # Optional filter
    query = db.collection('rental')
    if agency_id:
        query = query.where('agency_id', '==', agency_id)

    docs = query.stream()
    rentals = []
    for doc in docs:
        rental_data = doc.to_dict() or {}
        rentals.append(rental_data)

    return jsonify(rentals), 200


@rental_bp.route('/<rental_id>', methods=['GET'])
def get_rental(rental_id):
    db = firestore.client()
    doc = cast(DocumentSnapshot, db.collection(
        'rental').document(rental_id).get())

    if not doc.exists:
        return jsonify({"error": "Rental not found"}), 404

    rental_data = doc.to_dict() or {}
    return jsonify(rental_data), 200


@rental_bp.route('/<rental_id>', methods=['PUT'])
def update_rental(rental_id):
    db = firestore.client()
    data = request.json
    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    doc_ref = db.collection('rental').document(rental_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Rental not found"}), 404

    # Update only provided fields
    update_data = {k: v for k, v in data.items(
    ) if k in Rental.__dataclass_fields__}
    doc_ref.update(update_data)

    return jsonify({"message": "Rental updated"}), 200


@rental_bp.route('/<rental_id>', methods=['DELETE'])
def delete_rental(rental_id):
    db = firestore.client()
    doc_ref = db.collection('rental').document(rental_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Rental not found"}), 404

    doc_ref.delete()
    return jsonify({"message": "Rental deleted"}), 200
