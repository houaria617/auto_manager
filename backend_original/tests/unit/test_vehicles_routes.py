from unittest.mock import patch


# checks that creating a vehicle without auth returns 401
@patch('firebase_admin.firestore.client')
def test_create_vehicle_requires_auth(mock_firestore, client):
    payload = {
        'name': 'Toyota Corolla',
        'plate': 'ABC-123',
        'rent_price': 50.0,
        'state': 'available',
    }

    response = client.post('/vehicles/', json=payload)

    assert response.status_code == 401
    assert 'error' in response.json


# checks that listing vehicles without auth returns 401
@patch('firebase_admin.firestore.client')
def test_get_all_vehicles_requires_auth(mock_firestore, client):
    response = client.get('/vehicles/')

    assert response.status_code == 401
    assert 'error' in response.json


# checks that fetching a single vehicle without auth returns 401
@patch('firebase_admin.firestore.client')
def test_get_vehicle_by_id_requires_auth(mock_firestore, client):
    response = client.get('/vehicles/vehicle_123')

    assert response.status_code == 401
    assert 'error' in response.json


# checks that updating a vehicle without auth returns 401
@patch('firebase_admin.firestore.client')
def test_update_vehicle_requires_auth(mock_firestore, client):
    payload = {
        'name': 'Updated Name',
        'state': 'rented',
    }

    response = client.put('/vehicles/vehicle_123', json=payload)

    assert response.status_code == 401
    assert 'error' in response.json


# checks that deleting a vehicle without auth returns 401
@patch('firebase_admin.firestore.client')
def test_delete_vehicle_requires_auth(mock_firestore, client):
    response = client.delete('/vehicles/vehicle_123')

    assert response.status_code == 401
    assert 'error' in response.json


# checks that an invalid jwt token gets rejected
@patch('firebase_admin.firestore.client')
def test_create_vehicle_invalid_token(mock_firestore, client):
    payload = {
        'name': 'Toyota Corolla',
        'plate': 'ABC-123',
        'rent_price': 50.0,
        'state': 'available',
    }

    headers = {'Authorization': 'Bearer invalid_token_here'}
    response = client.post('/vehicles/', json=payload, headers=headers)

    assert response.status_code == 401
    assert 'error' in response.json

