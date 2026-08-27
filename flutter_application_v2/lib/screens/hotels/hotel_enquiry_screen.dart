import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class HotelEnquiryScreen extends StatefulWidget {
  const HotelEnquiryScreen({super.key});

  @override
  State<HotelEnquiryScreen> createState() => _HotelEnquiryScreenState();
}

class _HotelEnquiryScreenState extends State<HotelEnquiryScreen> {
  final _destinationController = TextEditingController(text: 'Santorini Escape, Greece');
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 20));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 27));

  int _rooms = 1;
  int _adults = 2;
  int _children = 0;
  int _infants = 0;

  static const List<String> _popularDestinations = [
    'Santorini Escape, Greece',
    'Paris Luxury Stays, France',
    'Zanzibar Beach Resort, Tanzania',
    'Akagera Safari Lodge, Rwanda',
    'Dubai Marina Villas, UAE',
    'Maldives Overwater Bungalows',
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
            children: [
              // Header matching uploaded UI Image 3
              Text(
                'Plan Your Escape',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover exclusive hotels and curate your perfect holiday experience with our concierge booking service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Form Parameters Container matching Image 3
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
                    // Destination Input
                    const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: 'Where do you want to go? e.g., Paris',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _showDestinationPicker,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Check-in Date
                    const Text('Check-in Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(isCheckIn: true),
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
                              '${_checkInDate.month.toString().padLeft(2, '0')}/${_checkInDate.day.toString().padLeft(2, '0')}/${_checkInDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Check-out Date
                    const Text('Check-out Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(isCheckIn: false),
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
                              '${_checkOutDate.month.toString().padLeft(2, '0')}/${_checkOutDate.day.toString().padLeft(2, '0')}/${_checkOutDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guests & Accommodation Section Header matching Image 3
                    Text(
                      'Guests & Accommodation',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Rooms Stepper matching Image 3
                    _buildStepperTile(
                      title: 'Rooms',
                      subtitle: null,
                      value: _rooms,
                      onMin: _rooms > 1 ? () => setState(() => _rooms--) : null,
                      onAdd: () => setState(() => _rooms++),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 2. Adults Stepper matching Image 3
                    _buildStepperTile(
                      title: 'Adults',
                      subtitle: 'Ages 13 or above',
                      value: _adults,
                      onMin: _adults > 1 ? () => setState(() => _adults--) : null,
                      onAdd: () => setState(() => _adults++),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 3. Children Stepper matching Image 3
                    _buildStepperTile(
                      title: 'Children',
                      subtitle: 'Ages 2 to 12',
                      value: _children,
                      onMin: _children > 0 ? () => setState(() => _children--) : null,
                      onAdd: () => setState(() => _children++),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 4. Infants Stepper matching Image 3
                    _buildStepperTile(
                      title: 'Infants',
                      subtitle: 'Under 2 years',
                      value: _infants,
                      onMin: _infants > 0 ? () => setState(() => _infants--) : null,
                      onAdd: () => setState(() => _infants++),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Send Enquiry CTA Button matching Image 3
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _dispatchEnquiry,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text('Send Enquiry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF052469),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Microcopy Confirmation text matching Image 3
                    Center(
                      child: Text(
                        'One of our concierge agents will contact you within 24 hours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
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

  Widget _buildStepperTile({
    required String title,
    required String? subtitle,
    required int value,
    required VoidCallback? onMin,
    required VoidCallback onAdd,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF2F5FD),
        borderRadius: MajesticHorizonTheme.radiusCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (subtitle != null)
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onMin,
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: onMin != null ? Colors.white : Colors.grey.shade300,
                  foregroundColor: const Color(0xFF052469),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF052469),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Select Popular Destination', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._popularDestinations.map((dest) {
              return ListTile(
                leading: const Icon(Icons.hotel_rounded, color: Color(0xFF052469)),
                title: Text(dest, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() => _destinationController.text = dest);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _selectDate({required bool isCheckIn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 3));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _dispatchEnquiry() {
    final appState = Provider.of<AppState>(context, listen: false);
    final enquiryId = '#ENQ-${8000 + appState.hotelEnquiries.length}';

    final newEnquiry = HotelEnquiryItem(
      id: enquiryId,
      destination: _destinationController.text,
      checkIn: '${_checkInDate.year}-${_checkInDate.month}-${_checkInDate.day}',
      checkOut: '${_checkOutDate.year}-${_checkOutDate.month}-${_checkOutDate.day}',
      rooms: _rooms,
      adults: _adults,
      children: _children,
      infants: _infants,
      status: 'Concierge Assigned',
      submittedTime: 'Just now',
    );

    appState.addHotelEnquiry(newEnquiry);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enquiry Dispatched!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your enquiry ID is $enquiryId.'),
            const SizedBox(height: 8),
            const Text(
              'One of our concierge agents will contact you within 24 hours to present curated options and rates.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return home
              appState.setSelectedTab(1); // Switch to Bookings
            },
            child: const Text('VIEW IN BOOKINGS'),
          ),
        ],
      ),
    );
  }
}
