import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
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
      final rawClients = await _clientRepo.getData();
      final rawCars = await _carRepo.getData();

      if (mounted) {
        setState(() {
          // FIXED: Safely cast the database results
          _clients = List<Map<String, dynamic>>.from(rawClients);
          _cars = List<Map<String, dynamic>>.from(rawCars);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddClientDialog() async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController =
        TextEditingController(); // CHANGED: Was emailController
    final formKeyClient = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewClient),
        content: Form(
          key: formKeyClient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.firstName),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lastName),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              // CHANGED: Email Input -> Phone Input
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneNumber),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKeyClient.currentState!.validate()) {
                // CHANGED: Map key is now 'phone'
                final newClient = {
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'phone': phoneController.text,
                };

                // 1. Insert into DB
                await _clientRepo.insertClient(newClient);

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
                    _selectedClientId = newest['id'] as int;
                  });
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
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
        title: Text(AppLocalizations.of(context)!.addNewCar),
        content: Form(
          key: formKeyCar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.carNameModel,
                ),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              TextFormField(
                controller: plateController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.plateNumber),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.dailyRentPrice,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.add),
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
          _dateError = AppLocalizations.of(context)!.dateError;
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
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectDates)),
        );
        return;
      }
      if (_dateError != null) return;

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
        title: Text(
          AppLocalizations.of(context)!.addRentalTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                      _buildLabel(AppLocalizations.of(context)!.client),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedClientId,
                              hint: Text(AppLocalizations.of(context)!.selectClient),
                              decoration: _inputDecoration(
                                Icons.person_outline,
                              ),
                              items: _clients.map((client) {
                                // Matches new schema: first_name, last_name
                                final name =
                                    "${client['first_name']} ${client['last_name']}";
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
                                  ? AppLocalizations.of(context)!.pleaseSelectClient
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildAddButton(_showAddClientDialog),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // CAR DROPDOWN
                      _buildLabel(AppLocalizations.of(context)!.car),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedCarId,
                              hint: Text(AppLocalizations.of(context)!.selectCar),
                              decoration: _inputDecoration(
                                Icons.directions_car,
                              ),
                              items: _cars.map((car) {
                                // Matches new schema: name, plate, price
                                final name = car['name'] ?? 'Unknown';
                                final plate = car['plate'] ?? '';
                                final price = car['price'] ?? 0;
                                return DropdownMenuItem<int>(
                                  value: car['id'] as int,
                                  child: Text(
                                    "$name ($plate) - ${AppLocalizations.of(context)!.pricePerDay(price.toStringAsFixed(2))}",
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
                                  value == null ? AppLocalizations.of(context)!.pleaseSelectCar : null,
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
                                _buildLabel(AppLocalizations.of(context)!.startDate),
                                _buildDateSelector(true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(AppLocalizations.of(context)!.endDate),
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
                      _buildLabel(AppLocalizations.of(context)!.totalPrice),
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
                            return AppLocalizations.of(context)!.pleaseEnterPrice;
                          if (double.tryParse(value) == null)
                            return AppLocalizations.of(context)!.invalidNumber;
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
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(
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
                              child: Text(
                                AppLocalizations.of(context)!.saveRental,
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
                  ? AppLocalizations.of(context)!.selectDate
                  : '${date.day}/${date.month}/${date.year}',
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
