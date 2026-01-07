// vehicle_model.dart
class Vehicle {
  final dynamic
  id; // Changed from int? to dynamic to support String IDs from Backend
  final String name; // Custom name given by user
  final String plate; // Plate number of the vehicle
  final String status; // "Available", "Rented", "Maintenance"
  final String? returnDate; // Only used if status == "Rented" (Model field)
  final String nextMaintenanceDate; // Next maintenance date for all vehicles
  final String? availableFrom; // When a maintenance vehicle becomes available
  final String? description; // Optional vehicle notes or comments

  Vehicle({
    this.id,
    required this.name,
    required this.plate,
    required this.status,
    this.returnDate,
    required this.nextMaintenanceDate,
    this.availableFrom,
    this.description,
  });

  //NEW: Factory constructor to create Vehicle from a database map (List<Map> from getData())
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name']?.toString() ?? 'Unknown',
      plate: map['plate']?.toString() ?? '',
      // Mapping DB field 'state' to Model field 'status'
      status: map['state']?.toString() ?? 'available',
      // Mapping DB field 'maintenance' to Model field 'nextMaintenanceDate'
      nextMaintenanceDate: map['maintenance']?.toString() ?? '',
      // Mapping DB field 'return_from_maintenance' to Model field 'availableFrom'
      availableFrom: map['return_from_maintenance']?.toString(),

      // These model fields are not stored in the cars table in your schema,
      // so they are set to null if not present in the map.
      returnDate: map['returnDate']?.toString(),
      description: map['description']?.toString(),
    );
  }

  //NEW: Method to convert Vehicle Model back to DB format (Map<String, dynamic>)
  Map<String, dynamic> toMap() {
    return {
      // Include 'id' only if present for use in update operations
      if (id != null) 'id': id,
      'name': name,
      'plate': plate,
      'state': status, // Mapping Model 'status' back to DB 'state'
      'maintenance': nextMaintenanceDate,
      'price': 0.0, // Assuming price is defaulted if not present in the model
      'return_from_maintenance': availableFrom,
      // Note: DB schema does not store returnDate or description in the 'cars' table.
    };
  }
}
