import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/passport_verifier.dart';
import '../../../../core/widgets/safiri_button.dart';
import '../../../../providers/app_state.dart';
import '../../../../screens/flights/flight_checkout_modal.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final String originCode;
  final String originName;
  final String destinationCode;
  final String destinationName;
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String stops;
  final double priceUsd;

  const PassengerDetailsScreen({
    super.key,
    required this.originCode,
    required this.originName,
    required this.destinationCode,
    required this.destinationName,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.priceUsd,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passportController;
  late TextEditingController _nationalityController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final nameParts = appState.currentUserName.split(' ');
    _firstNameController = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastNameController = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    _passportController = TextEditingController(text: appState.currentUserPassportNumber);
    _nationalityController = TextEditingController(text: appState.passportCountry.isNotEmpty ? appState.passportCountry : 'Rwanda');
    _emailController = TextEditingController(text: appState.currentUserEmail);
    _phoneController = TextEditingController(text: appState.currentUserPhone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PASSENGER DETAILS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight Summary Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.originCode} ⇄ ${widget.destinationCode}',
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            widget.airline,
                            style: const TextStyle(fontSize: 12, color: AppColors.darkAccentGold),
                          ),
                        ],
                      ),
                      Text(
                        '\$${widget.priceUsd.toStringAsFixed(0)}',
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Form Card
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
                      const Text(
                        'Primary Passenger Information',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(labelText: 'First Name'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(labelText: 'Last Name'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passportController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(labelText: 'Passport Number'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final res = PassportVerifierService.verify(v);
                                if (!res.isValid) return res.errorMessage ?? 'Invalid passport';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nationalityController,
                              decoration: const InputDecoration(labelText: 'Nationality'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email Address'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      SafiriButton(
                        text: 'PROCEED TO PAYMENT',
                        onPressed: _navigateToCheckout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCheckout() {
    if (_formKey.currentState!.validate()) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => FlightCheckoutModal(
          originCode: widget.originCode,
          originName: widget.originName,
          destinationCode: widget.destinationCode,
          destinationName: widget.destinationName,
          airline: widget.airline,
          departureTime: widget.departureTime,
          arrivalTime: widget.arrivalTime,
          duration: widget.duration,
          stops: widget.stops,
          priceUsd: widget.priceUsd,
        ),
      );
    }
  }
}
