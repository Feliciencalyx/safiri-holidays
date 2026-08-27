import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/visa_tracker_widget.dart';

class VisaVaultScreen extends StatefulWidget {
  final String visaId;

  const VisaVaultScreen({
    super.key,
    required this.visaId,
  });

  @override
  State<VisaVaultScreen> createState() => _VisaVaultScreenState();
}

class _VisaVaultScreenState extends State<VisaVaultScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadingDocName;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    final visaApp = appState.visaApplications.firstWhere(
      (a) => a.id == widget.visaId,
      orElse: () => appState.visaApplications.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('VISA APPLICATION ${visaApp.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Tracker Header
              VisaTrackerWidget(visaApp: visaApp),
              const SizedBox(height: 20),

              // Encryption Security Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2E24) : const Color(0xFFE8F5E9),
                  borderRadius: MajesticHorizonTheme.radiusCard,
                  border: Border.all(color: const Color(0xFF2E7D32)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline_rounded, color: Color(0xFF2E7D32), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '256-Bit Encrypted Vault',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                          ),
                          Text(
                            'Your personal documents are encrypted end-to-end and stored securely for concierge processing.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Document Checklist Header
              Text(
                'Required Documents Checklist',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Uploading Progress Indicator Bar
              if (_isUploading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryNavy.withValues(alpha: 0.08),
                    borderRadius: MajesticHorizonTheme.radiusCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encrypting & Uploading $_uploadingDocName...',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade300,
                        color: primaryNavy,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Checklist Cards
              ...visaApp.documentsUploaded.entries.map((entry) {
                final docName = entry.key;
                final isUploaded = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(
                      color: isUploaded ? const Color(0xFF2E7D32) : (isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isUploaded ? const Color(0xFFE8F5E9) : Colors.grey.shade200,
                        child: Icon(
                          isUploaded ? Icons.check_circle_rounded : Icons.file_upload_outlined,
                          color: isUploaded ? const Color(0xFF2E7D32) : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(docName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              isUploaded ? 'Verified & Encrypted' : 'Pending PDF/JPG upload',
                              style: TextStyle(
                                fontSize: 11,
                                color: isUploaded ? const Color(0xFF2E7D32) : Colors.grey,
                                fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _simulateDocumentUpload(visaApp.id, docName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUploaded ? Colors.grey.shade300 : primaryNavy,
                          foregroundColor: isUploaded ? Colors.black87 : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: Text(isUploaded ? 'Re-upload' : 'Upload'),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.setSelectedTab(2); // Switch to Documents tab
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('VIEW ALL IN DOCUMENTS VAULT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateDocumentUpload(String visaId, String docName) async {
    setState(() {
      _isUploading = true;
      _uploadingDocName = docName;
      _uploadProgress = 0.2;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _uploadProgress = 0.6);

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _uploadProgress = 1.0);

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.toggleDocumentUpload(visaId, docName);

      setState(() {
        _isUploading = false;
        _uploadingDocName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded and encrypted $docName!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }
}
