from unittest.mock import patch


@patch('firebase_admin.firestore.client')
def test_create_payment_missing_fields(mock_firestore, client):
    # Tests the validation logic for missing required fields
    payload = {"rental_id": 1}  # Missing payment_date and paid_amount
    response = client.post('/payments/', json=payload)

    assert response.status_code == 400
    assert "payment_date is required" in response.json['error']


@patch('firebase_admin.firestore.client')
def test_create_payment_invalid_json(mock_firestore, client):
    # Tests handling of invalid JSON
    response = client.post('/payments/', data="invalid json",
                           content_type='application/json')

    assert response.status_code == 400
    assert "Invalid or missing JSON data" in response.json['error']
