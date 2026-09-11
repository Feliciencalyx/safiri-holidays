import 'package:material_ui/material_ui.dart';
import '../../theme/app_theme.dart';
import 'visa_application_wizard_screen.dart';

class VisaEligibilityScreen extends StatefulWidget {
  const VisaEligibilityScreen({super.key});

  @override
  State<VisaEligibilityScreen> createState() => _VisaEligibilityScreenState();
}

class _VisaEligibilityScreenState extends State<VisaEligibilityScreen> {
  String? _selectedDestination = 'France (Schengen Area)';
  String? _selectedNationality = 'Rwanda';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safiri Holidays'),
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
              // Header Title matching Image 9
              Text(
                'Start Your Journey',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Navigating global entry requirements made seamless. Tell us where you want to go.',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
              const SizedBox(height: 20),

              // 4-Stage Stepper Bar matching Image 9
              Row(
                children: [
                  _buildStepBubble('1', 'Destination', true, primaryNavy),
                  _buildStepDivider(true, primaryNavy),
                  _buildStepBubble('2', 'Consultation', false, primaryNavy),
                  _buildStepDivider(false, primaryNavy),
                  _buildStepBubble('3', 'Documents', false, primaryNavy),
                  _buildStepDivider(false, primaryNavy),
                  _buildStepBubble('4', 'Review', false, primaryNavy),
                ],
              ),
              const SizedBox(height: 24),

              // Main Visa Application Form Card matching Image 9
              Container(
                padding: const EdgeInsets.all(20),
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
                    Text(
                      'Visa Application Eligibility',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Destination Country Dropdown
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Destination Country', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDestination,
                      decoration: const InputDecoration(
                        hintText: 'Select country of desired destination',
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(value: country, child: Text(country));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDestination = val),
                    ),
                    const SizedBox(height: 18),

                    // Applicant Nationality Dropdown
                    Row(
                      children: const [
                        Icon(Icons.public_rounded, size: 18, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Applicant Nationality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedNationality,
                      decoration: const InputDecoration(
                        hintText: 'Select your current nationality',
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(value: country, child: Text(country));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedNationality = val),
                    ),
                    const SizedBox(height: 20),

                    // Info Card matching Image 9
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E283C) : const Color(0xFFEEF3FE),
                        borderRadius: MajesticHorizonTheme.radiusCard,
                        border: Border.all(
                          color: isDark ? const Color(0xFF2C3C5A) : const Color(0xFFC7D7FD),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: primaryNavy, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Checking availability will send an enquiry to our concierge team. An admin will contact you shortly to begin the consultation phase.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bottom Action Row matching Image 9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton.icon(
                          onPressed: _submitVisaEligibility,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Check Availability'),
                        ),
                      ],
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

  Widget _buildStepBubble(String number, String label, bool isActive, Color primaryNavy) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primaryNavy : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? primaryNavy : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? primaryNavy : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isCompleted, Color primaryNavy) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? primaryNavy : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }

  void _submitVisaEligibility() {
    if (_selectedDestination != null && _selectedNationality != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisaApplicationWizardScreen(
            destinationCountry: _selectedDestination!,
            nationality: _selectedNationality!,
          ),
        ),
      );
    }
  }
}
