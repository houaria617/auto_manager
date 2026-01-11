from flask import Blueprint, jsonify, request
from firebase_admin import firestore
from google.cloud.firestore import Query
from datetime import date
from typing import cast
from google.cloud.firestore_v1.base_document import DocumentSnapshot

dashboard_bp = Blueprint('dashboard', __name__)


# returns summary stats for the agency dashboard
@dashboard_bp.route('/stats', methods=['GET'])
def get_dashboard_stats():
    db = firestore.client()
    agency_id = request.args.get('agency_id')
    today = date.today().isoformat()

    # count rentals that are currently ongoing
    ongoing_count = len(db.collection('rental')
        .where('agency_id', '==', agency_id)
        .where('rental_state', '==', 'ongoing').get())

    # count cars marked as available in the fleet
    available_cars = len(db.collection('car')
        .where('agency_id', '==', agency_id)
        .where('state', '==', 'available').get())

    # count ongoing rentals that need to be returned today
    due_today = len(db.collection('rental')
        .where('agency_id', '==', agency_id)
        .where('date_to', '==', today)
        .where('rental_state', '==', 'ongoing').get())

    # grab the 3 most recent activities for the timeline
    activities_docs = db.collection('activity')\
        .where('agency_id', '==', agency_id)\
        .order_by('activity_date', direction=Query.DESCENDING)\
        .limit(3).get()

    # transform activity docs into clean response objects
    activities = []
    for doc in activities_docs:
        data = doc.to_dict() or {}
        activities.append({
            "description": data.get("description"),
            "activity_date": data.get("activity_date"),
            "id": doc.id
        })

    # bundle everything into the response
    return jsonify({
        "ongoing_rentals": ongoing_count,
        "available_cars": available_cars,
        "due_today": due_today,
        "recent_activities": activities
    }), 200