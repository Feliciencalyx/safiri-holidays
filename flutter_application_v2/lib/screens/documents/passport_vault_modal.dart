import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/app_state.dart';

class PassportVaultModal extends StatefulWidget {
  const PassportVaultModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PassportVaultModal(),
    );
  }

  @override
  State<PassportVaultModal> createState() => _PassportVaultModalState();
}

class _PassportVaultModalState extends State<PassportVaultModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageProvider? _getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (!kIsWeb) {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return NetworkImage(path);
  }

  void _openFullScreenImage(BuildContext context, ImageProvider imageProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Passport Document Scan', style: TextStyle(fontSize: 16)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image(image: imageProvider),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = const Color(0xFF052469);
    final goldAccent = const Color(0xFFC89B3C);

    final hasScannedImage = appState.scannedPassportPath != null && appState.scannedPassportPath!.isNotEmpty;
    final scanImageProvider = hasScannedImage ? _getImageProvider(appState.scannedPassportPath) : null;

    final nameParts = appState.currentUserName.trim().split(' ');
    final surname = nameParts.length > 1 ? nameParts.last.toUpperCase() : appState.currentUserName.toUpperCase();
    final givenNames = nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ').toUpperCase() : '';

    final cleanPass = appState.currentUserPassportNumber.replaceAll(' ', '').toUpperCase();
    final mrzLine1 = 'P<RWA$surname<<${givenNames.replaceAll(' ', '<')}<<<<<<<<<<<<<<<<<<<<<<<<<<<<'.padRight(44, '<').substring(0, 44);
    final mrzLine2 = '${cleanPass.padRight(9, '<')}4RWA0101018M3111145<<<<<<<<<<<<<<04'.padRight(44, '<').substring(0, 44);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A29) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Modal Top Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_user_rounded, color: goldAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Personal Travel Vault',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AES-256',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Encrypted ICAO 9303 Biometric Document',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: primaryNavy,
            labelColor: isDark ? Colors.white : primaryNavy,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.badge_rounded, size: 18), text: 'Biometric Passport'),
              Tab(icon: Icon(Icons.document_scanner_rounded, size: 18), text: 'Document Scan'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Digital Biometric Passport Card
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // High-fidelity e-Passport Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF041944), Color(0xFF0A2B6E), Color(0xFF0D3482)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: goldAccent.withValues(alpha: 0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: primaryNavy.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Passport Top Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.public_rounded, color: goldAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      appState.passportCountry.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: goldAccent,
                                        fontSize: 13,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: goldAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: goldAccent.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.memory_rounded, color: goldAccent, size: 14),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'E-PASSPORT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Photo + Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Biometric Photo Box
                                Container(
                                  width: 82,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: appState.currentUserAvatarUrl.isNotEmpty
                                        ? Image.network(
                                            appState.currentUserAvatarUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white54, size: 40),
                                          )
                                        : const Icon(Icons.person, color: Colors.white54, size: 40),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Details Table
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPassportField('PASSPORT NO.', appState.currentUserPassportNumber, isPrimary: true),
                                      const SizedBox(height: 8),
                                      _buildPassportField('FULL NAME', appState.currentUserName),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(child: _buildPassportField('NATIONALITY', appState.passportCountry)),
                                          Expanded(child: _buildPassportField('EXPIRES', appState.passportExpiryDate)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // ICAO 9303 MRZ Machine Readable Zone
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mrzLine1,
                                    style: GoogleFonts.shareTechMono(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    mrzLine2,
                                    style: GoogleFonts.shareTechMono(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Verification QR and Security Stamp
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: QrImageView(
                                data: 'SAFIRI-PASS-VALID-${appState.currentUserPassportNumber}-${appState.passportExpiryDate}',
                                version: QrVersions.auto,
                                size: 68.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Verified Digital Credential',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Present QR code at participating VIP lounges, hotel fast-track desks, and airport security.',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: Scanned Document View
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (hasScannedImage && scanImageProvider != null) ...[
                        GestureDetector(
                          onTap: () => _openFullScreenImage(context, scanImageProvider),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 260,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: goldAccent.withValues(alpha: 0.5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image(
                                    image: scanImageProvider,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Text('Error loading scanned document image.'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to Enlarge',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Physical passport photo page verified and encrypted in your device vault.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.document_scanner_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'No Physical Scan Stored',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Scan your physical passport page to store an encrypted photo copy for visa & concierge processing.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  PassportScannerSheet.show(context);
                                },
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: const Text('Scan Passport Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1420) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      PassportScannerSheet.show(context);
                    },
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(hasScannedImage ? 'Re-scan Passport' : 'Scan Passport Document'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryNavy,
                      side: BorderSide(color: primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportField(String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? const Color(0xFFC89B3C) : Colors.white,
            fontSize: isPrimary ? 15 : 12,
            fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w600,
            letterSpacing: isPrimary ? 1.5 : 0.2,
          ),
        ),
      ],
    );
  }
}

/// Interactive Sheet for capturing, picking, or simulating a passport scan
class PassportScannerSheet extends StatelessWidget {
  const PassportScannerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const PassportScannerSheet(),
    );
  }

  Future<void> _handleImagePick(BuildContext context, ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null && context.mounted) {
        _runScanningProcess(context, file.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera/Gallery access error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleInstantScan(BuildContext context) {
    Navigator.pop(context); // Close bottom sheet
    _runScanningProcess(context, null);
  }

  void _runScanningProcess(BuildContext context, String? imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _PassportScanProgressDialog(
        imagePath: imagePath,
        onComplete: (savedPath) {
          Navigator.pop(dialogCtx); // Close progress dialog

          final appState = Provider.of<AppState>(context, listen: false);
          appState.updateScannedPassport(
            imagePath: savedPath,
            isVerified: true,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Passport scan verified & encrypted in Vault!'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Re-open the passport vault modal to show the verified document
          PassportVaultModal.show(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = const Color(0xFF052469);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A29) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.document_scanner_rounded, color: primaryNavy, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Scan Passport Document',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                    ),
                    Text(
                      'Select a capture method to verify your passport',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Option 1: Camera
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF052469).withValues(alpha: 0.12),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF052469)),
              ),
              title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: const Text('Capture physical passport photo page', style: TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () => _handleImagePick(context, ImageSource.camera),
            ),

            // Option 2: Gallery
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF78592E).withValues(alpha: 0.12),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF78592E)),
              ),
              title: const Text('Choose from Photos / Files', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: const Text('Upload PDF or high-res JPG scan', style: TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () => _handleImagePick(context, ImageSource.gallery),
            ),

            // Option 3: Instant AI Biometric Scanner
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2E7D32)),
              ),
              title: const Text('Instant Biometric AI Scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: const Text('Simulate automated OCR edge detection & verification', style: TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () => _handleInstantScan(context),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _PassportScanProgressDialog extends StatefulWidget {
  final String? imagePath;
  final void Function(String? savedPath) onComplete;

  const _PassportScanProgressDialog({
    required this.imagePath,
    required this.onComplete,
  });

  @override
  State<_PassportScanProgressDialog> createState() => _PassportScanProgressDialogState();
}

class _PassportScanProgressDialogState extends State<_PassportScanProgressDialog> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  int _stepIndex = 0;

  final List<String> _steps = [
    'Aligning document boundaries...',
    'Extracting ICAO 9303 MRZ zone...',
    'Performing biometric cryptographic check...',
    'Encrypting document with 256-bit AES...',
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _runSteps();
  }

  void _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _stepIndex = i);
      }
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      widget.onComplete(widget.imagePath ?? 'simulated_passport_scan');
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF141A29) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scanner Animation Box
            Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF052469).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF052469).withValues(alpha: 0.3), width: 1.5),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.badge_outlined,
                      size: 48,
                      color: const Color(0xFF052469).withValues(alpha: 0.4),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _laserController,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserController.value * 88,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC89B3C),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC89B3C).withValues(alpha: 0.8),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Biometric Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _steps[_stepIndex],
                key: ValueKey<int>(_stepIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_stepIndex + 1) / _steps.length,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF052469)),
            ),
          ],
        ),
      ),
    );
  }
}
