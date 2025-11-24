from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()
DATABASE_URL = "postgresql://postgres:djamel123@localhost:5432/auto_manager"

def create_app():
    app = Flask(__name__)

    app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URL
    db.init_app(app)
    CORS(app) 

    from .routes import client_routes
    app.register_blueprint(client_routes.client_bp)

    return app