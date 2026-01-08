from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from .auth import token_required  # Ensure this import is correct

payment_bp = Blueprint('payment_bp', __name__)


@payment_bp.route('/', methods=['POST'])
@token_required
def create_payment():
    data = request.json
    # Use .get() to avoid KeyErrors
    new_payment = {
        "rental_id": data.get("rental_id"),
        "paid_amount": data.get("paid_amount"),
        "payment_date": data.get("payment_date"),  # Matches Flutter
        "agency_id": request.current_user.get('user_id')
    }
    db = firestore.client()
    _, doc_ref = db.collection('payment').add(new_payment)
    return jsonify({"id": doc_ref.id}), 201


@payment_bp.route('/', methods=['GET'])
@token_required
def get_all_payments():
    rental_id = request.args.get('rental_id')
    db = firestore.client()
    query = db.collection('payment')

    if rental_id:
        query = query.where('rental_id', '==', rental_id)

    docs = query.stream()
    payments = [{"remote_id": d.id, **d.to_dict()} for d in docs]
    return jsonify(payments), 200
