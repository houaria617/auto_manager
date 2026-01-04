from unittest.mock import patch, MagicMock


@patch('firebase_admin.firestore.client')
def test_get_analytics_missing_agency_id(mock_firestore, client):
    # Tests that agency_id is required
    response = client.get('/analytics/stats?timeframe=This Week')

    assert response.status_code == 400
    assert "agency_id is required" in response.json['error']


@patch('firebase_admin.firestore.client')
def test_get_analytics_success(mock_firestore, client):
    # Mock Firestore queries
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db

    # Simple mocks
    mock_rental_doc = MagicMock()
    mock_rental_doc.to_dict.return_value = {
        'agency_id': '1',
        'date_from': '2023-01-01T00:00:00',
        'date_to': '2023-01-05T00:00:00',
        'total_amount': 100.0,
        'client_id': 1,
        'car_id': 1
    }
    mock_car_doc = MagicMock()
    mock_car_doc.id = '1'
    mock_car_doc.to_dict.return_value = {'name': 'Car1', 'plate': 'ABC123'}
    mock_client_doc = MagicMock()
    mock_client_doc.to_dict.return_value = {'id': 1}

    # Mock the streams
    mock_db.collection.return_value.where.return_value.stream.return_value = [
        mock_rental_doc]
    mock_db.collection.return_value.stream.return_value = [mock_client_doc]

    response = client.get('/analytics/stats?agency_id=1&timeframe=All Time')

    assert response.status_code == 200
    assert 'totalRevenue' in response.json
    assert 'totalRentals' in response.json
