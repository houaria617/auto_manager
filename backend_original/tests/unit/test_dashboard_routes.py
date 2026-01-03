from unittest.mock import MagicMock, patch

@patch('firebase_admin.firestore.client')
def test_get_dashboard_stats_logic(mock_firestore, client):
    # 1. Setup Mock DB
    mock_db = MagicMock()
    mock_firestore.return_value = mock_db

    # 2. Create "Fake" data snapshots
    mock_ongoing = [MagicMock()] * 5  # Simulates 5 ongoing rentals
    mock_available = [MagicMock()] * 10 # Simulates 10 available cars
    mock_due = [MagicMock()] * 2      # Simulates 2 due today
    
    # Mocking Activity documents
    mock_activity = MagicMock()
    mock_activity.to_dict.return_value = {
        "description": "New car added",
        "activity_date": "2026-01-01"
    }
    mock_activity.id = "act_1"

    # 3. Chain the mocks for the specific call order in your route
    # Note: .get() is called 4 times in the route. 
    # side_effect returns these in order.
    mock_db.collection().where().where().get.side_effect = [
        mock_ongoing, 
        mock_available, 
        mock_due
    ]
    mock_db.collection().where().order_by().limit().get.return_value = [mock_activity]

    # 4. Call the endpoint
    response = client.get('/dashboard/stats?agency_id=agency_001')

    # 5. Assertions
    assert response.status_code == 200
    data = response.json
    assert data['ongoing_rentals'] == 5
    assert data['available_cars'] == 10
    assert data['due_today'] == 2
    assert len(data['recent_activities']) == 1
    assert data['recent_activities'][0]['description'] == "New car added"