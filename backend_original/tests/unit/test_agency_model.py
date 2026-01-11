import pytest
from datetime import datetime
from app.models.agency import Agency


# tests for the agency model
class TestAgencyModel:

    # tests basic agency creation
    def test_agency_creation(self):
        agency = Agency(
            id='test_123',
            name='Test Agency',
            email='test@example.com',
            phone='+1234567890'
        )

        assert agency.id == 'test_123'
        assert agency.name == 'Test Agency'
        assert agency.email == 'test@example.com'
        assert agency.phone == '+1234567890'
        assert isinstance(agency.join_date, datetime)

    # tests converting agency to dictionary
    def test_agency_to_dict(self):
        join_date = datetime.now()
        agency = Agency(
            id='test_123',
            name='Test Agency',
            email='test@example.com',
            phone='+1234567890',
            join_date=join_date
        )

        agency_dict = agency.to_dict()

        assert isinstance(agency_dict, dict)
        assert agency_dict['id'] == 'test_123'
        assert agency_dict['name'] == 'Test Agency'
        assert agency_dict['email'] == 'test@example.com'
        assert agency_dict['phone'] == '+1234567890'
        assert 'join_date' in agency_dict

    # tests creating agency from dictionary
    def test_agency_from_dict(self):
        data = {
            'id': 'test_456',
            'name': 'Dict Agency',
            'email': 'dict@example.com',
            'phone': '+9876543210',
            'join_date': datetime.now().isoformat()
        }

        agency = Agency.from_dict(data)

        assert agency.id == 'test_456'
        assert agency.name == 'Dict Agency'
        assert agency.email == 'dict@example.com'
        assert agency.phone == '+9876543210'
        assert isinstance(agency.join_date, datetime)
    
    # tests saving and retrieving agency from firestore
    def test_agency_save_and_retrieve(self):
        import os
        test_id = f'test_{os.urandom(4).hex()}'

        agency = Agency(
            id=test_id,
            name='Save Test Agency',
            email=f'{test_id}@example.com',
            phone='+1234567890'
        )

        # save to firestore
        success = agency.save()
        assert success == True

        # retrieve and verify
        retrieved_agency = Agency.get_by_id(test_id)
        assert retrieved_agency is not None
        assert retrieved_agency.id == test_id
        assert retrieved_agency.name == 'Save Test Agency'

        # cleanup
        retrieved_agency.delete()
    
    # tests retrieving agency by email
    def test_agency_get_by_email(self):
        import os
        test_id = f'test_{os.urandom(4).hex()}'
        test_email = f'{test_id}@example.com'

        agency = Agency(
            id=test_id,
            name='Email Test Agency',
            email=test_email,
            phone='+1234567890'
        )

        # save to firestore
        agency.save()

        # retrieve by email and verify
        retrieved_agency = Agency.get_by_email(test_email)
        assert retrieved_agency is not None
        assert retrieved_agency.email == test_email
        assert retrieved_agency.id == test_id

        # cleanup
        retrieved_agency.delete()
    
    # tests updating agency data
    def test_agency_update(self):
        import os
        test_id = f'test_{os.urandom(4).hex()}'

        agency = Agency(
            id=test_id,
            name='Original Name',
            email=f'{test_id}@example.com',
            phone='+1234567890'
        )

        # save to firestore
        agency.save()

        # update the agency
        update_data = {'name': 'Updated Name', 'phone': '+9999999999'}
        success = agency.update(update_data)
        assert success == True

        # verify the update worked
        retrieved_agency = Agency.get_by_id(test_id)
        assert retrieved_agency.name == 'Updated Name'
        assert retrieved_agency.phone == '+9999999999'

        # cleanup
        retrieved_agency.delete()

    # tests deleting an agency
    def test_agency_delete(self):
        import os
        test_id = f'test_{os.urandom(4).hex()}'

        agency = Agency(
            id=test_id,
            name='Delete Test',
            email=f'{test_id}@example.com',
            phone='+1234567890'
        )

        # save to firestore
        agency.save()

        # verify it exists
        retrieved = Agency.get_by_id(test_id)
        assert retrieved is not None

        # delete and verify it's gone
        success = agency.delete()
        assert success == True

        retrieved = Agency.get_by_id(test_id)
        assert retrieved is None