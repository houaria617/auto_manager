import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:auto_manager/features/auth/presentation/register_screen.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';

final routes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/add_rental': (context) => const AddRentalScreen(), // Changed from AddRentalForm
};