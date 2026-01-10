// vehicle_model.dart
class Vehicle {
  final int? id; // Local SQLite ID (auto-increment)
  final String? remoteId; // Firebase/Firestore Document ID
  final int pendingSync; // 1 = Dirty (needs push), 0 = Clean
  final String name; // Custom name given by user
  final String plate; // Plate number of the vehicle
  final String status; // "available", "rented", "maintenance"
  final double? price; // Rent price per day
  final String? returnDate; // Only used if status == "Rented" (Model field)
  final String nextMaintenanceDate; // Next maintenance date for all vehicles
  final String? availableFrom; // When a maintenance vehicle becomes available
  final String? description; // Optional vehicle notes or comments

  Vehicle({
    this.id,
    this.remoteId,
    this.pendingSync = 1, // Default to dirty (needs sync)
    required this.name,
    required this.plate,
    required this.status,
    this.price,
    this.returnDate,
    required this.nextMaintenanceDate,
    this.availableFrom,
    this.description,
  });

  // Factory constructor to create Vehicle from a database map (List<Map> from getData())
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      remoteId: map['remote_id']?.toString(),
      pendingSync: map['pending_sync'] as int? ?? 0,
      name: map['name']?.toString() ?? 'Unknown',
      plate: map['plate']?.toString() ?? '',
      // Mapping DB field 'state' to Model field 'status'
      status: map['state']?.toString() ?? 'available',
      price: (map['price'] as num?)?.toDouble(),
      // Mapping DB field 'maintenance' to Model field 'nextMaintenanceDate'
      nextMaintenanceDate: map['maintenance']?.toString() ?? '',
      // Mapping DB field 'return_from_maintenance' to Model field 'availableFrom'
      availableFrom: map['return_from_maintenance']?.toString(),
      // These model fields are not stored in the cars table in your schema
      returnDate: map['returnDate']?.toString(),
      description: map['description']?.toString(),
    );
  }

  // Method to convert Vehicle Model back to DB format (Map<String, dynamic>)
  Map<String, dynamic> toMap() {
    return {
      // Include 'id' only if present for use in update operations
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      'pending_sync': pendingSync,
      'name': name,
      'plate': plate,
      'state': status, // Mapping Model 'status' back to DB 'state'
      'price': price ?? 0.0,
      'maintenance': nextMaintenanceDate,
      'return_from_maintenance': availableFrom,
    };
  }

  // For sending to Backend API (Exclude local_id, include remote_id as 'id')
  Map<String, dynamic> toJson() {
    return {
      if (remoteId != null) 'id': remoteId, // Send ID if updating
      'name': name,
      'plate': plate,
      'rent_price': price ?? 0.0,
      'state': status,
      'maintenance_date': nextMaintenanceDate,
      'return_from_maintenance': availableFrom,
    };
  }

  // Create a copy with updated fields (useful for immutable state updates)
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
