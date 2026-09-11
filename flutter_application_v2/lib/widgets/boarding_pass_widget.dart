import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../core/widgets/safiri_logo.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class BoardingPassWidget extends StatelessWidget {
  final BookingItem booking;

  const BoardingPassWidget({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = booking.flightDetails;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard,
        borderRadius: MajesticHorizonTheme.radiusHero,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
        boxShadow: isDark ? MajesticHorizonTheme.darkCardShadow : MajesticHorizonTheme.lightCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Navy Banner matching uploaded UI
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF052469),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BOOKING ID: ${booking.id}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF052469),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking.title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          booking.userTier,
                          style: const TextStyle(
                            color: Color(0xFFFED39D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SafiriLogo(
                      size: 24,
                      isHorizontal: true,
                      isDarkBackground: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Flight Itinerary Body if available
          if (details != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.originCode,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            details.origin,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.departureTime,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            details.duration,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.circle, size: 6, color: Color(0xFF052469)),
                              SizedBox(
                                width: 50,
                                child: Divider(color: Color(0xFF052469), thickness: 1.5),
                              ),
                              Icon(Icons.flight_takeoff_rounded, size: 16, color: Color(0xFF052469)),
                              SizedBox(
                                width: 50,
                                child: Divider(color: Color(0xFF052469), thickness: 1.5),
                              ),
                              Icon(Icons.circle, size: 6, color: Color(0xFF052469)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.stops,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF78592E), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            details.destinationCode,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            details.destination,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.arrivalTime,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPassDetailColumn('SEAT', details.seatNumber),
                      _buildPassDetailColumn('CLASS', details.cabinClass),
                      _buildPassDetailColumn('GATE', 'B14'),
                      _buildPassDetailColumn('PRICE', appState.formatPrice(booking.priceUsd)),
                    ],
                  ),
                ],
              ),
            ),

          // Tear Line Divider
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : (isDark ? Colors.white24 : Colors.black12),
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Bottom QR Verification Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                QrImageView(
                  data: booking.qrCodeData,
                  version: QrVersions.auto,
                  size: 70.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Digital E-Ticket Pass',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Scan QR code at VIP lounge entry & terminal check-in counter.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showEticketPdfModal(context, booking),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                        label: const Text('Download E-Ticket (PDF)', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showEticketPdfModal(BuildContext context, BookingItem booking) {
    final appState = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Official E-Ticket Document',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SafiriLogo(
                              size: 30,
                              isHorizontal: true,
                              showTagline: false,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF052469).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF052469)),
                              ),
                              child: Text(
                                'OFFICIAL E-TICKET #${booking.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Color(0xFF052469),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PASSENGER NAME', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text(booking.userName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(appState.tr('pnr_code'), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text('WB-${booking.id.replaceAll('#SAF-2026-', '')}9X', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF052469))),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        const Text('ITINERARY & CABIN ALLOWANCE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(booking.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
                        Text('Travel Period: ${booking.dateRange}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.luggage_rounded, size: 14, color: Color(0xFF78592E)),
                            const SizedBox(width: 6),
                            Text(appState.tr('baggage_policy'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78592E))),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade600),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 4),
                                  Text(appState.tr('payment_verified'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                ],
                              ),
                            ),
                            Text(
                              'FARE: ${appState.formatPrice(booking.priceUsd)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: QrImageView(
                            data: booking.qrCodeData,
                            version: QrVersions.auto,
                            size: 130.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Notice: Present this e-ticket along with your original valid passport at the airport check-in desk. Issued under Safiri Holidays Concierge Policy.',
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('E-Ticket #${booking.id} sent to your printer queue!'),
                            backgroundColor: const Color(0xFF052469),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('PRINT E-TICKET', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloaded E-Ticket PDF for ${booking.id} to Device Vault!'),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('SAVE PDF', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
