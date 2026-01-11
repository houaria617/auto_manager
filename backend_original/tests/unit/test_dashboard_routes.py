from unittest.mock import MagicMock, patch


# tests the dashboard stats endpoint with mocked firestore data
@patch('firebase_admin.firestore.client')
def test_get_dashboard_stats_logic(mock_firestore, client):
    # setup mock db
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db

    # create fake data snapshots
    mock_ongoing = [MagicMock()] * 5
    mock_available = [MagicMock()] * 10
    mock_due = [MagicMock()] * 2

    # mock activity document
    mock_activity = MagicMock()
    mock_activity.to_dict.return_value = {
        "description": "New car added",
        "activity_date": "2026-01-01"
    }
    mock_activity.id = "act_1"

    # chain the mocks for the specific call order in the route
    mock_db.collection().where().where().get.side_effect = [
        mock_ongoing,
        mock_available,
        mock_due
    ]
    mock_db.collection().where().order_by().limit().get.return_value = [mock_activity]

    # call the endpoint
    response = client.get('/dashboard/stats?agency_id=agency_001')

    # verify response
    assert response.status_code == 200
    data = response.json
    assert data['ongoing_rentals'] == 5
    assert data['available_cars'] == 10
    assert data['due_today'] == 2
    assert len(data['recent_activities']) == 1
    assert data['recent_activities'][0]['description'] == "New car added"