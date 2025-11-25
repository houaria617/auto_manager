# Car Rental System Database Schema

## 1. Client
- **ID** (Primary Key)
- **Full Name** (String)
- **Phone** (String)
- **Relation**: One Client has many Rentals.

## 2. Agencies
- **ID** (Primary Key)
- **Name** (String)
- **Password** (String)
- **Join Date** (Date)
- **Relation**: One Agency has many Rentals.

## 3. Car
- **ID** (Primary Key)
- **Name** (String)
- **Plate** (Integer)
- **Rent Price** (Float)
- **State** (String)
- **Maintenance Date** (Date)
- **Return From Maintenance** (Date)
- **Relation**: One Car can be associated with many Rentals.

## 4. Rental (Junction/Transaction Table)
- **ID** (Primary Key)
- **Client ID** (Foreign Key referencing Client)
- **Car ID** (Foreign Key referencing Car)
- **Agency ID** (Foreign Key referencing Agencies)
- **Date From** (Date)
- **Date To** (Date)
- **Total Amount** (Float)
- **Payment State** (String)
- **State** (String)

## 5. Payment
- **ID** (Primary Key)
- **Rental ID** (Foreign Key referencing Rental)
- **Date** (Date)
- **Paid Amount** (Float)
- **Relation**: One Rental can have multiple Payments.
