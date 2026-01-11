import pytest
import os
from app.db.auth_service import AuthService
from app.models import Agency


# tests for the auth service database operations
class TestAuthService:

    # makes sure password hashing and verification works
    def test_password_hashing(self):
        password = "TestPassword123"
        hashed = Agency.hash_password(password)

        assert hashed != password
        assert len(hashed) > 0
        assert Agency.verify_password(hashed, password)
        assert not Agency.verify_password(hashed, "WrongPassword")

    # tests creating a new user successfully
    def test_create_user_success(self):
        email = f'unittest_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Unit Test Agency'
        phone = '+1234567890'

        success, message, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success == True
        assert user_data is not None
        assert user_data['email'] == email
        assert user_data['name'] == name
        assert 'password' not in user_data

        # cleanup the test user
        if user_data:
            AuthService.delete_user(user_data['id'])
    
    # tests that duplicate emails are rejected
    def test_create_user_duplicate_email(self):
        email = f'duplicate_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Test Agency'
        phone = '+1234567890'

        # create first user
        success1, message1, user_data1 = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success1 == True

        # try to create duplicate which should fail
        success2, message2, user_data2 = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success2 == False
        assert 'already' in message2.lower()

        # cleanup
        if user_data1:
            AuthService.delete_user(user_data1['id'])

    # tests that valid credentials are accepted
    def test_verify_credentials_success(self):
        email = f'verify_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Verify Test'
        phone = '+1234567890'

        # create test user
        success_create, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success_create == True

        # verify the credentials work
        success_verify, message, verified_user = AuthService.verify_credentials(email, password)

        assert success_verify == True
        assert verified_user['id'] == user_data['id']
        assert verified_user['email'] == email

        # cleanup
        AuthService.delete_user(user_data['id'])

    # tests that wrong passwords are rejected
    def test_verify_credentials_wrong_password(self):
        email = f'wrong_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Wrong Test'
        phone = '+1234567890'

        # create test user
        success_create, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success_create == True

        # try with wrong password
        success_verify, message, verified_user = AuthService.verify_credentials(email, 'WrongPassword')

        assert success_verify == False
        assert verified_user is None

        # cleanup
        AuthService.delete_user(user_data['id'])

    # tests jwt token generation
    def test_generate_jwt_token(self):
        user_id = 'test_uid_123'
        email = 'test@example.com'

        token = AuthService.generate_jwt_token(user_id, email)

        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0

    # tests valid jwt token verification
    def test_verify_jwt_token_valid(self):
        user_id = 'test_uid_123'
        email = 'test@example.com'

        token = AuthService.generate_jwt_token(user_id, email)
        valid, payload = AuthService.verify_jwt_token(token)

        assert valid == True
        assert payload is not None
        assert payload['user_id'] == user_id
        assert payload['email'] == email

    # tests invalid jwt tokens are rejected
    def test_verify_jwt_token_invalid(self):
        invalid_token = 'invalid.token.here'

        valid, payload = AuthService.verify_jwt_token(invalid_token)

        assert valid == False
        assert payload is not None
        assert 'error' in payload

    # tests fetching user by their id
    def test_get_user_by_id(self):
        email = f'getbyid_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Get By ID Test'
        phone = '+1234567890'

        # create test user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success == True
        user_id = user_data['id']

        # fetch user by id
        retrieved_user = AuthService.get_user_by_id(user_id)

        assert retrieved_user is not None
        assert retrieved_user['id'] == user_id
        assert retrieved_user['email'] == email
        assert 'password' not in retrieved_user

        # cleanup
        AuthService.delete_user(user_id)

    # tests fetching user by their email
    def test_get_user_by_email(self):
        email = f'getbyemail_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Get By Email Test'
        phone = '+1234567890'

        # create test user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success == True

        # fetch user by email
        retrieved_user = AuthService.get_user_by_email(email)

        assert retrieved_user is not None
        assert retrieved_user['email'] == email
        assert 'password' not in retrieved_user

        # cleanup
        AuthService.delete_user(user_data['id'])

    # tests updating user profile data
    def test_update_user(self):
        email = f'update_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Original Name'
        phone = '+1234567890'

        # create test user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success == True
        user_id = user_data['id']

        # update the user
        update_data = {'name': 'Updated Name', 'phone': '+9999999999'}
        success_update, message = AuthService.update_user(user_id, update_data)

        assert success_update == True

        # verify the update worked
        retrieved_user = AuthService.get_user_by_id(user_id)
        assert retrieved_user['name'] == 'Updated Name'
        assert retrieved_user['phone'] == '+9999999999'

        # cleanup
        AuthService.delete_user(user_id)

    # tests deleting a user
    def test_delete_user(self):
        email = f'delete_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Delete Test'
        phone = '+1234567890'

        # create test user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )

        assert success == True
        user_id = user_data['id']

        # delete the user
        success_delete, message = AuthService.delete_user(user_id)

        assert success_delete == True

        # verify they're gone
        retrieved_user = AuthService.get_user_by_id(user_id)
        assert retrieved_user is None