import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../core/services/payment_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'visa_vault_screen.dart';

class VisaApplicationWizardScreen extends StatefulWidget {
  final String destinationCountry;
  final String nationality;

  const VisaApplicationWizardScreen({
    super.key,
    required this.destinationCountry,
    required this.nationality,
  });

  @override
  State<VisaApplicationWizardScreen> createState() => _VisaApplicationWizardScreenState();
}

class _VisaApplicationWizardScreenState extends State<VisaApplicationWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passportController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _visaType = 'Tourist Short-Stay (30 Days)';
  bool _hasPassportScan = true;
  bool _hasPhoto = true;
  bool _hasProofOfFunds = true;
  bool _hasFlightItinerary = true;

  final PaymentMethod _paymentMethod = PaymentMethod.momo;
  bool _isProcessing = false;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.currentUserName);
    _passportController = TextEditingController(text: appState.currentUserPassportNumber);
    _emailController = TextEditingController(text: appState.currentUserEmail);
    _phoneController = TextEditingController(text: appState.currentUserPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _embassyFeeUsd => _visaType.contains('Business') ? 160.0 : 90.0;
  double get _serviceFeeUsd => 45.0;
  double get _totalFeeUsd => _embassyFeeUsd + _serviceFeeUsd;
  int get _totalFareRwf => (_totalFeeUsd * 1350).round();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destinationCountry} Visa Application'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryNavy.withValues(alpha: 0.1),
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: primaryNavy.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, color: primaryNavy, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Destination: ${widget.destinationCountry}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryNavy),
                            ),
                            Text(
                              'Applicant Nationality: ${widget.nationality} • Status: Ready to Submit',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Visa Category Choice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. SELECT VISA TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _visaType,
                        decoration: const InputDecoration(labelText: 'Visa Category'),
                        items: const [
                          DropdownMenuItem(value: 'Tourist Short-Stay (30 Days)', child: Text('Tourist Short-Stay (30 Days)')),
                          DropdownMenuItem(value: 'Multiple Entry Tourist (90 Days)', child: Text('Multiple Entry Tourist (90 Days)')),
                          DropdownMenuItem(value: 'Business Express Visa', child: Text('Business Express Visa')),
                          DropdownMenuItem(value: 'Airport Transit Visa', child: Text('Airport Transit Visa')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _visaType = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Personal Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2. APPLICANT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Passport Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passportController,
                        decoration: const InputDecoration(labelText: 'Passport Number'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email Address'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Phone Number'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 3: Document Vault Upload Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('3. DOCUMENT VAULT ATTACHMENTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      _buildDocTile('Passport Scan Page (PDF / JPG)', _hasPassportScan, (v) => setState(() => _hasPassportScan = v ?? false)),
                      _buildDocTile('Recent Biometric Passport Photo', _hasPhoto, (v) => setState(() => _hasPhoto = v ?? false)),
                      _buildDocTile('Bank Statement / Proof of Funds', _hasProofOfFunds, (v) => setState(() => _hasProofOfFunds = v ?? false)),
                      _buildDocTile('Flight & Hotel Reservation Itinerary', _hasFlightItinerary, (v) => setState(() => _hasFlightItinerary = v ?? false)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Fee Breakdown & Payment Method
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('4. ESTIMATED FEE BREAKDOWN & ENQUIRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Government / Embassy Fee:'),
                          Text(appState.formatPrice(_embassyFeeUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Safiri Concierge Processing:'),
                          Text(appState.formatPrice(_serviceFeeUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Total Fee:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            appState.formatPrice(_totalFeeUsd),
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w800, color: primaryNavy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _submitVisaApplication,
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF052469),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    label: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('SUBMIT APPLICATION & SEND ENQUIRY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      secondary: Icon(value ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: value ? const Color(0xFF2E7D32) : Colors.grey),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Future<void> _submitVisaApplication() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final visaId = '#VISA-${9000 + appState.visaApplications.length}';

    try {
      // Record payment attempt or log enquiry in background
      try {
        await _paymentService.createPayment(
          bookingId: visaId,
          customerName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          amount: _totalFareRwf,
          paymentMethod: _paymentMethod.toApiValue(),
        );
      } catch (_) {
        // Non-blocking for enquiry mode
      }

      final newApp = VisaApplicationItem(
        id: visaId,
        destinationCountry: widget.destinationCountry,
        applicantNationality: widget.nationality,
        currentStep: 2, // Application Received, In Concierge Review
        status: 'Enquiry Submitted',
        documentsUploaded: {
          'Passport Scan': _hasPassportScan,
          'Passport Photo': _hasPhoto,
          'Proof of Funds': _hasProofOfFunds,
          'Flight Itinerary': _hasFlightItinerary,
        },
        submittedDate: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      );

      appState.addVisaApplication(newApp);

      if (mounted) {
        Navigator.pop(context); // close wizard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VisaVaultScreen(visaId: visaId)),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visa Application & Enquiry $visaId Submitted Successfully! Safiri Concierge will contact you.'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
