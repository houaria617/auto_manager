import pytest
import os
from app.db.auth_service import AuthService
from app.models import Agency

class TestAuthService:
    
    def test_password_hashing(self):
        """Test password hashing works correctly"""
        password = "TestPassword123"
        hashed = Agency.hash_password(password)
        
        assert hashed != password
        assert len(hashed) > 0
        assert Agency.verify_password(hashed, password)
        assert not Agency.verify_password(hashed, "WrongPassword")
    
    def test_create_user_success(self):
        """Test successful user creation"""
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
        assert 'password' not in user_data  # Password should not be in response
        
        # Cleanup
        if user_data:
            AuthService.delete_user(user_data['id'])
    
    def test_create_user_duplicate_email(self):
        """Test creating user with duplicate email"""
        email = f'duplicate_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Test Agency'
        phone = '+1234567890'
        
        # Create first user
        success1, message1, user_data1 = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success1 == True
        
        # Try to create duplicate
        success2, message2, user_data2 = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success2 == False
        assert 'already' in message2.lower()
        
        # Cleanup
        if user_data1:
            AuthService.delete_user(user_data1['id'])
    
    def test_verify_credentials_success(self):
        """Test successful credential verification"""
        email = f'verify_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Verify Test'
        phone = '+1234567890'
        
        # Create user
        success_create, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success_create == True
        
        # Verify credentials
        success_verify, message, verified_user = AuthService.verify_credentials(email, password)
        
        assert success_verify == True
        assert verified_user['id'] == user_data['id']
        assert verified_user['email'] == email
        
        # Cleanup
        AuthService.delete_user(user_data['id'])
    
    def test_verify_credentials_wrong_password(self):
        """Test credential verification with wrong password"""
        email = f'wrong_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Wrong Test'
        phone = '+1234567890'
        
        # Create user
        success_create, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success_create == True
        
        # Try wrong password
        success_verify, message, verified_user = AuthService.verify_credentials(email, 'WrongPassword')
        
        assert success_verify == False
        assert verified_user is None
        
        # Cleanup
        AuthService.delete_user(user_data['id'])
    
    def test_generate_jwt_token(self):
        """Test JWT token generation"""
        user_id = 'test_uid_123'
        email = 'test@example.com'
        
        token = AuthService.generate_jwt_token(user_id, email)
        
        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0
    
    def test_verify_jwt_token_valid(self):
        """Test JWT token verification with valid token"""
        user_id = 'test_uid_123'
        email = 'test@example.com'
        
        token = AuthService.generate_jwt_token(user_id, email)
        valid, payload = AuthService.verify_jwt_token(token)
        
        assert valid == True
        assert payload is not None
        assert payload['user_id'] == user_id
        assert payload['email'] == email
    
    def test_verify_jwt_token_invalid(self):
        """Test JWT token verification with invalid token"""
        invalid_token = 'invalid.token.here'
        
        valid, payload = AuthService.verify_jwt_token(invalid_token)
        
        assert valid == False
        assert payload is not None
        assert 'error' in payload
    
    def test_get_user_by_id(self):
        """Test getting user by ID"""
        email = f'getbyid_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Get By ID Test'
        phone = '+1234567890'
        
        # Create user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success == True
        user_id = user_data['id']
        
        # Get user by ID
        retrieved_user = AuthService.get_user_by_id(user_id)
        
        assert retrieved_user is not None
        assert retrieved_user['id'] == user_id
        assert retrieved_user['email'] == email
        assert 'password' not in retrieved_user
        
        # Cleanup
        AuthService.delete_user(user_id)
    
    def test_get_user_by_email(self):
        """Test getting user by email"""
        email = f'getbyemail_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Get By Email Test'
        phone = '+1234567890'
        
        # Create user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success == True
        
        # Get user by email
        retrieved_user = AuthService.get_user_by_email(email)
        
        assert retrieved_user is not None
        assert retrieved_user['email'] == email
        assert 'password' not in retrieved_user
        
        # Cleanup
        AuthService.delete_user(user_data['id'])
    
    def test_update_user(self):
        """Test updating user data"""
        email = f'update_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Original Name'
        phone = '+1234567890'
        
        # Create user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success == True
        user_id = user_data['id']
        
        # Update user
        update_data = {'name': 'Updated Name', 'phone': '+9999999999'}
        success_update, message = AuthService.update_user(user_id, update_data)
        
        assert success_update == True
        
        # Verify update
        retrieved_user = AuthService.get_user_by_id(user_id)
        assert retrieved_user['name'] == 'Updated Name'
        assert retrieved_user['phone'] == '+9999999999'
        
        # Cleanup
        AuthService.delete_user(user_id)
    
    def test_delete_user(self):
        """Test deleting user"""
        email = f'delete_{os.urandom(4).hex()}@example.com'
        password = 'TestPass123'
        name = 'Delete Test'
        phone = '+1234567890'
        
        # Create user
        success, _, user_data = AuthService.create_user(
            email=email,
            password=password,
            name=name,
            phone=phone
        )
        
        assert success == True
        user_id = user_data['id']
        
        # Delete user
        success_delete, message = AuthService.delete_user(user_id)
        
        assert success_delete == True
        
        # Verify deletion
        retrieved_user = AuthService.get_user_by_id(user_id)
        assert retrieved_user is None