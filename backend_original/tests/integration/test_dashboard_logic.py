from unittest.mock import MagicMock, patch


# tests dashboard stats with mocked firestore data
@patch('firebase_admin.firestore.client')
def test_get_dashboard_stats_success(mock_firestore, client):
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db

    # setup mock responses for each query
    mock_db.collection().where().where().get.side_effect = [
        [MagicMock()] * 5,
        [MagicMock()] * 10,
        [MagicMock()] * 2
    ]

    # mock the activity query
    mock_db.collection().where().order_by().limit().get.return_value = []

    response = client.get('/dashboard/stats?agency_id=123')

    assert response.status_code == 200
    assert response.json['ongoing_rentals'] == 5
    assert response.json['available_cars'] == 10
    assert response.json['due_today'] == 2