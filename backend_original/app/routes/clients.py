from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast

from app import get_db

client_bp = Blueprint('client_bp', __name__)

@client_bp.route('/', methods=['POST'])
def create_client():
    data = request.json
    if not data:
        return jsonify({"error": "No data received"}), 400

    db = get_db()
    
    # Use .get() to accept both 'full_name' (Flutter) and 'name' (Firebase)
    client_name = data.get('full_name') or data.get('name')
    phone = data.get('phone')
    agency_id = data.get('agency_id')

    if not phone:
        return jsonify({"error": "phone is required"}), 400
    if not client_name:
        return jsonify({"error": "full_name is required"}), 400

    # Add to Firestore - this will create the 'clients' collection automatically
    _, doc_ref = db.collection('clients').add({
        'full_name': client_name,
        'phone': phone,
        'agency_id': agency_id,
    })

    return jsonify({"id": doc_ref.id, "message": "Success"}), 201

@client_bp.route('/', methods=['GET'])
def get_all_clients():
    db = firestore.client()
    agency_id = request.args.get('agency_id')
    query = db.collection('clients')
    if agency_id:
        query = query.where('agency_id', '==', agency_id)
    # Fetch all documents in the 'clients' collection (optionally filtered)
    docs = query.stream()
    
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

@client_bp.route('/<client_id>', methods=['GET'])
def get_client(client_id):
    db = firestore.client()
    
    # We "cast" the result to force Pylance to see it as sync
    doc = cast(DocumentSnapshot, db.collection('clients').document(client_id).get())
    
    if not doc.exists:
        return jsonify({"error": "Client not found"}), 404
        
    # Now Pylance knows .to_dict() and .id exist
    client_data = doc.to_dict() or {}
    safe_client = {
        "id": doc.id,
        "full_name": client_data.get("full_name"),
        "phone": client_data.get("phone"),
        "agency_id": client_data.get("agency_id"),
    }
    return jsonify(safe_client), 200