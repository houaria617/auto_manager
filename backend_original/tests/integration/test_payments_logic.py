import pytest
from unittest.mock import MagicMock, patch


@patch('firebase_admin.firestore.client')
def test_create_payment_success(mock_firestore, client):
    # Mock the Firestore document creation
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc_ref = MagicMock()
    mock_doc_ref.id = "payment_id_123"
    mock_db.collection().document.return_value = mock_doc_ref

    payload = {
        "rental_id": 1,
        "payment_date": "2023-01-01",
        "paid_amount": 50.0
    }

    response = client.post('/payments/', json=payload)

    assert response.status_code == 201
    assert response.json['id'] == "payment_id_123"


@patch('firebase_admin.firestore.client')
def test_get_payment_not_found(mock_firestore, client):
    # Mock a document that does not exist
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    response = client.get('/payments/nonexistent_id')

    assert response.status_code == 404
    assert "Payment not found" in response.json['error']


@patch('firebase_admin.firestore.client')
def test_get_all_payments(mock_firestore, client):
    # Mock Firestore stream
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.to_dict.return_value = {
        "rental_id": 1,
        "payment_date": "2023-01-01",
        "paid_amount": 50.0
    }
    mock_db.collection().stream.return_value = [mock_doc]

    response = client.get('/payments/')

    assert response.status_code == 200
    assert len(response.json) == 1
    assert response.json[0]['rental_id'] == 1


@patch('firebase_admin.firestore.client')
def test_update_payment_success(mock_firestore, client):
    # Mock existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = True
    mock_db.collection().document().get.return_value = mock_doc

    payload = {"paid_amount": 75.0}
    response = client.put('/payments/payment_id_123', json=payload)

    assert response.status_code == 200
    assert "Payment updated" in response.json['message']


@patch('firebase_admin.firestore.client')
def test_update_payment_not_found(mock_firestore, client):
    # Mock non-existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    payload = {"paid_amount": 75.0}
    response = client.put('/payments/nonexistent_id', json=payload)

    assert response.status_code == 404
    assert "Payment not found" in response.json['error']


@patch('firebase_admin.firestore.client')
def test_delete_payment_success(mock_firestore, client):
    # Mock existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = True
    mock_db.collection().document().get.return_value = mock_doc

    response = client.delete('/payments/payment_id_123')

    assert response.status_code == 200
    assert "Payment deleted" in response.json['message']


@patch('firebase_admin.firestore.client')
def test_delete_payment_not_found(mock_firestore, client):
    # Mock non-existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    response = client.delete('/payments/nonexistent_id')

    assert response.status_code == 404
    assert "Payment not found" in response.json['error']
