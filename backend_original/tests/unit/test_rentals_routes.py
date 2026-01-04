from unittest.mock import patch


@patch('firebase_admin.firestore.client')
def test_create_rental_missing_fields(mock_firestore, client):
    # Tests the validation logic for missing required fields
    payload = {"client_id": 1, "car_id": 1}  # Missing several fields
    response = client.post('/rentals/', json=payload)

    assert response.status_code == 400
    assert "agency_id is required" in response.json['error']


@patch('firebase_admin.firestore.client')
def test_create_rental_invalid_json(mock_firestore, client):
    # Tests handling of invalid JSON
    response = client.post('/rentals/', data="invalid json",
                           content_type='application/json')

    assert response.status_code == 400
    assert "Invalid or missing JSON data" in response.json['error']
