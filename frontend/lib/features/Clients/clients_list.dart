import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubits
import 'package:auto_manager/logic/cubits/clients/client_cubit.dart';

// Localization
import 'package:auto_manager/l10n/app_localizations.dart';

// UI Components
import 'package:auto_manager/features/Dashboard/navigation_bar.dart';
import 'client_profile.dart'; // Ensure this points to the file below

class ClientsList extends StatefulWidget {
  const ClientsList({super.key});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  @override
  void initState() {
    super.initState();
    context.read<ClientCubit>().getClients();
  }

  // Helper to localize status strings coming from DB
  String _getLocalizedStatus(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppLocalizations.of(context)!.statusActive;
      case 'idle':
        return AppLocalizations.of(context)!.statusIdle;
      default:
        return status ?? AppLocalizations.of(context)!.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          l10n.clientsTitle,
          style: const TextStyle(
            fontFamily: 'ManropeExtraBold',
            color: Color(0xFF2D3748),
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: BlocBuilder<ClientCubit, List<Map<String, dynamic>>>(
        builder: (context, state) {
          if (state.isEmpty) {
            return Center(child: Text(l10n.noClientFound));
          }
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Search Bar
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (String newText) {
                              context.read<ClientCubit>().clientsSearch(
                                newText,
                              );
                            },
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2,
                                  color: Color(0xFF4F46E5),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF94A3B8),
                                size: 24,
                              ),
                              hintText: l10n.searchClientHint,
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF94A3B8),
                                fontSize: 15,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // List View
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.length,
                            itemBuilder: (context, i) {
                              final status =
                                  state[i]['state']?.toString() ?? 'idle';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ClientProfile(client: state[i]),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            height: 56,
                                            width: 56,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF007BFF),
                                                  Color.fromARGB(
                                                    255,
                                                    96,
                                                    157,
                                                    223,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF4F46E5,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 32,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  state[i]['full_name']
                                                          ?.toString() ??
                                                      l10n.unknown,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  state[i]['phone']
                                                          ?.toString() ??
                                                      l10n.noPhone,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: status == 'active'
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 4,
                                                  backgroundColor:
                                                      status == 'active'
                                                      ? const Color(0xFF16A34A)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 18,
                                              ),
                                              color: const Color(0xFF64748B),
                                              padding: const EdgeInsets.all(8),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
