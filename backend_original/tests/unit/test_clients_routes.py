from werkzeug.security import check_password_hash
from unittest.mock import patch

def test_password_hashing_logic():
    # Simulate the logic inside your POST route
    from werkzeug.security import generate_password_hash
    password = "my_password"
    hashed = generate_password_hash(password)
    
    assert hashed != password
    assert check_password_hash(hashed, password) is True

@patch('firebase_admin.firestore.client')
def test_create_client_missing_fields(mock_firestore, client):
    # Tests the validation logic
    payload = {"full_name": "Missing Phone and Password"}
    response = client.post('/clients/', json=payload)
    
    assert response.status_code == 400
    assert "phone is required" in response.json['error']