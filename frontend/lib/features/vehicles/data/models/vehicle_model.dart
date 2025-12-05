class Vehicle {
  final String name; // Custom name given by user
  final String plate; // Plate number of the vehicle
  final String status; // "Available", "Rented", "Maintenance"
  final String? returnDate; // Only used if status == "Rented"
  final String nextMaintenanceDate; // Next maintenance date for all vehicles
  final String? availableFrom; // When a maintenance vehicle becomes available
  final String? description; // Optional vehicle notes or comments

  Vehicle({
    required this.name,
    required this.plate,
    required this.status,
    this.returnDate,
    required this.nextMaintenanceDate,
    this.availableFrom,
    this.description,
  });
}
