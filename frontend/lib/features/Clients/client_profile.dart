import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubits
import 'package:auto_manager/logic/cubits/clients/profile_cubit.dart';

// Localization
import 'package:auto_manager/l10n/app_localizations.dart';

class ClientProfile extends StatefulWidget {
  final Map<String, dynamic> client;
  const ClientProfile({super.key, required this.client});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getRentals(widget.client['id']);
  }

  // Helper to translate status for Profile
  String _getProfileStatus(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppLocalizations.of(context)!.statusActive;
      case 'completed':
        return AppLocalizations.of(context)!.statusCompleted;
      case 'ongoing':
        return AppLocalizations.of(context)!.statusOngoing;
      default:
        return status ?? AppLocalizations.of(context)!.unknown;
    }
  }

  // Helper to translate client state
  String _getClientState(BuildContext context, String? state) {
    if (state == 'active') {
      return AppLocalizations.of(context)!.statusActive;
    }
    return AppLocalizations.of(context)!.statusIdle;
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
          l10n.clientProfileTitle,
          style: const TextStyle(
            fontFamily: 'ManropeExtraBold',
            color: Color(0xFF2D3748),
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3748)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<ProfileCubit, List<Map<String, dynamic>>>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER INFO ----------------
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.client['full_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.client['phone'] ?? l10n.noPhone,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge_outlined,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${l10n.ninLabel}: ${widget.client['phone']}', // Assuming phone is used as NIN placeholder based on original code
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: widget.client['state'] == 'active'
                                      ? [
                                          const Color(0xFFDCFCE7),
                                          const Color(0xFFBBF7D0),
                                        ]
                                      : [
                                          const Color(0xFFF1F5F9),
                                          const Color(0xFFE2E8F0),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: widget.client['state'] == 'active'
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF94A3B8),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getClientState(
                                      context,
                                      widget.client['state'],
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                      color: widget.client['state'] == 'active'
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '3 ${l10n.days}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: widget.client['state'] == 'active'
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFDEDDFF),
                                    Color(0xFFE0E7FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: const Color(0xFF007BFF),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.totalRents,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF007BFF),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${state.length}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF007BFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.rentHistory,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------------- RENTAL LIST ----------------
                Expanded(
                  child: state.isEmpty
                      ? Center(child: Text(l10n.noRecentActivities))
                      : ListView.builder(
                          itemCount: state.length,
                          itemBuilder: (context, index) {
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
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFF007BFF),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state[index]['name']
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2D3748),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${l10n.from} ${DateTime.parse(state[index]['date_from']).toString().split(' ')[0]} ${l10n.to} ${DateTime.parse(state[index]['date_to']).toString().split(' ')[0]}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${l10n.totalIs}: \$${state[index]['total_amount']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color:
                                                state[index]['state'] ==
                                                    'completed'
                                                ? const Color(0xFFF1F5F9)
                                                : state[index]['state'] ==
                                                      'ongoing'
                                                ? const Color(0xFFDCFCE7)
                                                : const Color(0xFFFEE2E2),
                                            border: Border.all(
                                              color:
                                                  state[index]['state'] ==
                                                      'completed'
                                                  ? const Color(0xFF94A3B8)
                                                  : state[index]['state'] ==
                                                        'ongoing'
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFDC2626),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            _getProfileStatus(
                                              context,
                                              state[index]['state'],
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color:
                                                  state[index]['state'] ==
                                                      'completed'
                                                  ? const Color(0xFF475569)
                                                  : state[index]['state'] ==
                                                        'ongoing'
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFDC2626),
                                            ),
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
          );
        },
      ),
    );
  }
}
