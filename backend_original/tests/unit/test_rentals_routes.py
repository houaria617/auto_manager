from unittest.mock import patch


# tests validation when required fields are missing
@patch('firebase_admin.firestore.client')
def test_create_rental_missing_fields(mock_firestore, client):
    payload = {"client_id": 1, "car_id": 1}
    response = client.post('/rentals/', json=payload)

    assert response.status_code == 400
    assert "agency_id is required" in response.json['error']


# tests handling of invalid json data
@patch('firebase_admin.firestore.client')
def test_create_rental_invalid_json(mock_firestore, client):
    response = client.post('/rentals/', data="invalid json",
                           content_type='application/json')

    assert response.status_code == 400
    assert "Invalid or missing JSON data" in response.json['error']
