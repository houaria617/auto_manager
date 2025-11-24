from app import db

class Client(db.Model):
    __tablename__ = 'client'
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(20), nullable=False)
    last_name = db.Column(db.String(20), nullable=False)
    phone = db.Column(db.String(12), nullable=False)
    rentals = db.relationship('Rental', backref='client', lazy=True)

class Car(db.Model):
    __tablename__ = 'car'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(40))
    plate = db.Column(db.String(30), unique=True, nullable=False)
    rent_price = db.Column(db.Numeric(30, 2))
    state = db.Column(db.String(20), nullable=False)
    maintenance_date = db.Column(db.Date)
    return_from_maintenance = db.Column(db.Date)
    rentals = db.relationship('Rental', backref='car', lazy=True)

class Agency(db.Model):
    __tablename__ = 'agency'
    id = db.Column(db.Integer, primary_key=True)
    join_date = db.Column(db.Date, nullable=False)
    name = db.Column(db.String(20), nullable=False)
    password = db.Column(db.String, nullable=False)
    rentals = db.relationship('Rental', backref='agency', lazy=True)

class Rental(db.Model):
    __tablename__ = 'rental'
    id = db.Column(db.Integer, primary_key=True)
    client_id = db.Column(db.Integer, db.ForeignKey('client.id'), nullable=False)
    car_id = db.Column(db.Integer, db.ForeignKey('car.id'), nullable=False)
    agency_id = db.Column(db.Integer, db.ForeignKey('agency.id'), nullable=False)
    date_from = db.Column(db.Date, nullable=False)
    date_to = db.Column(db.Date, nullable=False)
    total_amount = db.Column(db.Numeric(30, 2), nullable=False)
    rental_state = db.Column(db.String(20), nullable=False)
    payment_state = db.Column(db.String(20), nullable=False)
    payments = db.relationship('Payment', backref='rental', lazy=True)

class Payment(db.Model):
    __tablename__ = 'payment'
    id = db.Column(db.Integer, primary_key=True)
    rental_id = db.Column(db.Integer, db.ForeignKey('rental.id'), nullable=False)
    payment_date = db.Column(db.Date, nullable=False)
    amount = db.Column(db.Numeric(20, 2), nullable=False)