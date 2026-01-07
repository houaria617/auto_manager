import os
from flask import Flask
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore



def create_app():
    app = Flask(__name__)
    CORS(app)
    # Allow both with/without trailing slash without redirects
    app.url_map.strict_slashes = False
    
    # Load environment variables
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production')
    
    # Check if we are in testing mode
    is_testing = os.environ.get('FLASK_ENV') == 'testing' or app.config.get('TESTING')

    if not firebase_admin._apps:  # Prevent initializing multiple times
        try:
            # Try to load the real file relative to this file's directory
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            cert_path = os.path.join(base_dir, "serviceAccountKey.json")
            cred = credentials.Certificate(cert_path)
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
    from .routes import clients, dashboard, rentals, payments, analytics, auth, notifications, vehicles
    
    app.register_blueprint(auth.auth_bp, url_prefix='/auth')
    app.register_blueprint(clients.client_bp, url_prefix='/clients')
    app.register_blueprint(dashboard.dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(rentals.rental_bp, url_prefix='/rentals')
    app.register_blueprint(payments.payment_bp, url_prefix='/payments')
    app.register_blueprint(analytics.analytics_bp, url_prefix='/analytics')
    app.register_blueprint(notifications.notifications_bp, url_prefix='/notifications')
    app.register_blueprint(vehicles.vehicles_bp, url_prefix='/vehicles')

    print(app.url_map)
    return app

# Helper to use in your routes/services
def get_db():
    return firestore.client()