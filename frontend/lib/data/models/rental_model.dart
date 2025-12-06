class RentalModel {
  final int? id;
  final int clientId;
  final int carId;
  final String dateFrom;
  final String dateTo;
  final double totalAmount;
  final String paymentState; // 'paid', 'partially_paid', 'unpaid'
  final String state; // 'ongoing', 'completed', 'overdue'

  RentalModel({
    this.id,
    required this.clientId,
    required this.carId,
    required this.dateFrom,
    required this.dateTo,
    required this.totalAmount,
    required this.paymentState,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'car_id': carId,
      'date_from': dateFrom,
      'date_to': dateTo,
      'total_amount': totalAmount,
      'payment_state': paymentState,
      'state': state,
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map) {
    return RentalModel(
      id: map['id'] as int?,
      clientId: map['client_id'] as int,
      carId: map['car_id'] as int,
      dateFrom: map['date_from'] as String,
      dateTo: map['date_to'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentState: map['payment_state'] as String,
      state: map['state'] as String,
    );
  }

  RentalModel copyWith({
    int? id,
    int? clientId,
    int? carId,
    String? dateFrom,
    String? dateTo,
    double? totalAmount,
    String? paymentState,
    String? state,
  }) {
    return RentalModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      carId: carId ?? this.carId,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentState: paymentState ?? this.paymentState,
      state: state ?? this.state,
    );
  }
}
