from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from typing import cast
from werkzeug.security import generate_password_hash

client_bp = Blueprint('client_bp', __name__)

@client_bp.route('/', methods=['POST'])
def create_client():
    db = firestore.client() # This will point to Emulator during tests
    data = request.json
    if data is None or not isinstance(data, dict):
        return jsonify({"error": "Invalid or missing JSON data"}), 400

    required = ["full_name", "phone", "password"]
    for field in required:
        if field not in data:
            return jsonify({"error": f"{field} is required"}), 400

    # Hash the password before storing
    data["password"] = generate_password_hash(data["password"])
    # Logic to save to 'clients' collection
    doc_ref = db.collection('clients').document()
    doc_ref.set(data)

    return jsonify({"id": doc_ref.id}), 201

@client_bp.route('/', methods=['GET'])
def get_all_clients():
    db = firestore.client()
    # Fetch all documents in the 'clients' collection
    docs = db.collection('clients').stream()
    
    clients = []
    for doc in docs:
        client_data = doc.to_dict() or {}
        safe_client = {
            "full_name": client_data.get("full_name"),
            "phone": client_data.get("phone"),
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
        "full_name": client_data.get("full_name"),
        "phone": client_data.get("phone"),
    }
    return jsonify(safe_client), 200