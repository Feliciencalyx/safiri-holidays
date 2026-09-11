import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/user_profile_modal.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../visa/visa_eligibility_screen.dart';
import '../documents/passport_vault_modal.dart';
import '../currency/currency_converter_screen.dart';

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
                    appState.tr('included_privileges'),
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
                    child: Text(appState.tr('view_details')),
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
                              children: [
                                const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF052469)),
                                const SizedBox(width: 4),
                                Text(
                                  appState.tr('edit_profile').toUpperCase(),
                                  style: const TextStyle(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${appState.tr('phone_number')} & ${appState.tr('passport_number')}:', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                              Text(
                                '${appState.currentUserPhone} • ${appState.currentUserPassportNumber}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text('${appState.tr('registered_address')}:', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                              Text(
                                appState.currentUserAddress,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: appState.isPassportVerified ? Colors.green : Colors.amber.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appState.isPassportVerified ? appState.tr('verified').toUpperCase() : appState.tr('pending_verification').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Linked System Records & Relationships Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: MajesticHorizonTheme.radiusCard,
                  border: Border.all(
                    color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF052469).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.hub_outlined, color: Color(0xFF052469), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.tr('profile_relationships'),
                                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${appState.tr('sync_across_safiri')} ${appState.currentUserEmail}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildProfileRelationshipRow(
                      icon: Icons.confirmation_number_outlined,
                      title: appState.tr('linked_bookings'),
                      subtitle: '${appState.bookings.length} ${appState.tr('reservations_sync')}',
                      actionLabel: appState.tr('view_trips'),
                      onTap: () => appState.setSelectedTab(1),
                    ),
                    const SizedBox(height: 10),
                    _buildProfileRelationshipRow(
                      icon: Icons.assignment_outlined,
                      title: appState.tr('visa_apps_vault'),
                      subtitle: '${appState.visaApplications.length} ${appState.tr('active_apps_under_passport')} ${appState.currentUserPassportNumber}',
                      actionLabel: appState.tr('view_visas'),
                      onTap: () => appState.setSelectedTab(2),
                    ),
                    const SizedBox(height: 10),
                    _buildProfileRelationshipRow(
                      icon: Icons.badge_outlined,
                      title: appState.tr('biometric_passport_scan'),
                      subtitle: '${appState.passportCountry} • ${appState.tr('expires')} ${appState.passportExpiryDate}',
                      actionLabel: appState.tr('view_vault'),
                      onTap: () => PassportVaultModal.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Included Privileges Header & Filter Bar matching Image 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.tr('included_privileges'),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      {'key': 'All', 'label': appState.tr('filter_all')},
                      {'key': 'Travel', 'label': appState.tr('filter_travel')},
                      {'key': 'Lifestyle', 'label': appState.tr('filter_lifestyle')},
                    ].map((item) {
                      final filter = item['key']!;
                      final label = item['label']!;
                      final isSelected = _privilegeFilter == filter;

                      return InkWell(
                        onTap: () => setState(() => _privilegeFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(left: 12),
                          child: Column(
                            children: [
                              Text(
                                label,
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
                appState: appState,
                icon: Icons.chair_rounded,
                title: appState.tr('lounge_access'),
                description: appState.tr('lounge_access_desc'),
                btnText: appState.tr('view_details'),
                cardBg: cardBg,
                isDark: isDark,
                onTap: () => _showPrivilegeModal(context, appState.tr('lounge_access'), appState.tr('lounge_access_desc')),
              ),
              const SizedBox(height: 14),

              // Privilege 2: Priority Visa Processing matching Image 6
              _buildPrivilegeCard(
                context: context,
                appState: appState,
                icon: Icons.assignment_turned_in_rounded,
                title: appState.tr('visa_application'),
                description: appState.tr('visa_desc'),
                btnText: appState.tr('check_route'),
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
                appState: appState,
                icon: Icons.headset_mic_rounded,
                title: appState.tr('concierge_support'),
                description: appState.tr('concierge_support_desc'),
                btnText: appState.tr('contact_concierge'),
                cardBg: cardBg,
                isDark: isDark,
                onTap: () => _showPrivilegeModal(context, appState.tr('concierge_support'), appState.tr('concierge_support_desc')),
              ),
              const SizedBox(height: 30),

              // Preferences & Controls Section (Admin Portal Card removed for customer profile security)
              Text(
                appState.tr('app_settings'),
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
                title: Text(appState.tr('multi_currency'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${appState.tr('active_currency')}: ${appState.currentCurrency}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showCurrencyDialog(context),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: cardBg,
                shape: RoundedRectangleBorder(borderRadius: MajesticHorizonTheme.radiusCard),
                leading: const Icon(Icons.language_rounded),
                title: Text(appState.tr('i18n_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${appState.tr('locale_label')}: ${AppState.supportedLocales[appState.currentLocale]?['native']} (${appState.currentLocale.toUpperCase()})'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                tileColor: cardBg,
                shape: RoundedRectangleBorder(borderRadius: MajesticHorizonTheme.radiusCard),
                secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                title: Text(appState.tr('dark_theme'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(isDark ? appState.tr('dark_mode_active') : appState.tr('light_mode_active')),
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
    required AppState appState,
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
                child: Text(
                  appState.tr('active_status'),
                  style: const TextStyle(
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
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(details),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.tr('close')),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CurrencyConverterScreen()),
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
            Text(appState.tr('select_language'), style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildProfileRelationshipRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF052469).withValues(alpha: 0.08),
              child: Icon(icon, size: 16, color: const Color(0xFF052469)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Text(
              actionLabel,
              style: const TextStyle(color: Color(0xFF052469), fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF052469)),
          ],
        ),
      ),
    );
  }
}
