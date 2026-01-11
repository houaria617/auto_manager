from flask import Blueprint, request, jsonify
from functools import wraps
from app.db.auth_service import AuthService

auth_bp = Blueprint('auth', __name__)

# decorator that protects routes requiring a valid jwt token
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # try to extract the token from the authorization header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(' ')[1]
            except IndexError:
                return jsonify({'error': 'Invalid token format'}), 401
        
        if not token:
            return jsonify({'error': 'Token is missing'}), 401
        
        # check if the token is valid and not expired
        valid, payload = AuthService.verify_jwt_token(token)
        
        if not valid:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        # attach user info to the request for use in route handlers
        request.current_user = payload
        return f(*args, **kwargs)
    
    return decorated

# handles new agency registration
@auth_bp.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        
        # make sure all required fields are present
        required_fields = ['email', 'password', 'name', 'phone']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({'error': f'{field} is required'}), 400
        
        email = data['email'].strip()
        password = data['password']
        name = data['name'].strip()
        phone = data['phone'].strip()
        
        # enforce minimum password length
        if len(password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400
        
        # basic email format check
        if '@' not in email or '.' not in email:
            return jsonify({'error': 'Invalid email format'}), 400
        
        # create the new user in firestore
        success, message, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        if success:
            # give them a token so they can start making authenticated requests
            token = AuthService.generate_jwt_token(user_data['id'], email)
            
            return jsonify({
                'message': message,
                'user': user_data,
                'token': token
            }), 201
        else:
            return jsonify({'error': message}), 400
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# authenticates a user with email and password
@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # both fields are required to login
        if not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password are required'}), 400
        
        email = data['email'].strip()
        password = data['password']
        
        # check if the credentials match whats in the database
        success, message, user_data = AuthService.verify_credentials(email, password)
        
        if success:
            # generate a fresh token for this session
            token = AuthService.generate_jwt_token(user_data['id'], email)
            
            return jsonify({
                'message': message,
                'user': user_data,
                'token': token
            }), 200
        else:
            return jsonify({'error': message}), 401
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# checks if a jwt token is still valid
@auth_bp.route('/verify-token', methods=['POST'])
def verify_token():
    try:
        data = request.get_json()
        token = data.get('token')
        
        if not token:
            return jsonify({'error': 'Token is required'}), 400
        
        valid, payload = AuthService.verify_jwt_token(token)
        
        if valid:
            return jsonify({
                'valid': True,
                'payload': payload
            }), 200
        else:
            return jsonify({
                'valid': False,
                'error': payload.get('error', 'Invalid token')
            }), 401
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# returns the profile of the currently logged in user
@auth_bp.route('/me', methods=['GET'])
@token_required
def get_current_user():
    try:
        user_id = request.current_user.get('user_id')
        
        user_data = AuthService.get_user_by_id(user_id)
        
        if user_data:
            return jsonify({'user': user_data}), 200
        else:
            return jsonify({'error': 'User not found'}), 404
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# allows users to change their name or phone
@auth_bp.route('/update-profile', methods=['PUT'])
@token_required
def update_profile():
    try:
        data = request.get_json()
        user_id = request.current_user.get('user_id')
        
        # only allow specific fields to be updated for security
        allowed_fields = ['name', 'phone']
        update_data = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_data:
            return jsonify({'error': 'No valid fields to update'}), 400
        
        success, message = AuthService.update_user(user_id, update_data)
        
        if success:
            # return the updated user data
            user_data = AuthService.get_user_by_id(user_id)
            return jsonify({
                'message': message,
                'user': user_data
            }), 200
        else:
            return jsonify({'error': message}), 400
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# lets a user change their password after verifying the old one
@auth_bp.route('/change-password', methods=['PUT'])
@token_required
def change_password():
    try:
        data = request.get_json()
        user_id = request.current_user.get('user_id')
        
        old_password = data.get('old_password')
        new_password = data.get('new_password')
        
        if not old_password or not new_password:
            return jsonify({'error': 'Old password and new password are required'}), 400
        
        if len(new_password) < 6:
            return jsonify({'error': 'New password must be at least 6 characters'}), 400
        
        # fetch user to verify the old password
        user_data = AuthService.get_user_by_id(user_id)
        if not user_data:
            return jsonify({'error': 'User not found'}), 404
        
        # make sure they know their current password
        email = user_data.get('email')
        success, _, _ = AuthService.verify_credentials(email, old_password)
        
        if not success:
            return jsonify({'error': 'Old password is incorrect'}), 401
        
        # save the new password
        success, message = AuthService.update_user(user_id, {'password': new_password})
        
        if success:
            return jsonify({'message': 'Password changed successfully'}), 200
        else:
            return jsonify({'error': message}), 400
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# permanently removes a users account from the system
@auth_bp.route('/delete-account', methods=['DELETE'])
@token_required
def delete_account():
    try:
        user_id = request.current_user.get('user_id')
        
        success, message = AuthService.delete_user(user_id)
        
        if success:
            return jsonify({'message': message}), 200
        else:
            return jsonify({'error': message}), 400
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# logs out the user, client should discard the token
@auth_bp.route('/logout', methods=['POST'])
@token_required
def logout():
    return jsonify({'message': 'Logout successful. Please remove token from client.'}), 200