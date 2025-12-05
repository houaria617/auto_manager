// lib/features/payments/presentation/payments_screen.dart

import 'package:auto_manager/logic/cubits/payment/payment_cubit.dart';
import 'package:auto_manager/logic/cubits/payment/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatelessWidget {
  final int rentalId;
  final double totalAmount;

  const PaymentsScreen({
    super.key,
    required this.rentalId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..loadPayments(rentalId, totalAmount),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Payments', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PaymentError) {
              return Center(child: Text(state.message));
            } else if (state is PaymentLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentLoaded state) {
    double progress = totalAmount > 0 ? state.totalPaid / totalAmount : 0.0;
    if (progress > 1.0) progress = 1.0;

    return Column(
      children: [
        // SUMMARY CARD
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.grey[50],
          child: Column(
            children: [
              Text(
                "Remaining Balance",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "\$${state.remainingAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: state.remainingAmount <= 0 ? Colors.green : Colors.blue,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Paid: \$${state.totalPaid.toStringAsFixed(2)}"),
                  Text("Total: \$${totalAmount.toStringAsFixed(2)}"),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // HISTORY LIST
        Expanded(
          child: state.payments.isEmpty
              ? const Center(child: Text("No payments yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.payments.length,
                  itemBuilder: (context, index) {
                    final payment = state.payments[index];
                    final date = DateTime.parse(payment['date']);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      title: Text("Payment #${payment['id']}"),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy - HH:mm').format(date),
                      ),
                      trailing: Text(
                        "+\$${(payment['paid_amount'] as num).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ADD BUTTON
        if (state.remainingAmount > 0.1) // Only show if money is owed
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _showAddPaymentDialog(context, state.remainingAmount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Payment",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddPaymentDialog(BuildContext context, double maxAmount) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Amount"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "\$ ",
            hintText: "Max: ${maxAmount.toStringAsFixed(2)}",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                // Call Cubit
                context.read<PaymentCubit>().addPayment(
                  rentalId,
                  amount,
                  totalAmount,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Pay"),
          ),
        ],
      ),
    );
  }
}
