import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/duffel_api_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'flight_detail_screen.dart';

class FlightResultsScreen extends StatefulWidget {
  final String originCode;
  final String originName;
  final String originCity;
  final String originCountry;
  final String destinationCode;
  final String destinationName;
  final String destinationCity;
  final String destinationCountry;
  final String cabinClass;
  final int passengers;
  final int adults;
  final int children;
  final int infants;
  final bool isOneWay;
  final DateTimeRange travelDates;

  const FlightResultsScreen({
    super.key,
    required this.originCode,
    required this.originName,
    this.originCity = 'Origin',
    this.originCountry = 'Country',
    required this.destinationCode,
    required this.destinationName,
    this.destinationCity = 'Destination',
    this.destinationCountry = 'Country',
    required this.cabinClass,
    required this.passengers,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.isOneWay = true,
    required this.travelDates,
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  String _selectedFilter = 'Best';
  bool _isLoading = true;
  List<DuffelFlightOffer> _offers = [];
  late String _safiriProtocolUrl;
  final Map<String, String> _selectedFareTierMap = {};

  @override
  void initState() {
    super.initState();
    _safiriProtocolUrl = DuffelApiService.buildSafiriHolidaysWebUrl(
      originCode: widget.originCode,
      originCity: widget.originCity,
      originCountry: widget.originCountry,
      destinationCode: widget.destinationCode,
      destinationCity: widget.destinationCity,
      destinationCountry: widget.destinationCountry,
      departureDate: widget.travelDates.start,
      returnDate: widget.isOneWay ? null : widget.travelDates.end,
      adults: widget.adults,
      children: widget.children,
      infants: widget.infants,
      cabinClass: widget.cabinClass,
      isOneWay: widget.isOneWay,
    );
    _fetchDuffelFlightOffers();
  }

  Future<void> _fetchDuffelFlightOffers() async {
    setState(() => _isLoading = true);

    final results = await DuffelApiService.searchFlights(
      originCode: widget.originCode,
      destinationCode: widget.destinationCode,
      departureDate: widget.travelDates.start,
      returnDate: widget.isOneWay ? null : widget.travelDates.end,
      cabinClass: widget.cabinClass,
      passengers: widget.passengers,
      adults: widget.adults,
      children: widget.children,
      infants: widget.infants,
      isOneWay: widget.isOneWay,
    );

    if (mounted) {
      setState(() {
        _offers = results;
        _isLoading = false;
      });
    }
  }

  List<DuffelFlightOffer> get _displayedOffers {
    final list = List<DuffelFlightOffer>.from(_offers);
    if (_selectedFilter == 'Cheapest') {
      list.sort((a, b) => a.priceUsd.compareTo(b.priceUsd));
    } else if (_selectedFilter == 'Fastest') {
      list.sort((a, b) => _parseMinutes(a.duration).compareTo(_parseMinutes(b.duration)));
    }
    return list;
  }

  int _parseMinutes(String duration) {
    final hMatch = RegExp(r'(\d+)h').firstMatch(duration);
    final mMatch = RegExp(r'(\d+)m').firstMatch(duration);
    final h = hMatch != null ? int.parse(hMatch.group(1)!) : 0;
    final m = mMatch != null ? int.parse(mMatch.group(1)!) : 0;
    return h * 60 + m;
  }

  Future<void> _launchSafiriWebUrl() async {
    final uri = Uri.parse(_safiriProtocolUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Protocol URL: $_safiriProtocolUrl')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    final displayed = _displayedOffers;
    final uniqueAirlines = _offers.map((e) => e.airline).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLIGHT TICKETS (flights.safiriholidays.com)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchDuffelFlightOffers,
            tooltip: 'Refresh Live Fares',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Protocol Header Bar matching flights.safiriholidays.com
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFF052469),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'flights.safiriholidays.com Live API Data',
                        style: TextStyle(color: Color(0xFFFED39D), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: _launchSafiriWebUrl,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED39D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.open_in_browser_rounded, size: 12, color: Colors.black87),
                              SizedBox(width: 4),
                              Text('OPEN WEB PORTAL', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'srch: ${widget.originCode}-${widget.originCity}-${widget.originCountry}|${widget.destinationCode}-${widget.destinationCity}-${widget.destinationCountry} • px: ${widget.adults}-${widget.children}-${widget.infants}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),

            // Top Search Summary Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.originCode}  ${widget.isOneWay ? "➔" : "⇄"}  ${widget.destinationCode}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF052469)),
                        tooltip: 'Edit Search',
                      ),
                    ],
                  ),
                  Text(
                    '${widget.travelDates.start.day}/${widget.travelDates.start.month}/${widget.travelDates.start.year} ${widget.isOneWay ? "(One Way)" : "- ${widget.travelDates.end.day}/${widget.travelDates.end.month}/${widget.travelDates.end.year}"} • ${widget.passengers} Pax • ${widget.cabinClass}',
                    style: TextStyle(fontSize: 12, color: textMuted),
                  ),
                  if (!_isLoading && _offers.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF052469).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '✈️ ${displayed.length} Live Flight Tickets Sourced from ${uniqueAirlines.length} Airlines (${uniqueAirlines.take(4).join(", ")})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Best Fares', 'Best'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Cheapest Fares', 'Cheapest'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Fastest Routes', 'Fastest'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Flight Results List matching flights.safiriholidays.com
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFF052469)),
                          SizedBox(height: 16),
                          Text(
                            'Fetching live flight tickets from flights.safiriholidays.com...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : displayed.isEmpty
                      ? const Center(child: Text('No live flight offers found for this route.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayed.length,
                          itemBuilder: (context, index) {
                            final offer = displayed[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildSafiriFlightTicketCard(
                                context: context,
                                offer: offer,
                                cardBg: cardBg,
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF052469) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF052469) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSafiriFlightTicketCard({
    required BuildContext context,
    required DuffelFlightOffer offer,
    required Color cardBg,
    required bool isDark,
  }) {
    final appState = Provider.of<AppState>(context);
    final selectedTierName = _selectedFareTierMap[offer.id] ?? (offer.fareTiers.isNotEmpty ? offer.fareTiers.first.name : 'SAVER');
    
    // Selected tier calculation
    DuffelFareTier? selectedTier;
    if (offer.fareTiers.isNotEmpty) {
      selectedTier = offer.fareTiers.firstWhere((t) => t.name == selectedTierName, orElse: () => offer.fareTiers.first);
    }
    final activePriceUsd = selectedTier != null ? selectedTier.priceUsd : offer.priceUsd;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: MajesticHorizonTheme.radiusCard,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
        boxShadow: isDark ? MajesticHorizonTheme.darkCardShadow : MajesticHorizonTheme.lightCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carrier Header & Timings Box (matching flights.safiriholidays.com)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Carrier Name & Logo Badge
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFF052469).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: offer.airlineLogo.isNotEmpty
                              ? Image.network(
                                  offer.airlineLogo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      offer.airlineCode,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    offer.airlineCode,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.airline,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              offer.flightNumber,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price & "Book Now" Button
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              appState.formatPrice(activePriceUsd),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                            const Text('- Less Fare', style: TextStyle(fontSize: 10, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlightDetailScreen(
                                  offer: offer,
                                  originName: widget.originName,
                                  destinationName: widget.destinationName,
                                  cabinClass: widget.cabinClass,
                                  passengers: widget.passengers,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828), // Official Safiri Red CTA
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Flight Timeline Breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.departureTime,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.originCity, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(offer.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        const SizedBox(
                          width: 80,
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                        Text(
                          offer.stops,
                          style: TextStyle(
                            fontSize: 11,
                            color: offer.stops.toLowerCase().contains('non-stop') ? const Color(0xFF2E7D32) : const Color(0xFF78592E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          offer.arrivalTime,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.destinationCity, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Interactive Fare Tiers Row (SAVER, FLEXIPLUS, INDIGOUPFRONT) matching flights.safiriholidays.com
          if (offer.fareTiers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF8F9FA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: offer.fareTiers.map((tier) {
                    final isSelected = selectedTierName == tier.name;

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2C3954) : const Color(0xFFFFFDE7))
                            : (isDark ? const Color(0xFF141A24) : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFF57F17) : (isDark ? MajesticHorizonTheme.darkBorder : Colors.grey.shade300),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFareTierMap[offer.id] = tier.name;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tier Header Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFF59D) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tier.name,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Selected Indicator & Price Row
                            Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 18,
                                  color: isSelected ? const Color(0xFFF57F17) : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appState.formatPrice(tier.priceUsd),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Features Checkmarks
                            ...tier.features.map((feat) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        feat,
                                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
