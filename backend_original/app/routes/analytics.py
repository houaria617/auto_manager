from flask import Blueprint, request, jsonify
from firebase_admin import firestore
from datetime import datetime, timedelta, date
from collections import defaultdict
from .auth import token_required
from google.cloud.firestore import Query

analytics_bp = Blueprint('analytics_bp', __name__)


@analytics_bp.route('/stats', methods=['GET'])
def get_analytics_stats():
    db = firestore.client()
    timeframe = request.args.get(
        'timeframe', 'All Time')  # Default to 'All Time'
    agency_id = request.args.get('agency_id')  # Required for filtering

    if not agency_id:
        return jsonify({"error": "agency_id is required"}), 400

    # Define date filters
    now = datetime.now()
    if timeframe == 'This Week':
        start_date = now - timedelta(days=now.weekday())
        start_date = start_date.replace(
            hour=0, minute=0, second=0, microsecond=0)
    elif timeframe == 'This Month':
        start_date = now.replace(
            day=1, hour=0, minute=0, second=0, microsecond=0)
    else:  # All Time
        start_date = datetime(2000, 1, 1)

    # Fetch data from Firestore
    rentals_query = db.collection('rental').where('agency_id', '==', agency_id)
    rentals_docs = rentals_query.stream()
    all_rentals = [doc.to_dict() for doc in rentals_docs]

    cars_query = db.collection('car').where('agency_id', '==', agency_id)
    cars_docs = cars_query.stream()
    all_cars = {doc.id: doc.to_dict() for doc in cars_docs}

    # Assuming clients are global or filtered elsewhere
    clients_query = db.collection('client')
    clients_docs = clients_query.stream()
    all_clients = [doc.to_dict() for doc in clients_docs]

    # Filter rentals by date
    filtered_rentals = []
    for rental in all_rentals:
        date_str = rental.get('date_from', '')
        try:
            rental_date = datetime.fromisoformat(
                date_str.replace('Z', '+00:00'))
            if rental_date >= start_date:
                filtered_rentals.append(rental)
        except ValueError:
            continue  # Skip invalid dates

    # Calculate metrics
    total_revenue = 0.0
    total_duration = 0
    active_client_ids = set()
    car_popularity = defaultdict(int)
    revenue_chart_data = [0.0] * 7  # For weekly chart

    for rental in filtered_rentals:
        # Revenue
        amount = rental.get('total_amount', 0.0)
        if isinstance(amount, int):
            amount = float(amount)
        total_revenue += amount

        # Duration
        date_from_str = rental.get('date_from', '')
        date_to_str = rental.get('date_to', '')
        try:
            start = datetime.fromisoformat(
                date_from_str.replace('Z', '+00:00'))
            end = datetime.fromisoformat(date_to_str.replace('Z', '+00:00'))
            days = max(1, (end - start).days)
            total_duration += days
        except ValueError:
            days = 1
            total_duration += days

        # Active Clients
        client_id = rental.get('client_id')
        if client_id:
            active_client_ids.add(client_id)

        # Car Popularity
        car_id = rental.get('car_id')
        if car_id:
            car_popularity[car_id] += 1

        # Chart Data (for This Week)
        if timeframe == 'This Week':
            try:
                rental_start = datetime.fromisoformat(
                    date_from_str.replace('Z', '+00:00'))
                day_index = rental_start.weekday()  # 0=Monday
                if 0 <= day_index < 7:
                    revenue_chart_data[day_index] += amount
            except ValueError:
                pass

    # Average Duration
    avg_duration_days = round(
        total_duration / len(filtered_rentals)) if filtered_rentals else 0

    # Top Cars
    top_cars = []
    sorted_cars = sorted(car_popularity.items(),
                         key=lambda x: x[1], reverse=True)
    for rank, (car_id, rentals_count) in enumerate(sorted_cars[:3], start=1):
        car_data = all_cars.get(car_id, {})
        name = car_data.get('name', 'Unknown')
        plate = car_data.get('plate', '')
        top_cars.append({
            'name': f'{name} {plate}',
            'rentals': rentals_count,
            'rank': rank
        })

    # Response
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


@analytics_bp.route('/activities', methods=['GET'])
@token_required
def get_activities():
    """Return recent activities for the authenticated agency.

    Also ensures that "due today" rental activities are recorded exactly once per day.
    """
    db = firestore.client()

    # Prefer user_id from token for security
    user_id = request.current_user.get('user_id')
    # Fallback to query param only if token does not include user_id (shouldn't happen)
    agency_id = user_id or request.args.get('agency_id')

    if not agency_id:
        return jsonify({"error": "agency_id is required"}), 400

    today_str = date.today().isoformat()

    # 1) Find rentals due today and create an activity if not already present
    due_docs = db.collection('rental') \
        .where('agency_id', '==', agency_id) \
        .where('date_to', '==', today_str) \
        .stream()

    for rental_doc in due_docs:
        rental_id = rental_doc.id
        # Check if activity already exists to avoid duplicates
        existing = db.collection('activity') \
            .where('agency_id', '==', agency_id) \
            .where('type', '==', 'due_today') \
            .where('rental_id', '==', rental_id) \
            .where('activity_date', '==', today_str) \
            .get()

        if len(existing) == 0:
            # Create a concise description; avoid heavy lookups
            description = f"Rental due today (ID: {rental_id})"
            db.collection('activity').add({
                'agency_id': agency_id,
                'description': description,
                'activity_date': today_str,
                'type': 'due_today',
                'rental_id': rental_id,
            })

    # 2) Fetch recent activities for the agency (limit reasonable size)
    activity_query = db.collection('activity') \
        .where('agency_id', '==', agency_id) \
        .order_by('activity_date', direction=Query.DESCENDING) \
        .limit(50)

    docs = activity_query.stream()
    items = []
    for doc in docs:
        data = doc.to_dict() or {}
        # Map to frontend expectation: description + date
        items.append({
            'description': data.get('description', ''),
            'date': data.get('activity_date'),
            'remote_id': doc.id,
        })

    return jsonify(items), 200


@analytics_bp.route('/activities', methods=['POST'])
@token_required
def add_activity():
    """Insert a new activity for the authenticated agency."""
    try:
        payload = request.get_json(silent=True) or {}
        if not payload:
            return jsonify({"error": "Invalid or missing JSON data"}), 400

        agency_id = request.current_user.get('user_id')
        description = (payload.get('description') or '').strip()
        date_value = payload.get('date') or payload.get('activity_date')

        if not description:
            return jsonify({"error": "description is required"}), 400

        # Normalize date to YYYY-MM-DD if possible
        activity_date = None
        if isinstance(date_value, str) and len(date_value) >= 10:
            # Accept ISO 8601 and just take the date part
            activity_date = date_value[:10]
        else:
            activity_date = date.today().isoformat()

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
