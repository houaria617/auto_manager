import pytest
from unittest.mock import MagicMock, patch


# tests successful rental creation with mocked firestore
@patch('firebase_admin.firestore.client')
def test_create_rental_success(mock_firestore, client):
    # setup mock db
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc_ref = MagicMock()
    mock_doc_ref.id = "rental_id_123"
    mock_db.collection().document.return_value = mock_doc_ref

    payload = {
        "client_id": 1,
        "car_id": 1,
        "agency_id": 1,
        "date_from": "2023-01-01",
        "date_to": "2023-01-05",
        "total_amount": 100.0,
        "payment_state": "pending",
        "rental_state": "active"
    }

    response = client.post('/rentals/', json=payload)

    assert response.status_code == 201
    assert response.json['id'] == "rental_id_123"


# tests 404 response when rental not found
@patch('firebase_admin.firestore.client')
def test_get_rental_not_found(mock_firestore, client):
    # mock a non-existent document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    response = client.get('/rentals/nonexistent_id')

    assert response.status_code == 404
    assert "Rental not found" in response.json['error']


# tests fetching all rentals
@patch('firebase_admin.firestore.client')
def test_get_all_rentals(mock_firestore, client):
    # setup mock stream
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.to_dict.return_value = {
        "client_id": 1,
        "car_id": 1,
        "agency_id": 1,
        "date_from": "2023-01-01",
        "date_to": "2023-01-05",
        "total_amount": 100.0,
        "payment_state": "pending",
        "rental_state": "active"
    }
    mock_db.collection().stream.return_value = [mock_doc]

    response = client.get('/rentals/')

    assert response.status_code == 200
    assert len(response.json) == 1
    assert response.json[0]['client_id'] == 1


# tests successful rental update
@patch('firebase_admin.firestore.client')
def test_update_rental_success(mock_firestore, client):
    # mock existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = True
    mock_db.collection().document().get.return_value = mock_doc

    payload = {"rental_state": "completed"}
    response = client.put('/rentals/rental_id_123', json=payload)

    assert response.status_code == 200
    assert "Rental updated" in response.json['message']


# tests update failure when rental not found
@patch('firebase_admin.firestore.client')
def test_update_rental_not_found(mock_firestore, client):
    # mock non-existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    payload = {"rental_state": "completed"}
    response = client.put('/rentals/nonexistent_id', json=payload)

    assert response.status_code == 404
    assert "Rental not found" in response.json['error']


# tests successful rental deletion
@patch('firebase_admin.firestore.client')
def test_delete_rental_success(mock_firestore, client):
    # mock existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = True
    mock_db.collection().document().get.return_value = mock_doc

    response = client.delete('/rentals/rental_id_123')

    assert response.status_code == 200
    assert "Rental deleted" in response.json['message']


# tests delete failure when rental not found
@patch('firebase_admin.firestore.client')
def test_delete_rental_not_found(mock_firestore, client):
    # mock non-existing document
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db
    mock_doc = MagicMock()
    mock_doc.exists = False
    mock_db.collection().document().get.return_value = mock_doc

    response = client.delete('/rentals/nonexistent_id')

    assert response.status_code == 404
    assert "Rental not found" in response.json['error']
