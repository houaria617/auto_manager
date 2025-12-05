// vehicle_model.dart
class Vehicle {
  final int? id; // NEW: Database ID
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
      id: map['id'] as int?,
      name: map['name'] as String,
      plate: map['plate'] as String,
      // Mapping DB field 'state' to Model field 'status'
      status: map['state'] as String, 
      // Mapping DB field 'maintenance' to Model field 'nextMaintenanceDate'
      nextMaintenanceDate: map['maintenance'] as String,
      // Mapping DB field 'return_from_maintenance' to Model field 'availableFrom'
      availableFrom: map['return_from_maintenance'] as String?,
      
      // These model fields are not stored in the cars table in your schema, 
      // so they are set to null if not present in the map.
      returnDate: map['returnDate'] as String?, 
      description: map['description'] as String?,
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