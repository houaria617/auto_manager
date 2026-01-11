from unittest.mock import patch


# tests validation when required fields are missing
@patch('firebase_admin.firestore.client')
def test_create_payment_missing_fields(mock_firestore, client):
    payload = {"rental_id": 1}
    response = client.post('/payments/', json=payload)

    assert response.status_code == 400
    assert "payment_date is required" in response.json['error']


# tests handling of invalid json data
@patch('firebase_admin.firestore.client')
def test_create_payment_invalid_json(mock_firestore, client):
    response = client.post('/payments/', data="invalid json",
                           content_type='application/json')

    assert response.status_code == 400
    assert "Invalid or missing JSON data" in response.json['error']
