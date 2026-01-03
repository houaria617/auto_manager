import os
from flask import Flask
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

def create_app():
    app = Flask(__name__)
    CORS(app)
    # Check if we are in testing mode
    is_testing = os.environ.get('FLASK_ENV') == 'testing' or app.config.get('TESTING')

    if not firebase_admin._apps: # Prevent initializing multiple times
        try:
            # Try to load the real file
            cred = credentials.Certificate("serviceAccountKey.json")
            firebase_admin.initialize_app(cred)
        except (IOError, FileNotFoundError):
            # If the file is missing (like in your tests right now)
            if is_testing:
                # Use a dummy credential for testing purposes
                firebase_admin.initialize_app(options={'projectId': 'test-project'})
            else:
                # If we are NOT testing and the file is missing, we should probably know
                print("Warning: serviceAccountKey.json not found. Firestore will not work.")
            
    from .routes import clients, dashboard
    app.register_blueprint(clients.client_bp, url_prefix='/clients')
    app.register_blueprint(dashboard.dashboard_bp, url_prefix='/dashboard')

    # ... keep your blueprint registrations below ...
    print(app.url_map)
    return app

# Helper to use in your routes/services
def get_db():
    return firestore.client()