import pytest
from unittest.mock import MagicMock, patch


# tests successful client creation with mocked firestore
@patch('firebase_admin.firestore.client')
def test_create_client_success(mock_firestore, client):
    # setup mock db
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc_ref = MagicMock()
    mock_doc_ref.id = "test_id_123"
    mock_db.collection().document.return_value = mock_doc_ref

    payload = {
        "full_name": "John Doe",
        "phone": "123456789",
        "password": "securepassword"
    }

    response = client.post('/clients/', json=payload)

    assert response.status_code == 201
    assert response.json['id'] == "test_id_123"


# tests 404 response when client not found
@patch('firebase_admin.firestore.client')
def test_get_client_not_found(mock_firestore, client):
    # mock a non-existent document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    response = client.get('/clients/nonexistent_id')

    assert response.status_code == 404
    assert response.json['error'] == "Client not found"