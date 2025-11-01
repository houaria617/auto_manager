// lib/features/rentals/data/models/rental.dart

class Rental {
  final String id;
  final String customerName;
  final String vehicleModel;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final RentalStatus status;

  Rental({
    required this.id,
    required this.customerName,
    required this.vehicleModel,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.status,
  });

  int get daysLeft {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isOngoing =>
      status == RentalStatus.active || status == RentalStatus.unpaid;
  bool get isCompleted => status == RentalStatus.returned;
}

enum RentalStatus { active, unpaid, returned }

extension RentalStatusExtension on RentalStatus {
  String get displayName {
    switch (this) {
      case RentalStatus.active:
        return 'Paid';
      case RentalStatus.unpaid:
        return 'Unpaid';
      case RentalStatus.returned:
        return 'Returned';
    }
  }
}
