import jwt
import os
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, Tuple
from app import get_db
from ..models import Agency

class AuthService:
    COLLECTION_NAME = 'agencies'
    
    @staticmethod
    def create_user(email: str, password: str, name: str, phone: str) -> Tuple[bool, str, Optional[Dict]]:
        """
        Create a new agency user
        Returns: (success, message, user_data)
        """
        try:
            db = get_db()
            
            # Check if email already exists
            agencies = db.collection(AuthService.COLLECTION_NAME).where('email', '==', email).limit(1).stream()
            if list(agencies):
                return False, "Email already registered", None
            
            # Hash password
            hashed_password = Agency.hash_password(password)
            
            # Create agency object
            agency = Agency(
                name=name,
                password=hashed_password,
                email=email,
                join_date=datetime.now().date(),
                phone=phone
            )
            
            # Save to Firestore
            doc_ref = db.collection(AuthService.COLLECTION_NAME).document()
            agency_data = {
                'name': name,
                'password': hashed_password,
                'email': email,
                'join_date': agency.join_date.isoformat(),
                'phone': phone
            }
            doc_ref.set(agency_data)
            
            # Return user data without password
            return True, "User created successfully", {
                'id': doc_ref.id,
                'name': name,
                'email': email,
                'phone': phone,
                'join_date': agency.join_date.isoformat()
            }
            
        except Exception as e:
            return False, f"Error creating user: {str(e)}", None
    
    @staticmethod
    def verify_credentials(email: str, password: str) -> Tuple[bool, str, Optional[Dict]]:
        """
        Verify email and password
        Returns: (success, message, user_data)
        """
        try:
            db = get_db()
            
            # Find user by email
            agencies = db.collection(AuthService.COLLECTION_NAME).where('email', '==', email).limit(1).stream()
            
            agency_doc = None
            for doc in agencies:
                agency_doc = doc
                break
            
            if not agency_doc:
                return False, "Invalid email or password", None
            
            agency_data = agency_doc.to_dict()
            stored_password = agency_data.get('password')
            
            # Verify password
            if not Agency.verify_password(stored_password, password):
                return False, "Invalid email or password", None
            
            # Return user data without password
            user_data = {
                'id': agency_doc.id,
                'name': agency_data.get('name'),
                'email': agency_data.get('email'),
                'phone': agency_data.get('phone'),
                'join_date': agency_data.get('join_date')
            }
            
            return True, "Login successful", user_data
            
        except Exception as e:
            return False, f"Authentication error: {str(e)}", None
    
    @staticmethod
    def generate_jwt_token(user_id: str, email: str) -> str:
        """
        Generate a JWT token for API authentication
        """
        try:
            secret_key = os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production')
            payload = {
                'user_id': user_id,
                'email': email,
                'exp': datetime.utcnow() + timedelta(days=7),
                'iat': datetime.utcnow()
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            return token
        except Exception as e:
            print(f"Error generating JWT: {str(e)}")
            return None
    
    @staticmethod
    def verify_jwt_token(token: str) -> Tuple[bool, Optional[Dict]]:
        """
        Verify JWT token and return payload
        Returns: (valid, payload)
        """
        try:
            secret_key = os.getenv('SECRET_KEY', 'your-default-secret-key-change-in-production')
            payload = jwt.decode(token, secret_key, algorithms=['HS256'])
            return True, payload
        except jwt.ExpiredSignatureError:
            return False, {'error': 'Token expired'}
        except jwt.InvalidTokenError:
            return False, {'error': 'Invalid token'}
    
    @staticmethod
    def get_user_by_id(user_id: str) -> Optional[Dict]:
        """
        Get user data by ID
        Returns: user_data or None
        """
        try:
            db = get_db()
            doc = db.collection(AuthService.COLLECTION_NAME).document(user_id).get()
            
            if doc.exists:
                data = doc.to_dict()
                # Remove password from response
                if 'password' in data:
                    del data['password']
                data['id'] = doc.id
                return data
            return None
        except Exception as e:
            print(f"Error getting user: {str(e)}")
            return None
    
    @staticmethod
    def get_user_by_email(email: str) -> Optional[Dict]:
        """
        Get user data by email
        Returns: user_data or None
        """
        try:
            db = get_db()
            agencies = db.collection(AuthService.COLLECTION_NAME).where('email', '==', email).limit(1).stream()
            
            for doc in agencies:
                data = doc.to_dict()
                # Remove password from response
                if 'password' in data:
                    del data['password']
                data['id'] = doc.id
                return data
            return None
        except Exception as e:
            print(f"Error getting user by email: {str(e)}")
            return None
    
    @staticmethod
    def update_user(user_id: str, update_data: Dict[str, Any]) -> Tuple[bool, str]:
        """
        Update user data
        Returns: (success, message)
        """
        try:
            db = get_db()
            
            # If password is being updated, hash it
            if 'password' in update_data:
                update_data['password'] = Agency.hash_password(update_data['password'])
            
            doc_ref = db.collection(AuthService.COLLECTION_NAME).document(user_id)
            doc_ref.update(update_data)
            
            return True, "User updated successfully"
        except Exception as e:
            return False, f"Error updating user: {str(e)}"
    
    @staticmethod
    def delete_user(user_id: str) -> Tuple[bool, str]:
        """
        Delete user
        Returns: (success, message)
        """
        try:
            db = get_db()
            db.collection(AuthService.COLLECTION_NAME).document(user_id).delete()
            return True, "User deleted successfully"
        except Exception as e:
            return False, f"Error deleting user: {str(e)}"