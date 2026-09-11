import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/visa_tracker_widget.dart';
import '../visa/visa_vault_screen.dart';
import 'facility_finder_screen.dart';
import 'passport_vault_modal.dart';

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
                    appState.tr('documents_vault'),
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
                    tooltip: appState.tr('find_facility'),
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
                          children: [
                            Text(
                              appState.tr('find_facility'),
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              appState.tr('find_facility_desc'),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                appState.tr('active_visa_apps'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (appState.visaApplications.isEmpty)
                Center(child: Text(appState.tr('no_active_visas')))
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
                appState.tr('personal_vault'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildPassportVaultItem(
                context: context,
                appState: appState,
                cardBg: cardBg,
                isDark: isDark,
                primaryNavy: primaryNavy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassportVaultItem({
    required BuildContext context,
    required AppState appState,
    required Color cardBg,
    required bool isDark,
    required Color primaryNavy,
  }) {
    final hasScan = appState.scannedPassportPath != null && appState.scannedPassportPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: MajesticHorizonTheme.radiusCard,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: MajesticHorizonTheme.radiusCard,
        child: InkWell(
          borderRadius: MajesticHorizonTheme.radiusCard,
          onTap: () => PassportVaultModal.show(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF052469).withValues(alpha: 0.1),
                  child: const Icon(Icons.badge_outlined, color: Color(0xFF052469)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            appState.tr('passport_scan'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (hasScan) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${appState.tr('expires')}: ${appState.passportExpiryDate} • ${appState.isPassportVerified ? appState.tr('verified') : appState.tr('pending_verification')}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Scan / Camera Action Button
                IconButton(
                  icon: const Icon(Icons.document_scanner_outlined, color: Color(0xFF052469)),
                  tooltip: appState.tr('scan_passport'),
                  onPressed: () => PassportScannerSheet.show(context),
                ),
                // View Action Button
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
                  tooltip: appState.tr('view_encrypted_passport'),
                  onPressed: () => PassportVaultModal.show(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
