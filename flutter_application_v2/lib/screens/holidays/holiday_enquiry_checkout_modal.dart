import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/payment_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class HolidayEnquiryCheckoutModal extends StatefulWidget {
  final HolidayPackageItem packageItem;

  const HolidayEnquiryCheckoutModal({
    super.key,
    required this.packageItem,
  });

  @override
  State<HolidayEnquiryCheckoutModal> createState() => _HolidayEnquiryCheckoutModalState();
}

class _HolidayEnquiryCheckoutModalState extends State<HolidayEnquiryCheckoutModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _emailController = TextEditingController(text: 'violet.nabise@safiri.com');
  final _phoneController = TextEditingController(text: '+250788000123');
  final _notesController = TextEditingController(text: 'Interested in vegetarian meal options & airport pick-up');

  DateTime _travelDate = DateTime.now().add(const Duration(days: 30));
  int _adults = 2;
  int _children = 0;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.momo;
  bool _isProcessing = false;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.currentUserName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPriceUsd => widget.packageItem.priceUsd * _adults + (widget.packageItem.priceUsd * 0.6 * _children);
  double get _depositPriceUsd => _totalPriceUsd * 0.20; // 20% booking deposit
  int get _depositFareRwf => (_depositPriceUsd * 1350).round();

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
                    Text(
                      widget.packageItem.title,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: ${appState.formatPrice(_totalPriceUsd)} (Deposit 20%: ${appState.formatPrice(_depositPriceUsd)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF78592E)),
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 4: Travelers & Preferred Dates
                    const Text('1. TRAVEL DATES & PASSENGER COUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: _pickTravelDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                          borderRadius: MajesticHorizonTheme.radiusInput,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Departure Date: ${_travelDate.year}-${_travelDate.month.toString().padLeft(2, '0')}-${_travelDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildCounterTile('Adults (12+)', _adults, () => setState(() => _adults > 1 ? _adults-- : null), () => setState(() => _adults++), isDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCounterTile('Children (2-11)', _children, () => setState(() => _children > 0 ? _children-- : null), () => setState(() => _children++), isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Primary Contact Details
                    const Text('2. TRAVELER CONTACT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Contact Name'),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Custom Notes / Preferences'),
                    ),
                    const SizedBox(height: 18),

                    // Payment Method for Deposit
                    const Text('3. SELECT PAYMENT METHOD (20% DEPOSIT)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildPaymentTile('MTN Mobile Money', 'Instant USSD Push prompt', PaymentMethod.momo, isDark),
                    _buildPaymentTile('Airtel Money', 'Airtel Pay push prompt', PaymentMethod.airtel, isDark),
                    _buildPaymentTile('Credit / Debit Card', 'Visa, Mastercard, Amex', PaymentMethod.card, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dual CTA Action Row: Deposit Payment vs Custom Quote Enquiry
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _sendCustomQuoteEnquiry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF052469), width: 1.5),
                    ),
                    child: const Text('SEND QUOTE ENQUIRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _payDepositBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF052469),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('PAY DEPOSIT (${appState.formatPrice(_depositPriceUsd)})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterTile(String title, int value, VoidCallback onMin, VoidCallback onAdd, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF2F5FD),
        borderRadius: MajesticHorizonTheme.radiusCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Row(
            children: [
              InkWell(onTap: onMin, child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF052469))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              InkWell(onTap: onAdd, child: const Icon(Icons.add_circle, size: 20, color: Color(0xFF052469))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String title, String subtitle, PaymentMethod method, bool isDark) {
    final selected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF052469) : (isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
            width: selected ? 2 : 1,
          ),
          borderRadius: MajesticHorizonTheme.radiusCard,
          color: selected ? (isDark ? const Color(0xFF0D2554) : const Color(0xFFF0F4FF)) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(Icons.payment_rounded, size: 18, color: selected ? const Color(0xFF052469) : Colors.grey),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? const Color(0xFF052469) : null)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickTravelDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  Future<void> _payDepositBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final bookingId = '#HOL-2026-${1000 + appState.holidayEnquiries.length}';

    try {
      await _paymentService.createPayment(
        bookingId: bookingId,
        customerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        amount: _depositFareRwf,
        paymentMethod: _selectedPaymentMethod.toApiValue(),
      );

      final item = HolidayEnquiryBookingItem(
        id: bookingId,
        packageTitle: widget.packageItem.title,
        destination: widget.packageItem.destination,
        duration: widget.packageItem.duration,
        adults: _adults,
        children: _children,
        travelDate: '${_travelDate.year}-${_travelDate.month}-${_travelDate.day}',
        priceUsd: _totalPriceUsd,
        status: 'Deposit Paid (20%)',
        submittedTime: 'Just now',
        type: 'Direct Deposit',
      );

      appState.addHolidayEnquiry(item);

      if (mounted) {
        Navigator.pop(context); // close modal
        Navigator.pop(context); // close detail
        Navigator.pop(context); // close list
        appState.setSelectedTab(1); // switch to bookings

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Holiday Booking Deposit Paid ($bookingId)! Saved to Bookings.'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _sendCustomQuoteEnquiry() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final enquiryId = '#HOL-ENQ-${7000 + appState.holidayEnquiries.length}';

    final item = HolidayEnquiryBookingItem(
      id: enquiryId,
      packageTitle: widget.packageItem.title,
      destination: widget.packageItem.destination,
      duration: widget.packageItem.duration,
      adults: _adults,
      children: _children,
      travelDate: '${_travelDate.year}-${_travelDate.month}-${_travelDate.day}',
      priceUsd: _totalPriceUsd,
      status: 'Custom Quote Requested',
      submittedTime: 'Just now',
      type: 'Custom Quote',
    );

    appState.addHolidayEnquiry(item);

    Navigator.pop(context); // close modal
    Navigator.pop(context); // close detail
    Navigator.pop(context); // close list
    appState.setSelectedTab(1); // switch to bookings

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom Quote Request Sent ($enquiryId)! Specialist will respond within 24h.'),
        backgroundColor: const Color(0xFF052469),
      ),
    );
  }
}
