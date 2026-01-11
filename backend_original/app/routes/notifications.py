from flask import Blueprint, request, jsonify
from app.models import FCMToken
from app.firebase_config import send_notification
from app import get_db
from functools import wraps
import jwt
import os

notifications_bp = Blueprint('notifications', __name__)


# jwt decorator to protect notification routes
def jwt_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')

        if not token or not token.startswith('Bearer '):
            return jsonify({'error': 'No token provided'}), 401

        try:
            # strip the bearer prefix and decode
            token = token.split(' ')[1]
            payload = jwt.decode(
                token,
                os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production'),
                algorithms=['HS256']
            )
            kwargs['agency_id'] = payload['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401

        return f(*args, **kwargs)
    return decorated


# saves or updates the fcm token for push notifications
@notifications_bp.route('/register-token', methods=['POST'])
@jwt_required
def register_token(agency_id):
    try:
        data = request.get_json()

        if not data or 'token' not in data:
            return jsonify({'error': 'FCM token is required'}), 400

        fcm_token = data['token']
        db = get_db()

        # check if this token already exists in the database
        tokens_ref = db.collection('fcm_tokens')
        existing = tokens_ref.where('token', '==', fcm_token).limit(1).get()

        if existing:
            # update the existing token with the new agency
            for doc in existing:
                doc.reference.update({
                    'user_id': agency_id,
                    'token': fcm_token
                })
            print(f"✅ Updated FCM token for agency {agency_id}")
        else:
            # create a new token record
            tokens_ref.add({
                'user_id': agency_id,
                'token': fcm_token
            })
            print(f"✅ Registered new FCM token for agency {agency_id}")

        return jsonify({'message': 'Token saved successfully'}), 200

    except Exception as e:
        print(f"❌ Error in register_token: {e}")
        return jsonify({'error': 'Failed to save token'}), 500


# sends a test notification to verify firebase is working
@notifications_bp.route('/test-notification', methods=['POST'])
@jwt_required
def test_notification(agency_id):
    try:
        db = get_db()

        # find the fcm token for this agency
        tokens_ref = db.collection('fcm_tokens')
        tokens = tokens_ref.where('user_id', '==', agency_id).limit(1).get()

        if not tokens:
            return jsonify({
                'error': 'No FCM token found. Please register token first.'
            }), 404

        # grab the token and send the test notification
        token_doc = list(tokens)[0]
        fcm_token = token_doc.to_dict()['token']

        success = send_notification(
            token=fcm_token,
            title="Test Notification 🎉",
            body="If you see this, Firebase notifications are working!"
        )

        if success:
            return jsonify({'message': 'Test notification sent successfully'}), 200
        else:
            return jsonify({'error': 'Failed to send notification'}), 500

    except Exception as e:
        print(f"❌ Error in test_notification: {e}")
        return jsonify({'error': str(e)}), 500


# checks for rentals due today and sends push notifications
@notifications_bp.route('/check-due-today', methods=['POST'])
def check_due_today():
    try:
        from datetime import date

        db = get_db()
        today = date.today()

        # find all ongoing rentals that are due today
        rentals_ref = db.collection('rentals')
        due_rentals = rentals_ref.where('date_to', '==', today)\
                                 .where('rental_state', '==', 'ongoing')\
                                 .get()

        if not due_rentals:
            return jsonify({
                'message': 'No rentals due today',
                'notifications_sent': 0
            }), 200

        # group rentals by agency so we can batch notifications
        rentals_by_agency = {}
        for rental_doc in due_rentals:
            rental = rental_doc.to_dict()
            agency_id = rental['agency_id']

            if agency_id not in rentals_by_agency:
                rentals_by_agency[agency_id] = []
            rentals_by_agency[agency_id].append(rental)

        # send notifications to each agency
        notifications_sent = 0

        for agency_id, rentals in rentals_by_agency.items():
            # get the fcm token for this agency
            tokens_ref = db.collection('fcm_tokens')
            tokens = tokens_ref.where('user_id', '==', agency_id).limit(1).get()

            if not tokens:
                print(f"⚠️ No FCM token for agency {agency_id}")
                continue

            token_doc = list(tokens)[0]
            fcm_token = token_doc.to_dict()['token']

            # build the notification message
            rental_count = len(rentals)
            if rental_count == 1:
                body = "One rental must be returned today."
            else:
                body = f"{rental_count} rentals must be returned today."

            # send the notification
            success = send_notification(
                token=fcm_token,
                title="Rental Due Today",
                body=body
            )

            if success:
                notifications_sent += 1

        return jsonify({
            'message': f'Checked rentals for {len(rentals_by_agency)} agencies',
            'notifications_sent': notifications_sent,
            'total_due_rentals': len(due_rentals)
        }), 200

    except Exception as e:
        print(f"❌ Error in check_due_today: {e}")
        return jsonify({'error': str(e)}), 500