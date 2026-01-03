from dataclasses import dataclass, asdict
from datetime import date
from typing import Optional

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
        return asdict(self)

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
    
# from app import db

# class Client(db.Model):
#     __tablename__ = 'client'
#     id = db.Column(db.Integer, primary_key=True)
#     full_name = db.Column(db.String(40), nullable=False)
#     phone = db.Column(db.String(20), nullable=False)
#     # rentals = db.relationship('Rental', backref='client', lazy=True)

# class Car(db.Model):
#     __tablename__ = 'car'
#     id = db.Column(db.Integer, primary_key=True)
#     agency_id = db.Column(db.Integer, db.ForeignKey('agency.id', ondelete='CASCADE'), nullable=False, index=True)
#     name = db.Column(db.String(40))
#     plate = db.Column(db.String(30), unique=True, nullable=False)
#     rent_price = db.Column(db.Numeric(30, 2))
#     state = db.Column(db.String(20), nullable=False)
#     maintenance_date = db.Column(db.Date)
#     return_from_maintenance = db.Column(db.Date)
#     # rentals = db.relationship('Rental', backref='car', lazy=True)

# class Agency(db.Model):
#     __tablename__ = 'agency'
#     id = db.Column(db.Integer, primary_key=True)
#     name = db.Column(db.String(20), nullable=False)
#     password = db.Column(db.String, nullable=False)
#     email = db.Column(db.email, nullable=False)
#     join_date = db.Column(db.Date, nullable=False)
#     phone = db.Column(db.String(15), nullable=False)
#     # rentals = db.relationship('Rental', backref='agency', lazy=True)

# class Rental(db.Model):
#     __tablename__ = 'rental'
#     id = db.Column(db.Integer, primary_key=True)
#     client_id = db.Column(db.Integer, db.ForeignKey('client.id', ondelete='CASCADE'), nullable=False, index=True)
#     car_id = db.Column(db.Integer, db.ForeignKey('car.id', ondelete='CASCADE'), nullable=False, index=True)
#     agency_id = db.Column(db.Integer, db.ForeignKey('agency.id', ondelete='CASCADE'), nullable=False, index=True)
#     date_from = db.Column(db.Date, nullable=False)
#     date_to = db.Column(db.Date, nullable=False)
#     total_amount = db.Column(db.Numeric(30, 2), nullable=False)
#     payment_state = db.Column(db.String(20), nullable=False)
#     rental_state = db.Column(db.String(20), nullable=False)
#     # payments = db.relationship('Payment', backref='rental', lazy=True)

# class Payment(db.Model):
#     __tablename__ = 'payment'
#     id = db.Column(db.Integer, primary_key=True)
#     rental_id = db.Column(db.Integer, db.ForeignKey('rental.id', ondelete='CASCADE'), nullable=False, index=True)
#     payment_date = db.Column(db.Date, nullable=False)
#     paid_amount = db.Column(db.Numeric(20, 2), nullable=False)