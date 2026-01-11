from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast

from app import get_db

client_bp = Blueprint('client_bp', __name__)


# creates a new client record in firestore
@client_bp.route('/', methods=['POST'])
def create_client():
    data = request.json
    if not data:
        return jsonify({"error": "No data received"}), 400

    db = get_db()

    # accept either full_name from flutter or name from other sources
    client_name = data.get('full_name') or data.get('name')
    phone = data.get('phone')
    agency_id = data.get('agency_id')

    # basic validation for required fields
    if not phone:
        return jsonify({"error": "phone is required"}), 400
    if not client_name:
        return jsonify({"error": "full_name is required"}), 400

    # add to firestore, collection gets created automatically if it doesn't exist
    _, doc_ref = db.collection('clients').add({
        'full_name': client_name,
        'phone': phone,
        'agency_id': agency_id,
    })

    return jsonify({"id": doc_ref.id, "message": "Success"}), 201

# returns all clients, can filter by agency if needed
@client_bp.route('/', methods=['GET'])
def get_all_clients():
    db = firestore.client()
    agency_id = request.args.get('agency_id')

    # build query with optional agency filter
    query = db.collection('clients')
    if agency_id:
        query = query.where('agency_id', '==', agency_id)
    docs = query.stream()

    # transform firestore docs into clean response objects
    clients = []
    for doc in docs:
        client_data = doc.to_dict() or {}
        safe_client = {
            "id": doc.id,
            "full_name": client_data.get("full_name"),
            "phone": client_data.get("phone"),
            "agency_id": client_data.get("agency_id"),
        }
        clients.append(safe_client)

    return jsonify(clients), 200

# fetches a single client by their id
@client_bp.route('/<client_id>', methods=['GET'])
def get_client(client_id):
    db = firestore.client()

    # cast helps pylance understand the type here
    doc = cast(DocumentSnapshot, db.collection('clients').document(client_id).get())

    if not doc.exists:
        return jsonify({"error": "Client not found"}), 404

    # build a safe response object with only the fields we need
    client_data = doc.to_dict() or {}
    safe_client = {
        "id": doc.id,
        "full_name": client_data.get("full_name"),
        "phone": client_data.get("phone"),
        "agency_id": client_data.get("agency_id"),
    }
    return jsonify(safe_client), 200