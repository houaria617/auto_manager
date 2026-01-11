// subscription plans comparison screen

import 'package:auto_manager/features/subscription/presentation/screens/payment_screen.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 240, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.upgradeToPremium,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // free plan card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 225, 225, 225),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.free,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.zeroDA,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.blue),
                        const SizedBox(width: 18),
                        Text(AppLocalizations.of(context)!.accessBasicFeatures),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.blue),
                        const SizedBox(width: 18),
                        Text(AppLocalizations.of(context)!.limitedRentals),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.blue),
                        const SizedBox(width: 18),
                        Text(AppLocalizations.of(context)!.limitedCars),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // premium plan card with recommended badge
            Stack(
              children: [
                // Premium plan container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.premium,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.premiumPrice,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.upgradeToPremium,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.blue),
                            const SizedBox(width: 18),
                            Text(
                              AppLocalizations.of(context)!.accessAllFeatures,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.blue),
                            const SizedBox(width: 18),
                            Text(
                              AppLocalizations.of(context)!.unlimitedRentals,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.blue),
                            const SizedBox(width: 18),
                            Text(AppLocalizations.of(context)!.unlimitedCars),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.blue),
                            const SizedBox(width: 18),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.rentalHistoryAnalytics,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check, color: Colors.blue),
                            const SizedBox(width: 18),
                            Text(AppLocalizations.of(context)!.customReminders),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommended badge
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.recommended,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
