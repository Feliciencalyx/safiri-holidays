import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_button.dart';
import '../../../../providers/app_state.dart';
import '../../../../core/services/holiday_api_service.dart';
import '../../../../core/services/notification_service.dart';

class HolidayEnquiryScreen extends StatefulWidget {
  const HolidayEnquiryScreen({super.key});

  @override
  State<HolidayEnquiryScreen> createState() => _HolidayEnquiryScreenState();
}

class _HolidayEnquiryScreenState extends State<HolidayEnquiryScreen> {
  final _destinationController = TextEditingController(text: 'Santorini Escape, Greece');
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 20));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 27));

  int _rooms = 1;
  int _adults = 2;
  int _children = 0;
  int _infants = 0;

  final List<String> _selectedPreferences = ['Beach Resort', 'Breakfast Included'];

  static const List<String> _destinations = [
    'Santorini Escape, Greece',
    'Paris Luxury Stays, France',
    'Zanzibar Beach Resort, Tanzania',
    'Akagera Safari Lodge, Rwanda',
    'Dubai Marina Villas, UAE',
    'Maldives Overwater Bungalows',
  ];

  static const List<String> _prefOptions = [
    'Beach Resort',
    'Safari Lodge',
    'Honeymoon Suite',
    'Breakfast Included',
    'Private Pool',
    'Airport Chauffeur',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.tr('plan_your_escape').toUpperCase()),
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
              Text(
                'Plan Your Escape',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy),
              ),
              const SizedBox(height: 6),
              const Text(
                'Curate your bespoke holiday experience with our concierge booking team.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
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
                    const Text('DESTINATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _selectDestination,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CHECK-IN DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectDate(isCheckIn: true),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${_checkInDate.day}/${_checkInDate.month}/${_checkInDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CHECK-OUT DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectDate(isCheckIn: false),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Guests & Accommodation',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _buildStepper('Rooms', null, _rooms, _rooms > 1 ? () => setState(() => _rooms--) : null, () => setState(() => _rooms++)),
                    const SizedBox(height: 10),
                    _buildStepper('Adults', 'Ages 13+', _adults, _adults > 1 ? () => setState(() => _adults--) : null, () => setState(() => _adults++)),
                    const SizedBox(height: 10),
                    _buildStepper('Children', 'Ages 2 to 12', _children, _children > 0 ? () => setState(() => _children--) : null, () => setState(() => _children++)),
                    const SizedBox(height: 10),
                    _buildStepper('Infants', 'Under 2 years', _infants, _infants > 0 ? () => setState(() => _infants--) : null, () => setState(() => _infants++)),
                    const SizedBox(height: 24),

                    const Text(
                      'Holiday Preferences',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _prefOptions.map((pref) {
                        final isSelected = _selectedPreferences.contains(pref);

                        return FilterChip(
                          label: Text(pref),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPreferences.add(pref);
                              } else {
                                _selectedPreferences.remove(pref);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SafiriButton(
                      text: 'SEND ENQUIRY',
                      onPressed: _dispatchEnquiry,
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'One of our concierge agents will contact you within 24 hours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
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

  Widget _buildStepper(String title, String? subtitle, int val, VoidCallback? onMin, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onMin),
            Text('$val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd),
          ],
        ),
      ],
    );
  }

  void _selectDestination() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: _destinations.map((d) {
            return ListTile(
              title: Text(d),
              onTap: () {
                setState(() => _destinationController.text = d);
                Navigator.pop(context);
              },
            );
          }).toList(),
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
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _dispatchEnquiry() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    final res = await HolidayApiService.submitEnquiry(
      holidayTitle: _destinationController.text,
      customerName: appState.userName,
      email: appState.userEmail,
      phone: appState.userPhone,
      travelDate: '${_checkInDate.year}-${_checkInDate.month.toString().padLeft(2, '0')}-${_checkInDate.day.toString().padLeft(2, '0')}',
      numTravelers: _adults + _children,
      notes: 'Rooms: $_rooms, Prefs: ${_selectedPreferences.join(", ")}',
    );

    final enquiryData = res['enquiry'] ?? {};
    final enquiryId = enquiryData['id'] ?? '#HOL-${7000 + appState.hotelEnquiries.length}';

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

    notificationService.addNotification(
      title: 'Holiday Enquiry Assigned ($enquiryId)',
      body: 'Dedicated concierge agent assigned for ${_destinationController.text}. Expect a callback within 24h.',
      icon: Icons.hotel_rounded,
      color: const Color(0xFF0F4D4A),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Holiday Enquiry Dispatched!'),
          content: Text('Your Enquiry ID is $enquiryId. Our concierge desk will respond within 24 hours.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                appState.setSelectedTab(1);
              },
              child: const Text('VIEW IN BOOKINGS'),
            ),
          ],
        ),
      );
    }
  }
}
