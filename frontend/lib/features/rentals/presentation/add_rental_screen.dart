import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';

class AddRentalScreen extends StatefulWidget {
  const AddRentalScreen({super.key});

  @override
  State<AddRentalScreen> createState() => _AddRentalScreenState();
}

class _AddRentalScreenState extends State<AddRentalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _priceController = TextEditingController();

  // State Variables
  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  // --- MOCK DATA LISTS ---
  // We initialize these with some dummy data so the dropdowns aren't empty.
  List<Map<String, dynamic>> _clients = [
    {'id': 101, 'full_name': 'John Doe', 'phone': '123-456-7890'},
    {'id': 102, 'full_name': 'Jane Smith', 'phone': '987-654-3210'},
    {'id': 103, 'full_name': 'Alice Johnson', 'phone': '555-555-5555'},
  ];

  List<Map<String, dynamic>> _cars = [
    {
      'id': 201,
      'name_model': 'Toyota Camry',
      'plate_matricule': '123-ABC',
      'rent_price': 50.0,
    },
    {
      'id': 202,
      'name_model': 'Honda Civic',
      'plate_matricule': '456-DEF',
      'rent_price': 40.0,
    },
    {
      'id': 203,
      'name_model': 'Ford Mustang',
      'plate_matricule': '789-GHI',
      'rent_price': 85.0,
    },
  ];

  // Selections
  int? _selectedClientId;
  int? _selectedCarId;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // --- Add New Client (Local Mock) ---
  Future<void> _showAddClientDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKeyClient = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Mock Client'),
        content: Form(
          key: formKeyClient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKeyClient.currentState!.validate()) {
                // Generate a random-ish ID
                final newId = _clients.last['id'] + 1;

                final newClient = {
                  'id': newId,
                  'full_name': nameController.text,
                  'phone': phoneController.text,
                };

                setState(() {
                  _clients.add(newClient);
                  _selectedClientId = newId; // Auto-select
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add Local'),
          ),
        ],
      ),
    );
  }

  // --- Add New Car (Local Mock) ---
  Future<void> _showAddCarDialog() async {
    final modelController = TextEditingController();
    final plateController = TextEditingController();
    final priceController = TextEditingController();
    final formKeyCar = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Mock Car'),
        content: Form(
          key: formKeyCar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Daily Rent Price',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKeyCar.currentState!.validate()) {
                final newId = _cars.last['id'] + 1;

                final newCar = {
                  'id': newId,
                  'name_model': modelController.text,
                  'plate_matricule': plateController.text,
                  'rent_price': double.tryParse(priceController.text) ?? 0.0,
                };

                setState(() {
                  _cars.add(newCar);
                  _selectedCarId = newId; // Auto-select
                  _calculateTotalPrice(); // Auto-calculate
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add Local'),
          ),
        ],
      ),
    );
  }

  // --- Date Logic ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        _calculateTotalPrice();
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

  void _calculateTotalPrice() {
    if (_selectedCarId != null &&
        _startDate != null &&
        _endDate != null &&
        _dateError == null) {
      final car = _cars.firstWhere(
        (element) => element['id'] == _selectedCarId,
        orElse: () => {},
      );
      if (car.isNotEmpty && car['rent_price'] != null) {
        final days = _endDate!.difference(_startDate!).inDays;
        final billableDays = days == 0 ? 1 : days;
        final dailyPrice = (car['rent_price'] is int)
            ? (car['rent_price'] as int).toDouble()
            : car['rent_price'];
        final total = dailyPrice * billableDays;
        _priceController.text = total.toStringAsFixed(2);
      }
    }
  }

  // --- Save Rental (This still saves to Real Rental DB) ---
  void _saveRental() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }
      if (_dateError != null) return;

      // NOTE: We are saving the Mock IDs (101, 201, etc.) into the real Rental Database.
      // This is fine for testing Rental CRUD.
      final newRental = {
        'client_id': _selectedClientId,
        'car_id': _selectedCarId,
        'date_from': _startDate!.toIso8601String(),
        'date_to': _endDate!.toIso8601String(),
        'total_amount': double.parse(_priceController.text),
        'payment_state': 'Unpaid',
        'state': 'Ongoing',
      };

      context.read<RentalCubit>().addRental(newRental);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CLIENT DROPDOWN ---
                _buildLabel('Client'),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedClientId,
                        hint: const Text("Select Client"),
                        decoration: _inputDecoration(Icons.person_outline),
                        items: _clients.map((client) {
                          return DropdownMenuItem<int>(
                            value: client['id'],
                            child: Text(
                              client['full_name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedClientId = value),
                        validator: (value) =>
                            value == null ? 'Please select a client' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildAddButton(_showAddClientDialog),
                  ],
                ),

                const SizedBox(height: 20),

                // --- CAR DROPDOWN ---
                _buildLabel('Car'),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCarId,
                        hint: const Text("Select Car"),
                        decoration: _inputDecoration(Icons.directions_car),
                        items: _cars.map((car) {
                          final model = car['name_model'];
                          final plate = car['plate_matricule'];
                          final price = car['rent_price'];
                          return DropdownMenuItem<int>(
                            value: car['id'],
                            child: Text(
                              "$model ($plate) - \$$price/day",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCarId = value;
                            _calculateTotalPrice();
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a car' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildAddButton(_showAddCarDialog),
                  ],
                ),

                const SizedBox(height: 20),

                // --- DATES ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date'),
                          _buildDateSelector(true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Date'),
                          _buildDateSelector(false),
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
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 20),

                // --- PRICE ---
                _buildLabel('Total Price'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(null).copyWith(
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
                    if (value == null || value.isEmpty)
                      return 'Please enter price';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // --- BUTTONS ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                        onPressed: _saveRental,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
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
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData? icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateSelector(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final isError = _dateError != null && isStart && _startDate == null;

    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isError || (_dateError != null && !isStart))
                ? Colors.red
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null
                  ? 'Select Date'
                  : '${date.day}/${date.month}/${date.year}',
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
