import '../../../databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import '../../../cubit/rental_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddRentalScreen extends StatefulWidget {
  const AddRentalScreen({super.key});

  @override
  State<AddRentalScreen> createState() => _AddRentalScreenState();
}

class _AddRentalScreenState extends State<AddRentalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clientRepo = AbstractClientRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();

  final _priceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  // FIXED: Explicitly typed lists
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _cars = [];

  int? _selectedClientId;
  int? _selectedCarId;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rawClients = await _clientRepo.getAllClients();
      final rawCars = await _carRepo.getAllCars();

      if (mounted) {
        setState(() {
          print('### MOUNTED: $mounted');
          // FIXED: Safely cast the database results
          _clients = List<Map<String, dynamic>>.from(rawClients);
          _cars = List<Map<String, dynamic>>.from(rawCars);
          _isLoading = false;
          print('### Current _clients: $_clients');
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddClientDialog() async {
    final fullNameController = TextEditingController();
    // final lastNameController = TextEditingController();
    final phoneController =
        TextEditingController(); // CHANGED: Was emailController
    final formKeyClient = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Client'),
        content: Form(
          key: formKeyClient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              // TextFormField(
              //   controller: lastNameController,
              //   decoration: const InputDecoration(labelText: 'Last Name'),
              //   validator: (v) => v!.isEmpty ? 'Required' : null,
              // ),
              // CHANGED: Email Input -> Phone Input
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
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
            onPressed: () async {
              if (formKeyClient.currentState!.validate()) {
                // CHANGED: Map key is now 'phone'
                final newClient = {
                  'full_name': fullNameController.text,
                  //'last_name': lastNameController.text,
                  'phone': phoneController.text,
                };

                // 1. Insert into DB
                // this already return the created client id
                final clientID = await _clientRepo.insertClient(newClient);
                print('&&&& inside _showAddClientDialog, id: $clientID');

                // 2. Reload Data
                await _loadData();

                // 3. Auto-select (Find highest ID)
                if (_clients.isNotEmpty) {
                  final newest = _clients.reduce((curr, next) {
                    final currId = curr['id'] as int;
                    final nextId = next['id'] as int;
                    return currId > nextId ? curr : next;
                  });

                  setState(() {
                    print('inside set state');
                    _selectedClientId = newest['id'] as int;
                  });
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCarDialog() async {
    final nameController = TextEditingController();
    final plateController = TextEditingController();
    final priceController = TextEditingController();
    final formKeyCar = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Car'),
        content: Form(
          key: formKeyCar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Car Name (Model)',
                ),
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
            onPressed: () async {
              if (formKeyCar.currentState!.validate()) {
                final newCar = {
                  'name': nameController.text,
                  'plate': plateController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'state': 'Available',
                  'maintenance': '',
                  'return_from_maintenance': '',
                };

                await _carRepo.insertCar(newCar);
                await _loadData();

                // FIXED: Type-safe reduce
                if (_cars.isNotEmpty) {
                  final newest = _cars.reduce((curr, next) {
                    final currId = curr['id'] as int;
                    final nextId = next['id'] as int;
                    return currId > nextId ? curr : next;
                  });

                  setState(() {
                    _selectedCarId = newest['id'] as int;
                    _calculateTotalPrice();
                  });
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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

      if (car.isNotEmpty && car['price'] != null) {
        final days = _endDate!.difference(_startDate!).inDays;
        final billableDays = days == 0 ? 1 : days;

        final dailyPrice = (car['price'] is int)
            ? (car['price'] as int).toDouble()
            : (car['price'] as double);

        final total = dailyPrice * billableDays;
        _priceController.text = total.toStringAsFixed(2);
      }
    }
  }

  void _saveRental() {
    print('1. Save rental clicked');
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        print('2. Form validation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }
      print('3. Form validation passed');
      if (_dateError != null) return;

      final newRental = {
        'client_id': _selectedClientId,
        'car_id': _selectedCarId,
        'date_from': _startDate!.toIso8601String(),
        'date_to': _endDate!.toIso8601String(),
        'total_amount': double.parse(_priceController.text),
        'payment_state': 'unpaid',
        'state': 'ongoing',
      };
      print('4. Calling addRental');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CLIENT DROPDOWN
                      _buildLabel('Client'),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedClientId,
                              hint: const Text("Select Client"),
                              decoration: _inputDecoration(
                                Icons.person_outline,
                              ),
                              items: _clients.map((client) {
                                final name = "${client['full_name']}";
                                return DropdownMenuItem<int>(
                                  value: client['id'] as int,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedClientId = value),
                              validator: (value) => value == null
                                  ? 'Please select a client'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildAddButton(_showAddClientDialog),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // CAR DROPDOWN
                      _buildLabel('Car'),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedCarId,
                              hint: const Text("Select Car"),
                              decoration: _inputDecoration(
                                Icons.directions_car,
                              ),
                              items: _cars.map((car) {
                                // Matches new schema: name, plate, price
                                final name = car['name'] ?? 'Unknown';
                                final plate = car['plate'] ?? '';
                                return DropdownMenuItem<int>(
                                  value: car['id'] as int,
                                  child: Text(
                                    "$name ($plate)",
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

                      // DATES
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
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // PRICE
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // BUTTONS
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
                              onPressed: _saveRental,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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

// ######## FIRST FILE ENDS #########

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../cubit/rental_cubit.dart';

// class AddRentalScreen extends StatefulWidget {
//   const AddRentalScreen({super.key});

//   @override
//   State<AddRentalScreen> createState() => _AddRentalScreenState();
// }

// class _AddRentalScreenState extends State<AddRentalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _clientNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _carModelController = TextEditingController();
//   final _priceController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//   String? _dateError;

//   @override
//   void dispose() {
//     _clientNameController.dispose();
//     _carModelController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2026),
//     );
//     if (picked != null && mounted) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//           // Clear end date if it's before the new start date
//           if (_endDate != null && _endDate!.isBefore(_startDate!)) {
//             _endDate = null;
//           }
//         } else {
//           _endDate = picked;
//         }
//         _dateError = null; // Clear error when dates are selected
//         _validateDates();
//       });
//     }
//   }

//   void _validateDates() {
//     if (_startDate != null && _endDate != null) {
//       if (_endDate!.isBefore(_startDate!)) {
//         setState(() {
//           _dateError = 'End date must be after or equal to start date';
//         });
//       } else {
//         setState(() {
//           _dateError = null;
//         });
//       }
//     }
//   }

//   void _saveRental() {
//     print('1. Save rental clicked');
//     if (!_formKey.currentState!.validate()) {
//       print('2. Form validation failed');
//       return; // Form invalid, stop here
//     }
//     print('3. Form validation passed');

//     if (_startDate == null || _endDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select start and end dates')),
//       );
//       return;
//     }

//     if (_dateError != null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(_dateError!)));
//       return;
//     }

//     // All validations passed
//     print('4. Calling addRental');
//     final newRental = {
//         'client_id': _selectedClientId,
//         'car_id': _selectedCarId,
//         'date_from': _startDate!.toIso8601String(),
//         'date_to': _endDate!.toIso8601String(),
//         'total_amount': double.parse(_priceController.text),
//         'payment_state': 'unpaid',
//         'state': 'ongoing',
//       };
//       print('4. Calling addRental');
//       context.read<RentalCubit>().addRental(newRental);
//     print('5. Navigator pop');
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'New Rental',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildLabel('Client Name'),
//                 TextFormField(
//                   controller: _clientNameController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter client name',
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     prefixIcon: const Icon(Icons.person_outline),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter client name';
//                     }
//                     if (value.trim().length < 2) {
//                       return 'Client name must be at least 2 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 _buildLabel('Client Phone'),
//                 TextFormField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter client\'s phone',
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     prefixIcon: const Icon(Icons.phone),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter client\s phone';
//                     }
//                     if (value.trim().length < 10) {
//                       return 'Client\'s phone must be at least 10 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 _buildLabel('Car Model'),
//                 TextFormField(
//                   controller: _carModelController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter car model',
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     prefixIcon: const Icon(Icons.directions_car),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter car model';
//                     }
//                     if (value.trim().length < 2) {
//                       return 'Car model must be at least 2 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildLabel('Start Date'),
//                           GestureDetector(
//                             onTap: () => _selectDate(context, true),
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color:
//                                       _dateError != null && _startDate == null
//                                       ? Colors.red
//                                       : Colors.transparent,
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     _startDate == null
//                                         ? 'Select Date'
//                                         : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
//                                     style: TextStyle(
//                                       color: _startDate == null
//                                           ? Colors.grey[600]
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                   const Icon(Icons.calendar_today, size: 20),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildLabel('End Date'),
//                           GestureDetector(
//                             onTap: () => _selectDate(context, false),
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: _dateError != null
//                                       ? Colors.red
//                                       : Colors.transparent,
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     _endDate == null
//                                         ? 'Select Date'
//                                         : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
//                                     style: TextStyle(
//                                       color: _endDate == null
//                                           ? Colors.grey[600]
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                   const Icon(Icons.calendar_today, size: 20),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_dateError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8, left: 12),
//                     child: Text(
//                       _dateError!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 _buildLabel('Total Price'),
//                 TextFormField(
//                   controller: _priceController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Enter amount',
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     prefixIcon: const Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Text(
//                         '\$',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter price';
//                     }
//                     final price = double.tryParse(value);
//                     if (price == null) {
//                       return 'Please enter a valid number';
//                     }
//                     if (price <= 0) {
//                       return 'Price must be greater than 0';
//                     }
//                     if (price > 1000000) {
//                       return 'Price must be reasonable';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 40),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       flex: 2,
//                       child: ElevatedButton(
//                         onPressed: _saveRental,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Save Rental',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//     );
//   }
// }
