import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class VisaTrackerWidget extends StatelessWidget {
  final VisaApplicationItem visaApp;

  const VisaTrackerWidget({
    super.key,
    required this.visaApp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

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
              Text(
                'VISA APP ${visaApp.id}',
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF78592E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  visaApp.status.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF78592E), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${visaApp.applicantNationality} ➔ ${visaApp.destinationCountry}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Text('Submitted on ${visaApp.submittedDate}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 16),

          // 4-Stage Audit Tracker Horizontal Stepper
          Row(
            children: [
              _buildStepNode('Destination', 1, visaApp.currentStep, primaryNavy),
              _buildStepLine(1, visaApp.currentStep, primaryNavy),
              _buildStepNode('Consultation', 2, visaApp.currentStep, primaryNavy),
              _buildStepLine(2, visaApp.currentStep, primaryNavy),
              _buildStepNode('Documents', 3, visaApp.currentStep, primaryNavy),
              _buildStepLine(3, visaApp.currentStep, primaryNavy),
              _buildStepNode('Review', 4, visaApp.currentStep, primaryNavy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(String title, int stepIndex, int activeStep, Color primaryNavy) {
    final isCompleted = stepIndex < activeStep;
    final isCurrent = stepIndex == activeStep;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isCompleted || isCurrent ? primaryNavy : Colors.grey.shade300,
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepIndex',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? primaryNavy : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int fromStep, int activeStep, Color primaryNavy) {
    final isPassed = fromStep < activeStep;

    return SizedBox(
      width: 20,
      child: Divider(
        color: isPassed ? primaryNavy : Colors.grey.shade300,
        thickness: 2,
      ),
    );
  }
}
