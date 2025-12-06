// lib/features/rentals/presentation/screens/add_rental_screen.dart

import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddRentalScreen extends StatelessWidget {
  const AddRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentalCubit(),
      child: const _AddRentalScreenContent(),
    );
  }
}

class _AddRentalScreenContent extends StatefulWidget {
  const _AddRentalScreenContent();

  @override
  State<_AddRentalScreenContent> createState() =>
      _AddRentalScreenContentState();
}

class _AddRentalScreenContentState extends State<_AddRentalScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _carModelController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  // For demo purposes - In real app, these would come from dropdowns
  // that fetch from clients and cars tables
  int _selectedClientId = 1;
  int _selectedCarId = 1;

  @override
  void dispose() {
    _clientNameController.dispose();
    _carModelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _dateError = null;
        _validateDates();
      });
    }
  }

  void _validateDates() {
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        setState(() {
          _dateError = 'End date must be after or equal to start date';
        });
      } else {
        setState(() {
          _dateError = null;
        });
      }
    }
  }

  void _saveRental(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }

      if (_dateError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_dateError!)));
        return;
      }

      // Create rental model
      final rental = RentalModel(
        clientId: _selectedClientId,
        carId: _selectedCarId,
        dateFrom: _startDate!.toIso8601String(),
        dateTo: _endDate!.toIso8601String(),
        totalAmount: double.parse(_priceController.text),
        paymentState: 'unpaid',
        state: 'ongoing',
      );

      // Save rental using cubit
      context.read<RentalCubit>().createRental(rental);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentalCubit, RentalState>(
      listener: (context, state) {
        if (state is RentalOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
        if (state is RentalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'New Rental',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<RentalCubit, RentalState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Client Name'),
                          TextFormField(
                            controller: _clientNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter client name',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter client name';
                              }
                              if (value.trim().length < 2) {
                                return 'Client name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Car Model'),
                          TextFormField(
                            controller: _carModelController,
                            decoration: InputDecoration(
                              hintText: 'Enter car model',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.directions_car),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car model';
                              }
                              if (value.trim().length < 2) {
                                return 'Car model must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Start Date'),
                                    GestureDetector(
                                      onTap: () => _selectDate(context, true),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                _dateError != null &&
                                                    _startDate == null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _startDate == null
                                                  ? 'Select Date'
                                                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                              style: TextStyle(
                                                color: _startDate == null
                                                    ? Colors.grey[600]
                                                    : Colors.black,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('End Date'),
                                    GestureDetector(
                                      onTap: () => _selectDate(context, false),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _dateError != null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _endDate == null
                                                  ? 'Select Date'
                                                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                              style: TextStyle(
                                                color: _endDate == null
                                                    ? Colors.grey[600]
                                                    : Colors.black,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_dateError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                _dateError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _buildLabel('Total Price'),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              final price = double.tryParse(value);
                              if (price == null) {
                                return 'Please enter a valid number';
                              }
                              if (price <= 0) {
                                return 'Price must be greater than 0';
                              }
                              if (price > 1000000) {
                                return 'Price must be reasonable';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: state is RentalLoading
                                      ? null
                                      : () => _saveRental(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: state is RentalLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Save Rental',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is RentalLoading)
                  Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
