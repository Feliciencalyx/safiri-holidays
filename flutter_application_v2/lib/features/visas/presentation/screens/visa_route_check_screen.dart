import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_button.dart';
import '../../../../providers/app_state.dart';
import '../../../../screens/visa/visa_vault_screen.dart';
import '../../../../core/services/visa_api_service.dart';
import '../../../../core/services/notification_service.dart';

class VisaRouteCheckScreen extends StatefulWidget {
  const VisaRouteCheckScreen({super.key});

  @override
  State<VisaRouteCheckScreen> createState() => _VisaRouteCheckScreenState();
}

class _VisaRouteCheckScreenState extends State<VisaRouteCheckScreen> {
  String _destinationCountry = 'France (Schengen Area)';
  String _applicantNationality = 'Rwanda';
  String _residenceCountry = 'Rwanda';
  String _travelPurpose = 'Tourism';

  static const List<String> _countries = [
    'France (Schengen Area)',
    'United Kingdom',
    'United States',
    'United Arab Emirates',
    'Canada',
    'Kenya',
    'Tanzania',
    'Singapore',
    'Rwanda',
  ];

  static const List<String> _purposes = [
    'Tourism',
    'Business',
    'Study',
    'Family Visit',
    'Transit',
    'Medical',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.tr('visa_route_check')),
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
              // Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.assignment_turned_in_rounded, color: AppColors.accentGold, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Entry & Visa Route Check',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Evaluate entry rules, required documentation, and concierge consultation processing.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DESTINATION COUNTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _destinationCountry,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _destinationCountry = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('APPLICANT NATIONALITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _applicantNationality,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _applicantNationality = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('RESIDENCE COUNTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _residenceCountry,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _residenceCountry = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('PURPOSE OF TRAVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _travelPurpose,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _travelPurpose = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    SafiriButton(
                      text: 'CHECK ROUTE & START APPLICATION',
                      onPressed: _startVisaApplication,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startVisaApplication() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    final res = await VisaApiService.createApplication(
      destinationCountry: _destinationCountry,
      applicantNationality: _applicantNationality,
      residenceCountry: _residenceCountry,
      travelPurpose: _travelPurpose,
    );

    final visaData = res['visaCase'] ?? {};
    final caseId = visaData['id'] ?? '#VSA-${1000 + appState.visaApplications.length}';

    final newApp = VisaApplicationItem(
      id: caseId,
      destinationCountry: _destinationCountry,
      applicantNationality: _applicantNationality,
      currentStep: 2,
      status: 'Under Review',
      documentsUploaded: {
        'Passport Scan': true,
        'Proof of Funds': false,
        'Invitation Letter': false,
        'Biometrics Receipt': false,
      },
      submittedDate: DateTime.now().toIso8601String().split('T')[0],
    );

    appState.addVisaApplication(newApp);

    notificationService.addNotification(
      title: 'Visa Application Case Created ($caseId)',
      body: 'Your $_destinationCountry visa route check has been recorded. Tap to view Document Vault checklist.',
      icon: Icons.assignment_turned_in_rounded,
      color: const Color(0xFF78592E),
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VisaVaultScreen(visaId: caseId)),
      );
    }
  }
}
