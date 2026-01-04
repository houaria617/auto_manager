from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast
from app.models.models import Payment

payment_bp = Blueprint('payment_bp', __name__)


@payment_bp.route('/', methods=['POST'])
def create_payment():
    try:
        data = request.json
    except Exception:
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    required = ["rental_id", "payment_date", "paid_amount"]
    for field in required:
        if field not in data:
            return jsonify({"error": f"{field} is required"}), 400

    # Create Payment instance and convert to dict
    payment = Payment(**data)
    db = firestore.client()
    doc_ref = db.collection('payment').document()
    doc_ref.set(payment.to_dict())

    return jsonify({"id": doc_ref.id}), 201


@payment_bp.route('/', methods=['GET'])
def get_all_payments():
    db = firestore.client()
    rental_id = request.args.get('rental_id')  # Optional filter
    query = db.collection('payment')
    if rental_id:
        query = query.where('rental_id', '==', rental_id)

    docs = query.stream()
    payments = []
    for doc in docs:
        payment_data = doc.to_dict() or {}
        payments.append(payment_data)

    return jsonify(payments), 200


@payment_bp.route('/<payment_id>', methods=['GET'])
def get_payment(payment_id):
    db = firestore.client()
    doc = cast(DocumentSnapshot, db.collection(
        'payment').document(payment_id).get())

    if not doc.exists:
        return jsonify({"error": "Payment not found"}), 404

    payment_data = doc.to_dict() or {}
    return jsonify(payment_data), 200


@payment_bp.route('/<payment_id>', methods=['PUT'])
def update_payment(payment_id):
    try:
        data = request.json
    except Exception:
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    db = firestore.client()
    doc_ref = db.collection('payment').document(payment_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Payment not found"}), 404

    # Update only provided fields
    update_data = {k: v for k, v in data.items(
    ) if k in Payment.__dataclass_fields__}
    doc_ref.update(update_data)

    return jsonify({"message": "Payment updated"}), 200


@payment_bp.route('/<payment_id>', methods=['DELETE'])
def delete_payment(payment_id):
    db = firestore.client()
    doc_ref = db.collection('payment').document(payment_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Payment not found"}), 404

    doc_ref.delete()
    return jsonify({"message": "Payment deleted"}), 200
