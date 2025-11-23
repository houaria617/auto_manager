CREATE TABLE car (
    id SERIAL,
    name VARCHAR(40),
    plate VARCHAR(30) UNIQUE NOT NULL,
	rent_price NUMERIC(30,2),
	state VARCHAR(20) NOT NULL,
	maintenance_date date,
	return_from_maintenance date,
	CONSTRAINT pk_car_id PRIMARY KEY (id),
);

CREATE TABLE agency (
    id SERIAL,
	join_date date NOT NULL,
	name VARCHAR(20) NOT NULL,
	password VARCHAR NOT NULL, -- Will be encrypted
	CONSTRAINT pk_agency_id PRIMARY KEY (id)
);

CREATE TABLE client (
    id SERIAL,
	first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
	phone VARCHAR(12) NOT NULL,
	CONSTRAINT pk_client_id PRIMARY KEY (id),
);

CREATE TABLE rental (
    id SERIAL,
    client_id INT NOT NULL,
    car_id INT NOT NULL, 
	agency_id INT NOT NULL,
	date_from date NOT NULL,
	date_to date NOT NULL,
	total_amount NUMERIC(30,2) NOT NULL,
	rental_state VARCHAR(20) NOT NULL,
	payment_state VARCHAR(20) NOT NULL,
	CONSTRAINT pk_rental_id PRIMARY KEY (id),
	CONSTRAINT fk_client_id_in_rental 
	FOREIGN KEY (client_id)
	REFERENCES client(id),
	CONSTRAINT fk_car_id_in_rental 
	FOREIGN KEY (car_id)
	REFERENCES car(id),
	CONSTRAINT fk_agency_id_in_rental 
	FOREIGN KEY (agency_id)
	REFERENCES agency(id)
);

CREATE TABLE payment (
    id SERIAL,
    rental_id INT NOT NULL,
	payment_date date NOT NULL,
	amount NUMERIC(20, 2) NOT NULL,
	CONSTRAINT pk_payment_id PRIMARY KEY (id),
	CONSTRAINT fk_rental_id_in_payment 
	FOREIGN KEY (rental_id)
	REFERENCES rental(id)
);