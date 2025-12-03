class DBBaseTable {
  static const sqlCode = '''
    CREATE TABLE clients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      phone TEXT NOT NULL,
      state TEXT NOT NULL
    );
    
    CREATE TABLE cars (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      plate TEXT NOT NULL UNIQUE,
      rent_price REAL NOT NULL,
      state TEXT NOT NULL,
      maintenance_date TEXT,
      return_from_maintenance TEXT
    );
    
    CREATE TABLE rentals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER NOT NULL,
      car_id INTEGER NOT NULL,
      date_from TEXT NOT NULL,
      date_to TEXT NOT NULL,
      total_amount REAL NOT NULL,
      payment_state TEXT NOT NULL,
      state TEXT NOT NULL,
      FOREIGN KEY (client_id) REFERENCES clients (id),
      FOREIGN KEY (car_id) REFERENCES cars (id)
    );
    
    CREATE TABLE payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      rental_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      paid_amount REAL NOT NULL,
      FOREIGN KEY (rental_id) REFERENCES rentals (id)
    );
  ''';
}
