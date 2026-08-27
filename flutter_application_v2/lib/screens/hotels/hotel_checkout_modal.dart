import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/payment_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class HotelCheckoutModal extends StatefulWidget {
  final HotelCatalogItem hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int adults;
  final double totalPriceUsd;

  const HotelCheckoutModal({
    super.key,
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.totalPriceUsd,
  });

  @override
  State<HotelCheckoutModal> createState() => _HotelCheckoutModalState();
}

class _HotelCheckoutModalState extends State<HotelCheckoutModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _emailController = TextEditingController(text: 'violet.nabise@safiri.com');
  final _phoneController = TextEditingController(text: '+250788000123');
  final _specialRequestsController = TextEditingController(text: 'High floor, quiet room away from elevator');

  String _selectedRoomCategory = 'Deluxe Suite with Breakfast';
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
    _specialRequestsController.dispose();
    super.dispose();
  }

  int get _totalFareRwf => (widget.totalPriceUsd * 1350).round();

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
            // Modal Title & Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.name,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Price: ${appState.formatPrice(widget.totalPriceUsd)}',
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

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 3: Room Type Choice
                    const Text('1. SELECT ROOM CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildRoomOption('Standard Villa (King Bed)', 'Free WiFi • City View', widget.totalPriceUsd * 0.85, isDark),
                    _buildRoomOption('Deluxe Suite with Breakfast', 'Free WiFi • Breakfast • Ocean/Sky View', widget.totalPriceUsd, isDark),
                    _buildRoomOption('Executive Presidential Suite', 'All-Inclusive • Jacuzzi • Butler Service', widget.totalPriceUsd * 1.4, isDark),
                    const SizedBox(height: 18),

                    // Step 4: Primary Guest Details
                    const Text('2. PRIMARY GUEST DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Guest Name'),
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
                      controller: _specialRequestsController,
                      decoration: const InputDecoration(labelText: 'Special Requests / Preferences'),
                    ),
                    const SizedBox(height: 18),

                    // Step 5: Select Payment Method
                    const Text('3. SELECT PAYMENT METHOD (INSTANT RESERVATION)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildPaymentTile('MTN Mobile Money', 'USSD Push prompt on phone', PaymentMethod.momo, Icons.phone_android_rounded, isDark),
                    _buildPaymentTile('Airtel Money', 'Airtel Pay push prompt', PaymentMethod.airtel, Icons.phone_android_rounded, isDark),
                    _buildPaymentTile('Credit / Debit Card', 'Visa, Mastercard, Amex', PaymentMethod.card, Icons.credit_card_rounded, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dual CTA Buttons: Instant Pay vs Concierge Enquiry
            Row(
              children: [
                // Button 1: Send Enquiry
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _sendHotelEnquiry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF052469), width: 1.5),
                    ),
                    child: const Text('SEND ENQUIRY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),

                // Button 2: Pay & Book Now
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processInstantBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF052469),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('PAY ${appState.formatPrice(widget.totalPriceUsd)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomOption(String title, String subtitle, double priceUsd, bool isDark) {
    final selected = _selectedRoomCategory == title;
    final appState = Provider.of<AppState>(context, listen: false);

    return GestureDetector(
      onTap: () => setState(() => _selectedRoomCategory = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF052469) : (isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
            width: selected ? 2 : 1,
          ),
          borderRadius: MajesticHorizonTheme.radiusCard,
          color: selected ? (isDark ? const Color(0xFF0D2554) : const Color(0xFFF0F4FF)) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? const Color(0xFF052469) : null)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            Text(
              appState.formatPrice(priceUsd),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF78592E)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String title, String subtitle, PaymentMethod method, IconData icon, bool isDark) {
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
            Icon(icon, size: 20, color: selected ? const Color(0xFF052469) : Colors.grey),
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

  Future<void> _processInstantBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final bookingId = '#HTL-2026-${1000 + appState.bookings.length}';

    try {
      await _paymentService.createPayment(
        bookingId: bookingId,
        customerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        amount: _totalFareRwf,
        paymentMethod: _selectedPaymentMethod.toApiValue(),
      );

      final newPass = BookingItem(
        id: bookingId,
        title: '${widget.hotel.name} (${widget.rooms} Rooms)',
        userName: _nameController.text,
        userTier: 'Premium Explorer',
        status: 'Active',
        type: 'Hotel',
        dateRange: '${widget.checkIn.month}/${widget.checkIn.day} - ${widget.checkOut.month}/${widget.checkOut.day}, 2026',
        priceUsd: widget.totalPriceUsd,
        qrCodeData: '$bookingId-${widget.hotel.id}-VERIFIED',
      );

      appState.addBooking(newPass);

      if (mounted) {
        Navigator.pop(context); // close modal
        Navigator.pop(context); // close list screen
        appState.setSelectedTab(1); // switch to bookings tab

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hotel Reservation Confirmed ($bookingId)! Saved to Bookings.'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _sendHotelEnquiry() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final enquiryId = '#ENQ-${8000 + appState.hotelEnquiries.length}';

    final enquiry = HotelEnquiryItem(
      id: enquiryId,
      destination: widget.hotel.destination,
      checkIn: '${widget.checkIn.year}-${widget.checkIn.month}-${widget.checkIn.day}',
      checkOut: '${widget.checkOut.year}-${widget.checkOut.month}-${widget.checkOut.day}',
      rooms: widget.rooms,
      adults: widget.adults,
      children: 0,
      infants: 0,
      status: 'Concierge Assigned',
      submittedTime: 'Just now',
      hotelName: widget.hotel.name,
      roomType: _selectedRoomCategory,
      priceUsd: widget.totalPriceUsd,
    );

    appState.addHotelEnquiry(enquiry);

    Navigator.pop(context); // close modal
    Navigator.pop(context); // close list
    appState.setSelectedTab(1); // switch to bookings

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enquiry Dispatched ($enquiryId)! Concierge assigned within 24h.'),
        backgroundColor: const Color(0xFF052469),
      ),
    );
  }
}
