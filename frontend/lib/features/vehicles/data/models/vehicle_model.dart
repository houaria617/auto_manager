class Vehicle {
  // these are the core properties that define a vehicle in our system
  final int? id;
  final String? remoteId;
  final int pendingSync;
  final String name;
  final String plate;
  final String status;
  final double? price;
  final String? returnDate;
  final String nextMaintenanceDate;
  final String? availableFrom;
  final String? description;

  Vehicle({
    this.id,
    this.remoteId,
    this.pendingSync = 1,
    required this.name,
    required this.plate,
    required this.status,
    this.price,
    this.returnDate,
    required this.nextMaintenanceDate,
    this.availableFrom,
    this.description,
  });

  // builds a vehicle object from a database row
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      remoteId: map['remote_id']?.toString(),
      pendingSync: map['pending_sync'] as int? ?? 0,
      name: map['name']?.toString() ?? 'Unknown',
      plate: map['plate']?.toString() ?? '',
      status: map['state']?.toString() ?? 'available',
      price: (map['price'] as num?)?.toDouble(),
      nextMaintenanceDate: map['maintenance']?.toString() ?? '',
      availableFrom: map['return_from_maintenance']?.toString(),
      returnDate: map['returnDate']?.toString(),
      description: map['description']?.toString(),
    );
  }

  // converts this vehicle into a map for sqlite storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      'pending_sync': pendingSync,
      'name': name,
      'plate': plate,
      'state': status,
      'price': price ?? 0.0,
      'maintenance': nextMaintenanceDate,
      'return_from_maintenance': availableFrom,
    };
  }

  // converts this vehicle into json format for the backend api
  Map<String, dynamic> toJson() {
    return {
      if (remoteId != null) 'id': remoteId,
      'name': name,
      'plate': plate,
      'rent_price': price ?? 0.0,
      'state': status,
      'maintenance_date': nextMaintenanceDate,
      'return_from_maintenance': availableFrom,
    };
  }

  // creates a new vehicle with some fields changed, keeps the rest the same
  Vehicle copyWith({
    int? id,
    String? remoteId,
    int? pendingSync,
    String? name,
    String? plate,
    String? status,
    double? price,
    String? returnDate,
    String? nextMaintenanceDate,
    String? availableFrom,
    String? description,
  }) {
    return Vehicle(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      pendingSync: pendingSync ?? this.pendingSync,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      status: status ?? this.status,
      price: price ?? this.price,
      returnDate: returnDate ?? this.returnDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      availableFrom: availableFrom ?? this.availableFrom,
      description: description ?? this.description,
    );
  }
}
