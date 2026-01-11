from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from .auth import token_required

payment_bp = Blueprint('payment_bp', __name__)


# records a new payment against a rental
@payment_bp.route('/', methods=['POST'])
@token_required
def create_payment():
    data = request.json

    # build the payment object from the request data
    new_payment = {
        "rental_id": data.get("rental_id"),
        "paid_amount": data.get("paid_amount"),
        "payment_date": data.get("payment_date"),
        "agency_id": request.current_user.get('user_id')
    }

    # save to firestore and return the new id
    db = firestore.client()
    _, doc_ref = db.collection('payment').add(new_payment)
    return jsonify({"id": doc_ref.id}), 201


# returns payments, can filter by rental if needed
@payment_bp.route('/', methods=['GET'])
@token_required
def get_all_payments():
    rental_id = request.args.get('rental_id')
    db = firestore.client()

    # build query with optional rental filter
    query = db.collection('payment')
    if rental_id:
        query = query.where('rental_id', '==', rental_id)

    # transform docs and include remote_id for sync
    docs = query.stream()
    payments = [{"remote_id": d.id, **d.to_dict()} for d in docs]
    return jsonify(payments), 200
