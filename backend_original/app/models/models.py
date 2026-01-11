from dataclasses import dataclass, asdict
from datetime import date
from typing import Optional
import bcrypt

# represents a customer in the system
@dataclass
class Client:
    full_name: str
    phone: str
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)

# car model used primarily for legacy or local references
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

# vehicle model for firestore storage with string ids
@dataclass
class Vehicle:
    agency_id: str
    name: str
    plate: str
    rent_price: float = 0.0
    state: str = 'available'
    maintenance_date: Optional[str] = None
    return_from_maintenance: Optional[str] = None
    id: Optional[str] = None

    # converts the vehicle to a dict for saving to firestore
    def to_dict(self):
        data = {
            'agency_id': self.agency_id,
            'name': self.name,
            'plate': self.plate,
            'rent_price': self.rent_price,
            'state': self.state,
        }
        if self.maintenance_date:
            data['maintenance_date'] = self.maintenance_date
        if self.return_from_maintenance:
            data['return_from_maintenance'] = self.return_from_maintenance
        return data

    # builds a vehicle object from a firestore document
    @classmethod
    def from_dict(cls, data: dict, doc_id: Optional[str] = None):
        return cls(
            id=doc_id,
            agency_id=data.get('agency_id', ''),
            name=data.get('name', ''),
            plate=data.get('plate', ''),
            rent_price=data.get('rent_price', 0.0),
            state=data.get('state', 'available'),
            maintenance_date=data.get('maintenance_date'),
            return_from_maintenance=data.get('return_from_maintenance'),
        )

# represents a rental agency that owns vehicles
@dataclass
class Agency:
    name: str
    password: str
    email: str
    join_date: date
    phone: str
    id: Optional[int] = None

    # converts to dict but excludes the password for safety
    def to_dict(self):
        data = asdict(self)
        if 'password' in data:
            del data['password']
        return data
    
    # hashes a plaintext password using bcrypt
    @staticmethod
    def hash_password(password: str) -> str:
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    # checks if the provided password matches the stored hash
    @staticmethod
    def verify_password(stored_password: str, provided_password: str) -> bool:
        return bcrypt.checkpw(provided_password.encode('utf-8'), stored_password.encode('utf-8'))

# represents a rental contract linking client to car
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

# tracks individual payments made towards a rental
@dataclass
class Payment:
    rental_id: int
    payment_date: date
    paid_amount: float
    id: Optional[int] = None

    def to_dict(self):
        return asdict(self)

# logs recent actions in the system for the dashboard
@dataclass
class RecentActivity:
    description: str
    activity_date: date
    id: Optional[int] = None

# stores fcm tokens for push notifications
@dataclass
class FCMToken:
    user_id: int  # This is your agency_id
    token: str
    id: Optional[str] = None  # Firestore document ID
    
    def to_dict(self):
        return asdict(self)