import pytest
from unittest.mock import MagicMock, patch


# tests analytics stats with mocked rental and car data
@patch('firebase_admin.firestore.client')
def test_get_analytics_stats_success(mock_firestore, client):
    # setup mock db
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db

    # create mock rental document
    mock_rental_doc = MagicMock()
    mock_rental_doc.to_dict.return_value = {
        'agency_id': '1',
        'date_from': '2023-01-01T00:00:00',
        'date_to': '2023-01-05T00:00:00',
        'total_amount': 100.0,
        'client_id': 1,
        'car_id': '1'
    }

    # setup mock streams
    mock_db.collection().where().stream.side_effect = [
        [mock_rental_doc],
        [MagicMock(id='1', to_dict=lambda: {'name': 'Car1', 'plate': 'ABC123'})],
        [MagicMock(to_dict=lambda: {'agency_id': 1, 'id': 1})]
    ]

    response = client.get('/analytics/stats?agency_id=1&timeframe=All Time')

    assert response.status_code == 200
    data = response.json
    assert data['totalRevenue'] == 100.0
    assert data['totalRentals'] == 1
    assert data['avgDurationDays'] == 4
    assert len(data['topCars']) == 1
    assert data['topCars'][0]['name'] == 'Car1 ABC123'
    assert data['totalClients'] == 1
    assert data['activeClients'] == 1
    assert len(data['revenueChartData']) == 7
