import os
from flask import Flask
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore



def create_app():
    app = Flask(__name__)
    CORS(app)
# lets urls work with or without trailing slashes
    app.url_map.strict_slashes = False

    # grab the secret key from env or use a default for dev
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production') 

    # figure out if were running tests
    is_testing = os.environ.get('FLASK_ENV') == 'testing' or app.config.get('TESTING')

    # set up firebase only once
    if not firebase_admin._apps:
        try:
            cred = credentials.Certificate("serviceAccountKey.json")
            firebase_admin.initialize_app(cred)
        except (IOError, FileNotFoundError):
            # use dummy creds for tests, warn otherwise
            if is_testing:
                firebase_admin.initialize_app(
                    options={'projectId': 'test-project'})
            else:
                print(
                    "Warning: serviceAccountKey.json not found. Firestore will not work.")

    # wire up all the route blueprints
    from .routes import clients, dashboard, rentals, payments, analytics, auth, notifications, vehicles
    
    app.register_blueprint(auth.auth_bp, url_prefix='/auth')
    app.register_blueprint(clients.client_bp, url_prefix='/clients')
    app.register_blueprint(dashboard.dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(rentals.rental_bp, url_prefix='/rentals')
    app.register_blueprint(payments.payment_bp, url_prefix='/payments')
    app.register_blueprint(analytics.analytics_bp, url_prefix='/analytics')
    app.register_blueprint(notifications.notifications_bp, url_prefix='/notifications')
    app.register_blueprint(vehicles.vehicle_bp, url_prefix='/vehicles')

    print(app.url_map)
    return app

# helper for getting a firestore client in routes
def get_db():
    return firestore.client()