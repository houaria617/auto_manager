// placeholder payment screen with language switcher

import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.comingSoon),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      ),
      // temporary language picker for testing
      body: Center(
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return DropdownButton<String>(
              value: locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<LocaleCubit>().changeLanguage(value);
                }
              },
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              icon: const Icon(Icons.language, color: Colors.black),
              underline: Container(height: 2, color: Colors.black),
              dropdownColor: Colors.white,
            );
          },
        ),
      ),
    );
  }
}
