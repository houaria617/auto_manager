from flask import Blueprint, jsonify, request
from firebase_admin import firestore
from google.cloud.firestore import Query
from datetime import date
from typing import cast
from google.cloud.firestore_v1.base_document import DocumentSnapshot

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/stats', methods=['GET'])
def get_dashboard_stats():
    db = firestore.client()
    # In the future, agency_id will come from your Auth token
    agency_id = request.args.get('agency_id') 
    today = date.today().isoformat()

    # 1. Ongoing Rentals (rental_state is 'ongoing')
    ongoing_count = len(db.collection('rental')
        .where('agency_id', '==', agency_id)
        .where('rental_state', '==', 'ongoing').get())

    # 2. Available Cars (state is 'available')
    available_cars = len(db.collection('car')
        .where('agency_id', '==', agency_id)
        .where('state', '==', 'available').get())

    # 3. Due Today (date_to == today)
    due_today = len(db.collection('rental')
        .where('agency_id', '==', agency_id)
        .where('date_to', '==', today).get())

    # 4. Recent Activities (limit to 3, ordered by date)
    activities_docs = db.collection('activity')\
        .where('agency_id', '==', agency_id)\
        .order_by('activity_date', direction=Query.DESCENDING)\
        .limit(3).get()

    activities = []
    for doc in activities_docs:
        data = doc.to_dict() or {}
        activities.append({
            "description": data.get("description"),
            "activity_date": data.get("activity_date"),
            "id": doc.id
        })

    return jsonify({
        "ongoing_rentals": ongoing_count,
        "available_cars": available_cars,
        "due_today": due_today,
        "recent_activities": activities
    }), 200