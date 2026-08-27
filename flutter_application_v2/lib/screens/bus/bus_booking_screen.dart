import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/payment_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class BusBookingScreen extends StatefulWidget {
  const BusBookingScreen({super.key});

  @override
  State<BusBookingScreen> createState() => _BusBookingScreenState();
}

class _BusBookingScreenState extends State<BusBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _passengerNameController;
  final _phoneController = TextEditingController(text: '+250788000999');

  String _originCity = 'Kigali';
  String _destinationCity = 'Musanze';
  DateTime _travelDate = DateTime.now().add(const Duration(days: 3));
  String _selectedOperator = 'Volcano Express VIP';
  String _selectedSeat = '14B';
  final PaymentMethod _paymentMethod = PaymentMethod.momo;

  bool _isProcessing = false;
  final PaymentService _paymentService = PaymentService();

  static const List<String> _cities = ['Kigali', 'Musanze', 'Rubavu', 'Huye', 'Kampala', 'Nairobi', 'Bujumbura'];

  static const List<Map<String, dynamic>> _operators = [
    {'name': 'Volcano Express VIP', 'time': '08:30 AM', 'priceUsd': 12.0, 'class': 'VIP Executive AC'},
    {'name': 'Alpha Express Luxury', 'time': '10:00 AM', 'priceUsd': 10.0, 'class': 'Standard AC'},
    {'name': 'Horizon Express', 'time': '02:00 PM', 'priceUsd': 9.0, 'class': 'Economy Express'},
    {'name': 'Jaguar Executive Coach', 'time': '08:00 PM', 'priceUsd': 25.0, 'class': 'Sleeper Coach'},
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _passengerNameController = TextEditingController(text: appState.currentUserName);
  }

  @override
  void dispose() {
    _passengerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _currentPriceUsd {
    final op = _operators.firstWhere((o) => o['name'] == _selectedOperator, orElse: () => _operators.first);
    return (op['priceUsd'] as double);
  }

  int get _currentFareRwf => (_currentPriceUsd * 1350).round();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safiri Bus & Express Booking'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner matching safiriholidays.com Bus section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: MajesticHorizonTheme.radiusCard,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F4D4A), Color(0xFF177A75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_filled_rounded, size: 40, color: Colors.white),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('BEST DEALS ON BUS TICKETS', style: TextStyle(color: Color(0xFFFED39D), fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('Luxury & Executive Coaches', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('No convenience fee • Instant QR Boarding Pass', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step 1: Route Selection
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
                      const Text('1. ROUTE & TRAVEL DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _originCity,
                              decoration: const InputDecoration(labelText: 'From City'),
                              items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _originCity = v);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.sync_alt_rounded, color: Colors.grey),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _destinationCity,
                              decoration: const InputDecoration(labelText: 'To City'),
                              items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _destinationCity = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickTravelDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                            borderRadius: MajesticHorizonTheme.radiusInput,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Travel Date: ${_travelDate.year}-${_travelDate.month.toString().padLeft(2, '0')}-${_travelDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Step 2: Bus Operator Selection
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
                      const Text('2. SELECT OPERATOR & SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      ..._operators.map((op) {
                        final selected = _selectedOperator == op['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedOperator = op['name']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected ? (isDark ? const Color(0xFF0D2554) : const Color(0xFFF0F4FF)) : Colors.transparent,
                              borderRadius: MajesticHorizonTheme.radiusCard,
                              border: Border.all(
                                color: selected ? const Color(0xFF052469) : (isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(op['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? const Color(0xFF052469) : null)),
                                    Text('${op['time']} • ${op['class']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                Text(
                                  appState.formatPrice(op['priceUsd'] as double),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF78592E)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Step 3: Interactive Seat Selection
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('3. SEAT SELECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text('Selected: $_selectedSeat', style: TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seat Grid Display
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ['04A', '08B', '12A', '14B', '15A', '18C', '20D'].map((seat) {
                          final isSelected = _selectedSeat == seat;
                          return ChoiceChip(
                            selected: isSelected,
                            avatar: Icon(Icons.chair_rounded, size: 16, color: isSelected ? Colors.white : primaryNavy),
                            label: Text(seat),
                            onSelected: (val) => setState(() => _selectedSeat = seat),
                            selectedColor: const Color(0xFF052469),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Step 4: Passenger Info
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
                      const Text('4. PASSENGER INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passengerNameController,
                        decoration: const InputDecoration(labelText: 'Full Passenger Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number (SMS E-Ticket)'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step 5: Pay & Issue Bus E-Ticket
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processBusBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF052469),
                    ),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('PAY ${appState.formatPrice(_currentPriceUsd)} & ISSUE TICKET', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickTravelDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  Future<void> _processBusBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final busId = '#BUS-2026-${1000 + appState.busBookings.length}';

    try {
      await _paymentService.createPayment(
        bookingId: busId,
        customerName: _passengerNameController.text,
        email: appState.currentUserEmail,
        phone: _phoneController.text,
        amount: _currentFareRwf,
        paymentMethod: _paymentMethod.toApiValue(),
      );

      final newBusBooking = BusBookingItem(
        id: busId,
        routeName: '$_originCity ➔ $_destinationCity Express',
        operatorName: _selectedOperator,
        travelDate: '${_travelDate.year}-${_travelDate.month}-${_travelDate.day}',
        departureTime: '08:30 AM',
        seatNumber: _selectedSeat,
        priceUsd: _currentPriceUsd,
        passengerName: _passengerNameController.text,
        phone: _phoneController.text,
        status: 'Confirmed',
        qrCodeData: '$busId-$_originCity-$_destinationCity-$_selectedSeat',
      );

      appState.addBusBooking(newBusBooking);

      // Also add to My Bookings tab list
      final newPass = BookingItem(
        id: busId,
        title: '$_originCity ➔ $_destinationCity Bus Ticket (Seat $_selectedSeat)',
        userName: _passengerNameController.text,
        userTier: 'Premium Explorer',
        status: 'Active',
        type: 'Bus',
        dateRange: '${_travelDate.year}-${_travelDate.month}-${_travelDate.day}',
        priceUsd: _currentPriceUsd,
        qrCodeData: '$busId-$_selectedSeat-VERIFIED',
      );
      appState.addBooking(newPass);

      if (mounted) {
        Navigator.pop(context); // close screen
        appState.setSelectedTab(1); // switch to bookings tab

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bus Ticket $busId Confirmed! Boarding Pass saved to Bookings.'),
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
}
