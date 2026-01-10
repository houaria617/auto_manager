"""
Unit tests for vehicles routes.
Tests the validation logic and route handlers for the vehicles blueprint.
These tests focus on authentication and basic error handling.
"""
from unittest.mock import patch


@patch('firebase_admin.firestore.client')
def test_create_vehicle_requires_auth(mock_firestore, client):
    """Test that vehicle creation requires authentication"""
    payload = {
        'name': 'Toyota Corolla',
        'plate': 'ABC-123',
        'rent_price': 50.0,
        'state': 'available',
    }

    # Without authorization header, should get 401
    response = client.post('/vehicles/', json=payload)

    assert response.status_code == 401
    assert 'error' in response.json


@patch('firebase_admin.firestore.client')
def test_get_all_vehicles_requires_auth(mock_firestore, client):
    """Test that getting all vehicles requires authentication"""
    response = client.get('/vehicles/')

    assert response.status_code == 401
    assert 'error' in response.json


@patch('firebase_admin.firestore.client')
def test_get_vehicle_by_id_requires_auth(mock_firestore, client):
    """Test that getting a specific vehicle requires authentication"""
    response = client.get('/vehicles/vehicle_123')

    assert response.status_code == 401
    assert 'error' in response.json


@patch('firebase_admin.firestore.client')
def test_update_vehicle_requires_auth(mock_firestore, client):
    """Test that updating a vehicle requires authentication"""
    payload = {
        'name': 'Updated Name',
        'state': 'rented',
    }

    response = client.put('/vehicles/vehicle_123', json=payload)

    assert response.status_code == 401
    assert 'error' in response.json


@patch('firebase_admin.firestore.client')
def test_delete_vehicle_requires_auth(mock_firestore, client):
    """Test that deleting a vehicle requires authentication"""
    response = client.delete('/vehicles/vehicle_123')

    assert response.status_code == 401
    assert 'error' in response.json


@patch('firebase_admin.firestore.client')
def test_create_vehicle_invalid_token(mock_firestore, client):
    """Test that invalid token is rejected"""
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

