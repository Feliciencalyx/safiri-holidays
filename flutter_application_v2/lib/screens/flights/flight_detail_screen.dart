import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/duffel_api_service.dart';
import '../../core/utils/passport_verifier.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'flight_checkout_modal.dart';

class FlightDetailScreen extends StatefulWidget {
  final DuffelFlightOffer offer;
  final String originName;
  final String destinationName;
  final String cabinClass;
  final int passengers;

  const FlightDetailScreen({
    super.key,
    required this.offer,
    required this.originName,
    required this.destinationName,
    required this.cabinClass,
    required this.passengers,
  });

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  final _enquiryNotesController = TextEditingController();
  bool _isSubmittingEnquiry = false;

  @override
  void dispose() {
    _enquiryNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    final offer = widget.offer;
    final baseFareUsd = (offer.priceUsd * 0.85);
    final taxesUsd = (offer.priceUsd * 0.15);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLIGHT DETAILS & SUMMARY'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner: Route & Airline
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: MajesticHorizonTheme.radiusCard,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F2B5B), Color(0xFF1D3B8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  offer.airline.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '${widget.cabinClass.toUpperCase()} CLASS',
                                style: const TextStyle(color: Color(0xFFFED39D), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.originCode,
                                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  Text(
                                    widget.originName.isNotEmpty ? widget.originName : offer.originCode,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.flight_takeoff_rounded, color: Color(0xFFFED39D), size: 24),
                                  const SizedBox(height: 4),
                                  Text(offer.duration, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                  Text(offer.stops, style: const TextStyle(fontSize: 10, color: Color(0xFFFED39D), fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    offer.destinationCode,
                                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  Text(
                                    widget.destinationName.isNotEmpty ? widget.destinationName : offer.destinationCode,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Flight Segment Timeline Breakdown
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: MajesticHorizonTheme.radiusCard,
                        border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FLIGHT ITINERARY SEGMENTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 14),

                          // Departure Leg
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.flight_takeoff, color: primaryNavy, size: 20),
                                  Container(width: 2, height: 40, color: primaryNavy.withValues(alpha: 0.3)),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Departure: ${offer.departureTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${offer.originCode} • ${widget.originName}', style: TextStyle(fontSize: 12, color: textMuted)),
                                    const Text('Terminal 1 • Check-in opens 3 hours prior', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Flight Segment Details
                          Padding(
                            padding: const EdgeInsets.only(left: 34, bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryNavy.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.airline_seat_recline_normal_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${offer.airline} • Boeing 737 / Airbus A350 • ${offer.duration}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Arrival Leg
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.flight_land, color: primaryNavy, size: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Arrival: ${offer.arrivalTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${offer.destinationCode} • ${widget.destinationName}', style: TextStyle(fontSize: 12, color: textMuted)),
                                    const Text('International Terminal', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fare Inclusions & Baggage Policy
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: MajesticHorizonTheme.radiusCard,
                        border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('INCLUSIONS & BAGGAGE ALLOWANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),
                          _buildInclusionRow(Icons.luggage_rounded, 'Checked Baggage', '2 x 23 kg Included per passenger'),
                          _buildInclusionRow(Icons.work_outline_rounded, 'Cabin Carry-On', '1 x 7 kg + Personal Item'),
                          _buildInclusionRow(Icons.restaurant_rounded, 'In-flight Meals', 'Hot meal & beverages included'),
                          _buildInclusionRow(Icons.wifi_rounded, 'Onboard Entertainment', 'In-seat screen & complimentary WiFi'),
                          _buildInclusionRow(Icons.autorenew_rounded, 'Ticket Rules', 'Change allowed with nominal fee • Non-refundable'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fare Breakdown
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: MajesticHorizonTheme.radiusCard,
                        border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FARE BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Base Airfare (${widget.passengers} Adult):'),
                              Text(appState.formatPrice(baseFareUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Government Taxes & Aviation Fees:'),
                              Text(appState.formatPrice(taxesUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Fare Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                appState.formatPrice(offer.priceUsd),
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF052469)),
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

            // Bottom Dual CTA Bar matching safiriholidays.com
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
                border: Border(top: BorderSide(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Option 1: Send Flight Enquiry / Request Custom Quote
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFlightEnquiryDialog(context, offer),
                          icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF78592E)),
                          label: const Text(
                            'SEND ENQUIRY',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF78592E)),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF78592E), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Option 2: Proceed to Passenger Details & Instant E-Ticket Checkout
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => FlightCheckoutModal(
                                originCode: offer.originCode,
                                originName: widget.originName.isNotEmpty ? widget.originName : offer.originCode,
                                destinationCode: offer.destinationCode,
                                destinationName: widget.destinationName.isNotEmpty ? widget.destinationName : offer.destinationCode,
                                airline: offer.airline,
                                departureTime: offer.departureTime,
                                arrivalTime: offer.arrivalTime,
                                duration: offer.duration,
                                stops: offer.stops,
                                priceUsd: offer.priceUsd,
                              ),
                            );
                          },
                          icon: const Icon(Icons.confirmation_number_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            'BOOK & PAY NOW',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF052469),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusionRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF052469)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFlightEnquiryDialog(BuildContext context, DuffelFlightOffer offer) {
    final appState = Provider.of<AppState>(context, listen: false);
    final passportInfo = PassportVerifierService.verify(appState.currentUserPassportNumber);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Flight Enquiry: ${offer.originCode} ➔ ${offer.destinationCode}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connected User Credential Step Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF052469).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF052469).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF052469), size: 18),
                          const SizedBox(width: 6),
                          const Text('CONNECTED USER CREDENTIALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF052469))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Passenger: ${appState.currentUserName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Email: ${appState.currentUserEmail}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Phone: ${appState.currentUserPhone}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Passport: ${appState.currentUserPassportNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: passportInfo.isValid ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              passportInfo.isValid ? 'VERIFIED' : 'UNVERIFIED',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Submit an enquiry to Safiri Flight Concierge for custom dates, group fares, or special seat holds.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _enquiryNotesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Special Requests / Flexible Dates / Group Info',
                    hintText: 'e.g., Need 4 seats together, preference for aisle seats, or flexible by +/- 2 days',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmittingEnquiry
                  ? null
                  : () async {
                      setDialogState(() => _isSubmittingEnquiry = true);
                      await Future.delayed(const Duration(milliseconds: 600));

                      final enqId = '#ENQ-FLT-${1000 + DateTime.now().millisecond}';
                      appState.addBooking(
                        BookingItem(
                          id: enqId,
                          title: 'Flight Quote Enquiry (${offer.airline} ${offer.originCode}-${offer.destinationCode})',
                          userName: '${appState.currentUserName} (${appState.currentUserPassportNumber})',
                          userTier: 'Verified Concierge Enquiry',
                          status: 'Enquiry Dispatched',
                          type: 'Flight',
                          dateRange: 'Pending Concierge Contact',
                          priceUsd: offer.priceUsd,
                          qrCodeData: '$enqId-ENQUIRY-VERIFIED-${appState.currentUserPassportNumber}',
                        ),
                      );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        appState.setSelectedTab(1); // Switch to Bookings tab

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Flight Enquiry $enqId verified & submitted for ${appState.currentUserName}! Safiri concierges will contact you.'),
                            backgroundColor: const Color(0xFF78592E),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF78592E)),
              child: _isSubmittingEnquiry
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('VERIFY & SUBMIT ENQUIRY'),
            ),
          ],
        ),
      ),
    );
  }
}
