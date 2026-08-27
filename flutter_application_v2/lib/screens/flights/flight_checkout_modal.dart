import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/duffel_api_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/utils/passport_verifier.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class FlightCheckoutModal extends StatefulWidget {
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

  const FlightCheckoutModal({
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
  State<FlightCheckoutModal> createState() => _FlightCheckoutModalState();
}

class _FlightCheckoutModalState extends State<FlightCheckoutModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passportController;
  late TextEditingController _nationalityController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isProcessing = false;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.currentUserName);
    _passportController = TextEditingController(text: appState.currentUserPassportNumber);
    _nationalityController = TextEditingController(text: appState.passportCountry.isNotEmpty ? appState.passportCountry : 'Rwanda');
    _emailController = TextEditingController(text: appState.currentUserEmail);
    _phoneController = TextEditingController(text: appState.currentUserPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  int get _totalFareRwf => (widget.priceUsd * 1350).round();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHECKOUT & E-TICKET ISSUANCE',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Fare: ${appState.formatPrice(widget.priceUsd)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF78592E)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Scrollable Content Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PASSENGER DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Passenger Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passportController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(labelText: 'Passport Number', prefixIcon: Icon(Icons.badge_outlined, size: 18)),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Passport required';
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number'),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Gateway Selection Header
                    const Text('SELECT PAYMENT METHOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),

                    // Method 1: Card
                    _buildPaymentOption(
                      title: PaymentMethod.card.displayName,
                      subtitle: PaymentMethod.card.subtitle,
                      method: PaymentMethod.card,
                      icon: Icons.credit_card_rounded,
                      isDark: isDark,
                    ),

                    // Method 2: MoMo
                    _buildPaymentOption(
                      title: PaymentMethod.momo.displayName,
                      subtitle: PaymentMethod.momo.subtitle,
                      method: PaymentMethod.momo,
                      icon: Icons.phone_android_rounded,
                      isDark: isDark,
                    ),

                    // Method 3: Airtel Money
                    _buildPaymentOption(
                      title: PaymentMethod.airtel.displayName,
                      subtitle: PaymentMethod.airtel.subtitle,
                      method: PaymentMethod.airtel,
                      icon: Icons.phone_android_rounded,
                      isDark: isDark,
                    ),

                    // Method 4: Net Banking
                    _buildPaymentOption(
                      title: PaymentMethod.netbanking.displayName,
                      subtitle: PaymentMethod.netbanking.subtitle,
                      method: PaymentMethod.netbanking,
                      icon: Icons.account_balance_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pay Action CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'PAY ${appState.formatPrice(widget.priceUsd)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required PaymentMethod method,
    required IconData icon,
    required bool isDark,
  }) {
    final selected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? const Color(0xFF052469)
                : (isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
            width: selected ? 2 : 1,
          ),
          borderRadius: MajesticHorizonTheme.radiusCard,
          color: selected
              ? (isDark ? const Color(0xFF0D2554) : const Color(0xFFF0F4FF))
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF052469) : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: selected ? const Color(0xFF052469) : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF052469),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCheckout(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch payment checkout page');
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final bookingId = '#SAF-2026-${1000 + appState.bookings.length}';
    final methodStr = _selectedMethod.toApiValue();

    try {
      // 1. Send Payment Creation request to Safiri Node.js Backend
      final paymentResult = await _paymentService.createPayment(
        bookingId: bookingId,
        customerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        amount: _totalFareRwf,
        paymentMethod: methodStr,
      );

      final checkoutUrl = paymentResult['checkoutUrl'];
      if (checkoutUrl != null && checkoutUrl.toString().isNotEmpty) {
        await _openCheckout(checkoutUrl.toString());
      }

      // 2. Issue Duffel Order & E-Ticket Boarding Pass
      final orderResult = await DuffelApiService.createOrder(
        offerId: 'off_checkout',
        passengerName: _nameController.text,
        passportNumber: _passportController.text,
        nationality: _nationalityController.text,
      );

      final finalBookingId = orderResult['bookingId'] ?? bookingId;
      final qrData = orderResult['qrCodeData'] ?? '$finalBookingId-${widget.originCode}-${widget.destinationCode}-VERIFIED';

      final newPass = BookingItem(
        id: finalBookingId,
        title: '${widget.originCode} ⇄ ${widget.destinationCode} Flight Pass',
        userName: _nameController.text,
        userTier: 'Premium Explorer Tier',
        status: 'Active',
        type: 'Flight',
        dateRange: 'Oct 12 - Oct 26, 2026',
        priceUsd: widget.priceUsd,
        qrCodeData: qrData,
        flightDetails: FlightDetails(
          origin: widget.originName,
          originCode: widget.originCode,
          destination: widget.destinationName,
          destinationCode: widget.destinationCode,
          airline: widget.airline,
          airlineLogo: '',
          departureTime: widget.departureTime,
          arrivalTime: widget.arrivalTime,
          duration: widget.duration,
          stops: widget.stops,
          cabinClass: 'Economy',
          seatNumber: '14A',
        ),
      );

      appState.addBooking(newPass);

      if (mounted) {
        Navigator.pop(context); // Close checkout modal
        Navigator.pop(context); // Close search results

        appState.setSelectedTab(1); // Navigate to My Bookings tab

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Initiated (${_selectedMethod.displayName})! E-Ticket Pass $finalBookingId issued.'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
