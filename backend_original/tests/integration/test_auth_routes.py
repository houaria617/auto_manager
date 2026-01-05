import pytest
import os
from app.db.auth_service import AuthService

class TestAuthRoutes:
    
    def test_signup_success(self, client):
        """Test successful user signup"""
        user_data = {
            'email': f'signup_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Signup Test Agency',
            'phone': '+1234567890'
        }
        
        response = client.post('/auth/signup', json=user_data)
        
        assert response.status_code == 201
        data = response.get_json()
        assert 'user' in data
        assert 'token' in data
        assert data['user']['email'] == user_data['email']
        assert 'password' not in data['user']
        
        # Cleanup
        if 'user' in data:
            AuthService.delete_user(data['user']['id'])
    
    def test_signup_missing_fields(self, client):
        """Test signup with missing required fields"""
        incomplete_data = {
            'email': 'test@example.com',
            'password': 'TestPass123'
            # Missing name and phone
        }
        
        response = client.post('/auth/signup', json=incomplete_data)
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
    
    def test_signup_weak_password(self, client):
        """Test signup with weak password"""
        user_data = {
            'email': f'weak_{os.urandom(4).hex()}@example.com',
            'password': '123',  # Too short
            'name': 'Weak Password Test',
            'phone': '+1234567890'
        }
        
        response = client.post('/auth/signup', json=user_data)
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
        assert 'password' in data['error'].lower()
    
    def test_signup_invalid_email(self, client):
        """Test signup with invalid email"""
        user_data = {
            'email': 'invalid-email',
            'password': 'TestPass123',
            'name': 'Invalid Email Test',
            'phone': '+1234567890'
        }
        
        response = client.post('/auth/signup', json=user_data)
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
        assert 'email' in data['error'].lower()
    
    def test_signup_duplicate_email(self, client):
        """Test signup with duplicate email"""
        email = f'duplicate_{os.urandom(4).hex()}@example.com'
        user_data = {
            'email': email,
            'password': 'TestPass123',
            'name': 'Duplicate Test',
            'phone': '+1234567890'
        }
        
        # First signup
        response1 = client.post('/auth/signup', json=user_data)
        assert response1.status_code == 201
        data1 = response1.get_json()
        
        # Second signup with same email
        response2 = client.post('/auth/signup', json=user_data)
        assert response2.status_code == 400
        data2 = response2.get_json()
        assert 'error' in data2
        assert 'already' in data2['error'].lower()
        
        # Cleanup
        if 'user' in data1:
            AuthService.delete_user(data1['user']['id'])
    
    def test_login_success(self, client):
        """Test successful login"""
        # Create user first
        user_data = {
            'email': f'login_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Login Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        assert signup_response.status_code == 201
        
        # Login
        login_data = {
            'email': user_data['email'],
            'password': user_data['password']
        }
        
        login_response = client.post('/auth/login', json=login_data)
        
        assert login_response.status_code == 200
        data = login_response.get_json()
        assert 'user' in data
        assert 'token' in data
        assert data['user']['email'] == user_data['email']
        assert 'password' not in data['user']
        
        # Cleanup
        signup_data = signup_response.get_json()
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_login_invalid_credentials(self, client):
        """Test login with invalid credentials"""
        login_data = {
            'email': 'nonexistent@example.com',
            'password': 'WrongPassword123'
        }
        
        response = client.post('/auth/login', json=login_data)
        
        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data
    
    def test_login_missing_fields(self, client):
        """Test login with missing fields"""
        incomplete_data = {
            'email': 'test@example.com'
            # Missing password
        }
        
        response = client.post('/auth/login', json=incomplete_data)
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
    
    def test_verify_token_valid(self, client):
        """Test token verification with valid token"""
        # Create user and get token
        user_data = {
            'email': f'verify_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Verify Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        
        # Verify token
        verify_response = client.post('/auth/verify-token', json={'token': token})
        
        assert verify_response.status_code == 200
        verify_data = verify_response.get_json()
        assert verify_data['valid'] == True
        assert 'payload' in verify_data
        
        # Cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_verify_token_invalid(self, client):
        """Test token verification with invalid token"""
        invalid_token = 'invalid.token.here'
        
        response = client.post('/auth/verify-token', json={'token': invalid_token})
        
        assert response.status_code == 401
        data = response.get_json()
        assert data['valid'] == False
    
    def test_get_current_user(self, client):
        """Test getting current user with valid token"""
        # Create user
        user_data = {
            'email': f'current_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Current User Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        
        # Get current user
        headers = {'Authorization': f'Bearer {token}'}
        response = client.get('/auth/me', headers=headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'user' in data
        assert data['user']['email'] == user_data['email']
        assert 'password' not in data['user']
        
        # Cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_get_current_user_no_token(self, client):
        """Test getting current user without token"""
        response = client.get('/auth/me')
        
        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data
    
    def test_update_profile(self, client):
        """Test updating user profile"""
        # Create user
        user_data = {
            'email': f'update_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Original Name',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        
        # Update profile
        headers = {'Authorization': f'Bearer {token}'}
        update_data = {'name': 'Updated Name', 'phone': '+9999999999'}
        response = client.put('/auth/update-profile', json=update_data, headers=headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['user']['name'] == 'Updated Name'
        assert data['user']['phone'] == '+9999999999'
        
        # Cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_change_password(self, client):
        """Test changing password"""
        # Create user
        user_data = {
            'email': f'changepass_{os.urandom(4).hex()}@example.com',
            'password': 'OldPass123',
            'name': 'Change Password Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        
        # Change password
        headers = {'Authorization': f'Bearer {token}'}
        change_data = {
            'old_password': 'OldPass123',
            'new_password': 'NewPass456'
        }
        response = client.put('/auth/change-password', json=change_data, headers=headers)
        
        assert response.status_code == 200
        
        # Try logging in with new password
        login_data = {
            'email': user_data['email'],
            'password': 'NewPass456'
        }
        login_response = client.post('/auth/login', json=login_data)
        assert login_response.status_code == 200
        
        # Cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_logout(self, client):
        """Test logout endpoint"""
        # Create user and get token
        user_data = {
            'email': f'logout_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Logout Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        
        # Logout
        headers = {'Authorization': f'Bearer {token}'}
        response = client.post('/auth/logout', headers=headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'message' in data
        
        # Cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])
    
    def test_protected_route_without_token(self, client):
        """Test accessing protected route without token"""
        response = client.post('/auth/logout')
        
        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data
    
    def test_delete_account(self, client):
        """Test deleting account"""
        # Create user
        user_data = {
            'email': f'delete_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Delete Test',
            'phone': '+1234567890'
        }
        
        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']
        user_id = signup_data['user']['id']
        
        # Delete account
        headers = {'Authorization': f'Bearer {token}'}
        response = client.delete('/auth/delete-account', headers=headers)
        
        assert response.status_code == 200
        
        # Verify user is deleted
        deleted_user = AuthService.get_user_by_id(user_id)
        assert deleted_user is None