import os
from flask import Flask
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore


def create_app():
    app = Flask(__name__)
    CORS(app)
    
    # Load environment variables
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production')
    
    # Check if we are in testing mode
    is_testing = os.environ.get('FLASK_ENV') == 'testing' or app.config.get('TESTING')

    if not firebase_admin._apps:  # Prevent initializing multiple times
        try:
            # Try to load the real file
            cred = credentials.Certificate("serviceAccountKey.json")
            firebase_admin.initialize_app(cred)
        except (IOError, FileNotFoundError):
            # If the file is missing
            if is_testing:
                # Use a dummy credential for testing purposes
                firebase_admin.initialize_app(
                    options={'projectId': 'test-project'})
            else:
                # If we are NOT testing and the file is missing, we should probably know
                print(
                    "Warning: serviceAccountKey.json not found. Firestore will not work.")

    # Register blueprints
    from .routes import clients, dashboard, rentals, payments, analytics, auth
    
    app.register_blueprint(auth.auth_bp, url_prefix='/auth')
    app.register_blueprint(clients.client_bp, url_prefix='/clients')
    app.register_blueprint(dashboard.dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(rentals.rental_bp, url_prefix='/rentals')
    app.register_blueprint(payments.payment_bp, url_prefix='/payments')
    app.register_blueprint(analytics.analytics_bp, url_prefix='/analytics')

    print(app.url_map)
    return app

# Helper to use in your routes/services
def get_db():
    return firestore.client()