abstract class AbstractPaymentRepo {
  Future<List<Map<String, dynamic>>> getData();
  Future<void> insertData(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getPaymentsForRental(int rentalId);
  Future<double> getTotalPaid(int rentalId);
  Future<void> addPayment(Map<String, dynamic> payment);
}
