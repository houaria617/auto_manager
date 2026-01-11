from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from datetime import datetime, timedelta, date
from collections import defaultdict
from .auth import token_required
from google.cloud.firestore import Query

analytics_bp = Blueprint('analytics_bp', __name__)


# returns analytics stats based on timeframe filter
@analytics_bp.route('/stats', methods=['GET'])
def get_analytics_stats():
    db = firestore.client()
    timeframe = request.args.get('timeframe', 'All Time')
    agency_id = request.args.get('agency_id')

    if not agency_id:
        return jsonify({"error": "agency_id is required"}), 400

    # figure out the start date based on timeframe
    now = datetime.now()
    if timeframe == 'This Week':
        start_date = now - timedelta(days=now.weekday())
        start_date = start_date.replace(hour=0, minute=0, second=0, microsecond=0)
    elif timeframe == 'This Month':
        start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    else:
        start_date = datetime(2000, 1, 1)

    # fetch all the data we need from firestore
    rentals_query = db.collection('rental').where('agency_id', '==', agency_id)
    rentals_docs = rentals_query.stream()
    all_rentals = [doc.to_dict() for doc in rentals_docs]

    cars_query = db.collection('car').where('agency_id', '==', agency_id)
    cars_docs = cars_query.stream()
    all_cars = {doc.id: doc.to_dict() for doc in cars_docs}

    # clients are global for now
    clients_query = db.collection('client')
    clients_docs = clients_query.stream()
    all_clients = [doc.to_dict() for doc in clients_docs]

    # filter rentals by the selected timeframe
    filtered_rentals = []
    for rental in all_rentals:
        date_str = rental.get('date_from', '')
        try:
            rental_date = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            if rental_date >= start_date:
                filtered_rentals.append(rental)
        except ValueError:
            continue

    # initialize metrics we'll calculate
    total_revenue = 0.0
    total_duration = 0
    active_client_ids = set()
    car_popularity = defaultdict(int)
    revenue_chart_data = [0.0] * 7

    # loop through rentals and calculate all the metrics
    for rental in filtered_rentals:
        # add up the revenue
        amount = rental.get('total_amount', 0.0)
        if isinstance(amount, int):
            amount = float(amount)
        total_revenue += amount

        # calculate duration in days
        date_from_str = rental.get('date_from', '')
        date_to_str = rental.get('date_to', '')
        try:
            start = datetime.fromisoformat(date_from_str.replace('Z', '+00:00'))
            end = datetime.fromisoformat(date_to_str.replace('Z', '+00:00'))
            days = max(1, (end - start).days)
            total_duration += days
        except ValueError:
            days = 1
            total_duration += days

        # track which clients are active
        client_id = rental.get('client_id')
        if client_id:
            active_client_ids.add(client_id)

        # track car rental counts for popularity
        car_id = rental.get('car_id')
        if car_id:
            car_popularity[car_id] += 1

        # build chart data for weekly view
        if timeframe == 'This Week':
            try:
                rental_start = datetime.fromisoformat(date_from_str.replace('Z', '+00:00'))
                day_index = rental_start.weekday()
                if 0 <= day_index < 7:
                    revenue_chart_data[day_index] += amount
            except ValueError:
                pass

    # calculate average rental duration
    avg_duration_days = round(total_duration / len(filtered_rentals)) if filtered_rentals else 0

    # find the top 3 most rented cars
    top_cars = []
    sorted_cars = sorted(car_popularity.items(), key=lambda x: x[1], reverse=True)
    for rank, (car_id, rentals_count) in enumerate(sorted_cars[:3], start=1):
        car_data = all_cars.get(car_id, {})
        name = car_data.get('name', 'Unknown')
        plate = car_data.get('plate', '')
        top_cars.append({
            'name': f'{name} {plate}',
            'rentals': rentals_count,
            'rank': rank
        })

    # bundle everything into the response
    response = {
        'totalRevenue': total_revenue,
        'totalRentals': len(filtered_rentals),
        'avgDurationDays': avg_duration_days,
        'topCars': top_cars,
        'totalClients': len(all_clients),
        'activeClients': len(active_client_ids),
        'revenueChartData': revenue_chart_data
    }

    return jsonify(response), 200


# returns recent activities and creates due today entries if needed
@analytics_bp.route('/activities', methods=['GET'])
@token_required
def get_activities():
    db = firestore.client()

    # prefer user_id from token for security
    user_id = request.current_user.get('user_id')
    agency_id = user_id or request.args.get('agency_id')

    if not agency_id:
        return jsonify({"error": "agency_id is required"}), 400

    today_str = date.today().isoformat()

    # find rentals due today and create activities if they don't exist yet
    due_docs = db.collection('rental') \
        .where('agency_id', '==', agency_id) \
        .where('date_to', '==', today_str) \
        .stream()

    for rental_doc in due_docs:
        rental_id = rental_doc.id

        # check if we already have an activity for this rental today
        existing = db.collection('activity') \
            .where('agency_id', '==', agency_id) \
            .where('type', '==', 'due_today') \
            .where('rental_id', '==', rental_id) \
            .where('activity_date', '==', today_str) \
            .get()

        # create the activity if it doesn't exist
        if len(existing) == 0:
            description = f"Rental due today (ID: {rental_id})"
            db.collection('activity').add({
                'agency_id': agency_id,
                'description': description,
                'activity_date': today_str,
                'type': 'due_today',
                'rental_id': rental_id,
            })

    # fetch recent activities for the timeline
    activity_query = db.collection('activity') \
        .where('agency_id', '==', agency_id) \
        .order_by('activity_date', direction=Query.DESCENDING) \
        .limit(50)

    # transform docs into response format
    docs = activity_query.stream()
    items = []
    for doc in docs:
        data = doc.to_dict() or {}
        items.append({
            'description': data.get('description', ''),
            'date': data.get('activity_date'),
            'remote_id': doc.id,
        })

    return jsonify(items), 200


# inserts a new activity for the authenticated agency
@analytics_bp.route('/activities', methods=['POST'])
@token_required
def add_activity():
    try:
        payload = request.get_json(silent=True) or {}
        if not payload:
            return jsonify({"error": "Invalid or missing JSON data"}), 400

        agency_id = request.current_user.get('user_id')
        description = (payload.get('description') or '').strip()
        date_value = payload.get('date') or payload.get('activity_date')

        if not description:
            return jsonify({"error": "description is required"}), 400

        # normalize date to yyyy-mm-dd format
        activity_date = None
        if isinstance(date_value, str) and len(date_value) >= 10:
            activity_date = date_value[:10]
        else:
            activity_date = date.today().isoformat()

        # save the activity to firestore
        db = firestore.client()
        _, doc_ref = db.collection('activity').add({
            'agency_id': agency_id,
            'description': description,
            'activity_date': activity_date,
            'type': payload.get('type'),
            'rental_id': payload.get('rental_id'),
        })

        return jsonify({"id": doc_ref.id}), 201
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500
