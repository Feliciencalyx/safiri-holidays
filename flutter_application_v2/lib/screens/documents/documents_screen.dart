import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/visa_tracker_widget.dart';
import '../visa/visa_vault_screen.dart';
import 'facility_finder_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Documents & Vault',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryNavy,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FacilityFinderScreen()),
                      );
                    },
                    icon: const Icon(Icons.location_city_rounded),
                    tooltip: 'Find a Facility',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prominent Facility Directory Action Card matching Image 10
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FacilityFinderScreen()),
                  );
                },
                borderRadius: MajesticHorizonTheme.radiusCard,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78592E).withValues(alpha: 0.12),
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: const Color(0xFF78592E).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF78592E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.domain_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Find a Facility Directory',
                              style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Locate global visa hubs, airport luxury lounges, and partner hotels.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF78592E)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Visa Applications Section
              Text(
                'Active Visa Applications',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (appState.visaApplications.isEmpty)
                const Center(child: Text('No active visa applications.'))
              else
                ...appState.visaApplications.map((visaApp) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VisaVaultScreen(visaId: visaApp.id)),
                        );
                      },
                      child: VisaTrackerWidget(visaApp: visaApp),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // Personal Saved Documents Section
              Text(
                'Personal Travel Vault',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildVaultDocumentItem(
                context: context,
                title: 'International Passport Scan',
                subtitle: 'Expires: 14 Nov 2031 • Verified',
                icon: Icons.badge_outlined,
                cardBg: cardBg,
                isDark: isDark,
              ),
              _buildVaultDocumentItem(
                context: context,
                title: 'COVID-19 & Yellow Fever Certs',
                subtitle: 'Health Pass • Verified',
                icon: Icons.health_and_safety_outlined,
                cardBg: cardBg,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultDocumentItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardBg,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: MajesticHorizonTheme.radiusCard,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF052469).withValues(alpha: 0.1),
            child: Icon(icon, color: const Color(0xFF052469)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening encrypted view for $title')),
              );
            },
          ),
        ],
      ),
    );
  }
}
