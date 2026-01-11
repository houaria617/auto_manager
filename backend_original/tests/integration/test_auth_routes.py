import pytest
import os
from app.db.auth_service import AuthService


# integration tests for auth routes
class TestAuthRoutes:

    # tests successful user signup flow
    def test_signup_success(self, client):
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

        # cleanup
        if 'user' in data:
            AuthService.delete_user(data['user']['id'])

    # tests signup validation for missing fields
    def test_signup_missing_fields(self, client):
        incomplete_data = {
            'email': 'test@example.com',
            'password': 'TestPass123'
        }

        response = client.post('/auth/signup', json=incomplete_data)

        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data

    # tests signup rejection for weak passwords
    def test_signup_weak_password(self, client):
        user_data = {
            'email': f'weak_{os.urandom(4).hex()}@example.com',
            'password': '123',
            'name': 'Weak Password Test',
            'phone': '+1234567890'
        }

        response = client.post('/auth/signup', json=user_data)

        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
        assert 'password' in data['error'].lower()

    # tests signup rejection for invalid email format
    def test_signup_invalid_email(self, client):
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

    # tests signup rejection for duplicate email
    def test_signup_duplicate_email(self, client):
        email = f'duplicate_{os.urandom(4).hex()}@example.com'
        user_data = {
            'email': email,
            'password': 'TestPass123',
            'name': 'Duplicate Test',
            'phone': '+1234567890'
        }

        # first signup should succeed
        response1 = client.post('/auth/signup', json=user_data)
        assert response1.status_code == 201
        data1 = response1.get_json()

        # second signup with same email should fail
        response2 = client.post('/auth/signup', json=user_data)
        assert response2.status_code == 400
        data2 = response2.get_json()
        assert 'error' in data2
        assert 'already' in data2['error'].lower()

        # cleanup
        if 'user' in data1:
            AuthService.delete_user(data1['user']['id'])

    # tests successful login flow
    def test_login_success(self, client):
        # create user first
        user_data = {
            'email': f'login_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Login Test',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        assert signup_response.status_code == 201

        # try to login
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

        # cleanup
        signup_data = signup_response.get_json()
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests login rejection for invalid credentials
    def test_login_invalid_credentials(self, client):
        login_data = {
            'email': 'nonexistent@example.com',
            'password': 'WrongPassword123'
        }

        response = client.post('/auth/login', json=login_data)

        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data

    # tests login validation for missing fields
    def test_login_missing_fields(self, client):
        incomplete_data = {
            'email': 'test@example.com'
        }

        response = client.post('/auth/login', json=incomplete_data)

        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data

    # tests valid token verification
    def test_verify_token_valid(self, client):
        # create user and get token
        user_data = {
            'email': f'verify_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Verify Test',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']

        # verify the token
        verify_response = client.post('/auth/verify-token', json={'token': token})

        assert verify_response.status_code == 200
        verify_data = verify_response.get_json()
        assert verify_data['valid'] == True
        assert 'payload' in verify_data

        # cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests invalid token rejection
    def test_verify_token_invalid(self, client):
        invalid_token = 'invalid.token.here'

        response = client.post('/auth/verify-token', json={'token': invalid_token})

        assert response.status_code == 401
        data = response.get_json()
        assert data['valid'] == False

    # tests getting current user with valid token
    def test_get_current_user(self, client):
        # create user
        user_data = {
            'email': f'current_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Current User Test',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']

        # get current user
        headers = {'Authorization': f'Bearer {token}'}
        response = client.get('/auth/me', headers=headers)

        assert response.status_code == 200
        data = response.get_json()
        assert 'user' in data
        assert data['user']['email'] == user_data['email']
        assert 'password' not in data['user']

        # cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests rejection when no token provided
    def test_get_current_user_no_token(self, client):
        response = client.get('/auth/me')

        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data

    # tests updating user profile
    def test_update_profile(self, client):
        # create user
        user_data = {
            'email': f'update_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Original Name',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']

        # update profile
        headers = {'Authorization': f'Bearer {token}'}
        update_data = {'name': 'Updated Name', 'phone': '+9999999999'}
        response = client.put('/auth/update-profile', json=update_data, headers=headers)

        assert response.status_code == 200
        data = response.get_json()
        assert data['user']['name'] == 'Updated Name'
        assert data['user']['phone'] == '+9999999999'

        # cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests changing password
    def test_change_password(self, client):
        # create user
        user_data = {
            'email': f'changepass_{os.urandom(4).hex()}@example.com',
            'password': 'OldPass123',
            'name': 'Change Password Test',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']

        # change the password
        headers = {'Authorization': f'Bearer {token}'}
        change_data = {
            'old_password': 'OldPass123',
            'new_password': 'NewPass456'
        }
        response = client.put('/auth/change-password', json=change_data, headers=headers)

        assert response.status_code == 200

        # verify new password works
        login_data = {
            'email': user_data['email'],
            'password': 'NewPass456'
        }
        login_response = client.post('/auth/login', json=login_data)
        assert login_response.status_code == 200

        # cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests logout endpoint
    def test_logout(self, client):
        # create user and get token
        user_data = {
            'email': f'logout_{os.urandom(4).hex()}@example.com',
            'password': 'TestPass123',
            'name': 'Logout Test',
            'phone': '+1234567890'
        }

        signup_response = client.post('/auth/signup', json=user_data)
        signup_data = signup_response.get_json()
        token = signup_data['token']

        # logout
        headers = {'Authorization': f'Bearer {token}'}
        response = client.post('/auth/logout', headers=headers)

        assert response.status_code == 200
        data = response.get_json()
        assert 'message' in data

        # cleanup
        if 'user' in signup_data:
            AuthService.delete_user(signup_data['user']['id'])

    # tests protected route access without token
    def test_protected_route_without_token(self, client):
        response = client.post('/auth/logout')

        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data

    # tests account deletion
    def test_delete_account(self, client):
        # create user
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

        # delete account
        headers = {'Authorization': f'Bearer {token}'}
        response = client.delete('/auth/delete-account', headers=headers)

        assert response.status_code == 200

        # verify user is gone
        deleted_user = AuthService.get_user_by_id(user_id)
        assert deleted_user is None