abstract class AbstractPaymentRepo {
  Future<List<Map<String, dynamic>>> getData();
  Future<void> insertData(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getPaymentsForRental(
    int rentalId,
  ); // ensure int
  Future<double> getTotalPaid(int rentalId);
  Future<bool> addPayment(Map<String, dynamic> payment);
}
