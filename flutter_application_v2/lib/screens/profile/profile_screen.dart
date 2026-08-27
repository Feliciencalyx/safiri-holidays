import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/user_profile_modal.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../visa/visa_eligibility_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _privilegeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & View History Button matching Image 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Benefits',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: primaryNavy,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _showHistoryModal(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    child: const Text('View History'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // VIP Member Card with System-wide Profile Connection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: MajesticHorizonTheme.radiusHero,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF031B4E), Color(0xFF052469), Color(0xFF0D3FA9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: MajesticHorizonTheme.lightCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => UserProfileModal.show(context),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white24,
                                backgroundImage: appState.currentUserAvatarUrl.isNotEmpty
                                    ? (appState.currentUserAvatarUrl.startsWith('http')
                                        ? NetworkImage(appState.currentUserAvatarUrl)
                                        : (File(appState.currentUserAvatarUrl).existsSync()
                                            ? FileImage(File(appState.currentUserAvatarUrl))
                                            : NetworkImage(appState.currentUserAvatarUrl) as ImageProvider))
                                    : null,
                                child: appState.currentUserAvatarUrl.isEmpty
                                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.currentUserName,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  appState.currentUserEmail,
                                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => UserProfileModal.show(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED39D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.edit_rounded, size: 14, color: Color(0xFF052469)),
                                SizedBox(width: 4),
                                Text(
                                  'EDIT PROFILE',
                                  style: TextStyle(
                                    color: Color(0xFF052469),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Phone & Passport:', style: TextStyle(color: Colors.white60, fontSize: 10)),
                            Text(
                              '${appState.currentUserPhone} • ${appState.currentUserPassportNumber}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: appState.isPassportVerified ? Colors.green : Colors.amber.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appState.isPassportVerified ? 'PASSPORT VERIFIED' : 'PASSPORT PENDING',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Included Privileges Header & Filter Bar matching Image 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Included Privileges',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                    ),
                  ),
                  Row(
                    children: ['All', 'Travel', 'Lifestyle'].map((filter) {
                      final isSelected = _privilegeFilter == filter;

                      return InkWell(
                        onTap: () => setState(() => _privilegeFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(left: 12),
                          child: Column(
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? primaryNavy : textMuted,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  height: 2,
                                  width: 20,
                                  color: primaryNavy,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Privilege 1: Global Lounge Access matching Image 6
              _buildPrivilegeCard(
                context: context,
                icon: Icons.chair_rounded,
                title: 'Global Lounge Access',
                description: 'Complimentary access to over 1,200 airport lounges worldwide, regardless of ticket class.',
                btnText: 'View Details',
                cardBg: cardBg,
                isDark: isDark,
                onTap: () => _showPrivilegeModal(context, 'Global Lounge Access', 'Access over 1,200 luxury partner lounges with priority check-in and complimentary dining.'),
              ),
              const SizedBox(height: 14),

              // Privilege 2: Priority Visa Processing matching Image 6
              _buildPrivilegeCard(
                context: context,
                icon: Icons.assignment_turned_in_rounded,
                title: 'Priority Visa Processing',
                description: 'Expedited handling of visa applications with dedicated concierges guiding the process.',
                btnText: 'Apply Now',
                cardBg: cardBg,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VisaEligibilityScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Privilege 3: Luxury Concierge Support matching Image 6
              _buildPrivilegeCard(
                context: context,
                icon: Icons.headset_mic_rounded,
                title: 'Luxury Concierge Support',
                description: '24/7 dedicated support for reservations, emergency travel changes, and bespoke requests.',
                btnText: 'Contact Concierge',
                cardBg: cardBg,
                isDark: isDark,
                onTap: () => _showPrivilegeModal(context, 'Luxury Concierge Support', 'Your dedicated concierge manager is available via direct phone or in-app messaging 24/7/365.'),
              ),
              const SizedBox(height: 30),

              // Admin Portal Access Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: MajesticHorizonTheme.radiusHero,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: MajesticHorizonTheme.lightCardShadow,
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFF59E0B), size: 26),
                            SizedBox(width: 8),
                            Text(
                              'Safiri Admin Portal',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN CONSOLE',
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage flight routes, holiday packages, review customer bookings, manage users & system configurations.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          appState.setAdminMode(true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.dashboard_rounded, size: 20),
                        label: const Text(
                          'Open Admin Section',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Preferences & Controls Section
              Text(
                'App Engine Settings',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ListTile(
                tileColor: cardBg,
                shape: RoundedRectangleBorder(borderRadius: MajesticHorizonTheme.radiusCard),
                leading: const Icon(Icons.currency_exchange_rounded),
                title: const Text('Multi-Currency Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Active: ${appState.currentCurrency}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showCurrencyDialog(context),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: cardBg,
                shape: RoundedRectangleBorder(borderRadius: MajesticHorizonTheme.radiusCard),
                leading: const Icon(Icons.language_rounded),
                title: const Text('Internationalization (i18n)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Locale: ${AppState.supportedLocales[appState.currentLocale]?['native']} (${appState.currentLocale.toUpperCase()})'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                tileColor: cardBg,
                shape: RoundedRectangleBorder(borderRadius: MajesticHorizonTheme.radiusCard),
                secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                title: const Text('Dark Theme Engine (Inverted)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(isDark ? 'Majestic Horizon Dark Mode' : 'Majestic Horizon Light Mode'),
                value: isDark,
                onChanged: (val) => appState.toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivilegeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String btnText,
    required Color cardBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: MajesticHorizonTheme.radiusHero,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
        boxShadow: isDark ? MajesticHorizonTheme.darkCardShadow : MajesticHorizonTheme.lightCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFF052469).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF052469), size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED39D).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF78592E),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              child: Text(btnText),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivilegeModal(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(details),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('VIP Benefit History', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                title: Text('Priority Pass Lounge Visit - LHR T5'),
                subtitle: Text('Redeemed on 12 Oct 2026'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                title: Text('Schengen Visa Expedited Review'),
                subtitle: Text('Redeemed on 15 Aug 2026'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Multi-Currency Engine', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...AppState.currencyData.entries.map((e) {
              return ListTile(
                title: Text('${e.value['name']} (${e.key})'),
                subtitle: Text('Symbol: ${e.value['symbol']}'),
                trailing: appState.currentCurrency == e.key ? const Icon(Icons.check, color: Color(0xFF052469)) : null,
                onTap: () {
                  appState.setCurrency(e.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Language & i18n Locale', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...AppState.supportedLocales.entries.map((e) {
              return ListTile(
                leading: Text(e.value['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text('${e.value['native']} (${e.value['name']})'),
                trailing: appState.currentLocale == e.key ? const Icon(Icons.check, color: Color(0xFF052469)) : null,
                onTap: () {
                  appState.setLocale(e.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
