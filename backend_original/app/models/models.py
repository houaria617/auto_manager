from dataclasses import dataclass, asdict
from datetime import date
from typing import Optional
import bcrypt

@dataclass
class Client:
    full_name: str
    phone: str
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)

@dataclass
class Car:
    agency_id: int
    name: str
    plate: str
    rent_price: float
    state: str
    maintenance_date: Optional[date] = None
    return_from_maintenance: Optional[date] = None
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)

@dataclass
class Agency:
    name: str
    password: str
    email: str
    join_date: date
    phone: str
    id: Optional[int] = None

    def to_dict(self):
        """Convert to dict, excluding password"""
        data = asdict(self)
        # Don't include password in dict representation
        if 'password' in data:
            del data['password']
        return data
    
    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a password for storing"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    @staticmethod
    def verify_password(stored_password: str, provided_password: str) -> bool:
        """Verify a stored password against one provided by user"""
        return bcrypt.checkpw(provided_password.encode('utf-8'), stored_password.encode('utf-8'))

@dataclass
class Rental:
    client_id: int
    car_id: int
    agency_id: int
    date_from: date
    date_to: date
    total_amount: float
    payment_state: str
    rental_state: str
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)

@dataclass
class Payment:
    rental_id: int
    payment_date: date
    paid_amount: float
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)
    
@dataclass
class RecentActivity:
    description: str
    activity_date: date
    id: Optional[int] = None
# notifications 
@dataclass
class FCMToken:
    user_id: int  # This is your agency_id
    token: str
    id: Optional[str] = None  # Firestore document ID
    
    def to_dict(self):
        return asdict(self)