import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/duffel_api_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  bool _isOneWay = true;
  String _originCode = 'KGL';
  String _originName = 'Kigali International Airport (KGL)';
  String _originCity = 'Kigali';
  String _originCountry = 'Rwanda';

  String _destinationCode = 'KME';
  String _destinationName = 'Kamembe International Airport (KME)';
  String _destinationCity = 'Cyangugu / Rusizi';
  String _destinationCountry = 'Rwanda';

  String _cabinClass = 'Economy';
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  DateTimeRange _travelDates = DateTimeRange(
    start: DateTime.now().add(const Duration(days: 14)),
    end: DateTime.now().add(const Duration(days: 28)),
  );

  int get _totalPassengers => _adults + _children + _infants;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safiri Flight Search Engine'),
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
              // Header Intro Banner with Web Engine Protocol Tag
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryNavy.withValues(alpha: 0.08),
                  borderRadius: MajesticHorizonTheme.radiusCard,
                  border: Border.all(color: primaryNavy.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flight_takeoff_rounded, color: primaryNavy, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'flights.safiriholidays.com Web Search Engine',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Search live airline fares using official safiriholidays.com web search protocol.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Segmented Trip Type Toggle (One Way vs Round Trip)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: _isOneWay,
                      label: const Center(child: Text('ONE WAY')),
                      onSelected: (val) => setState(() => _isOneWay = true),
                      selectedColor: primaryNavy,
                      labelStyle: TextStyle(color: _isOneWay ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      selected: !_isOneWay,
                      label: const Center(child: Text('ROUND TRIP')),
                      onSelected: (val) => setState(() => _isOneWay = false),
                      selectedColor: primaryNavy,
                      labelStyle: TextStyle(color: !_isOneWay ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Inputs Card
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
                    // Origin Airport
                    Text(appState.tr('origin'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectAirport(isOrigin: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                          borderRadius: MajesticHorizonTheme.radiusInput,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF052469)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _originName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Swap Button
                    Center(
                      child: IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            final tempCode = _originCode;
                            final tempName = _originName;
                            final tempCity = _originCity;
                            final tempCountry = _originCountry;

                            _originCode = _destinationCode;
                            _originName = _destinationName;
                            _originCity = _destinationCity;
                            _originCountry = _destinationCountry;

                            _destinationCode = tempCode;
                            _destinationName = tempName;
                            _destinationCity = tempCity;
                            _destinationCountry = tempCountry;
                          });
                        },
                        icon: const Icon(Icons.swap_vert_rounded),
                        tooltip: 'Swap Airports',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Destination Airport
                    Text(appState.tr('destination'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectAirport(isOrigin: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                          borderRadius: MajesticHorizonTheme.radiusInput,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flight_land_rounded, color: Color(0xFF78592E)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _destinationName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Travel Dates Range
                    Text(
                      _isOneWay ? 'DEPARTURE DATE' : 'TRAVEL DATES (DEPARTURE - RETURN)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                          borderRadius: MajesticHorizonTheme.radiusInput,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _isOneWay
                                  ? '${_travelDates.start.day}/${_travelDates.start.month}/${_travelDates.start.year}'
                                  : '${_travelDates.start.day}/${_travelDates.start.month}/${_travelDates.start.year}  →  ${_travelDates.end.day}/${_travelDates.end.month}/${_travelDates.end.year}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Cabin Class & Passengers Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appState.tr('cabin_class'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _cabinClass,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: MajesticHorizonTheme.radiusInput,
                                    borderSide: BorderSide(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: MajesticHorizonTheme.radiusInput,
                                    borderSide: BorderSide(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                                  ),
                                ),
                                items: ['Economy', 'Premium Economy', 'Business', 'First'].map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _cabinClass = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PASSENGERS (PX)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _showPassengersModal,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder),
                                    borderRadius: MajesticHorizonTheme.radiusInput,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$_adults-$_children-$_infants ($_totalPassengers Pax)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const Icon(Icons.arrow_drop_down, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlightResultsScreen(
                                originCode: _originCode,
                                originName: _originName,
                                originCity: _originCity,
                                originCountry: _originCountry,
                                destinationCode: _destinationCode,
                                destinationName: _destinationName,
                                destinationCity: _destinationCity,
                                destinationCountry: _destinationCountry,
                                cabinClass: _cabinClass,
                                passengers: _totalPassengers,
                                adults: _adults,
                                children: _children,
                                infants: _infants,
                                isOneWay: _isOneWay,
                                travelDates: _travelDates,
                              ),
                            ),
                          );
                        },
                        child: Text(appState.tr('search_flights').toUpperCase()),
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

  void _showPassengersModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PASSENGERS (PX)', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPassengerCounterRow('Adults (12+ yrs)', _adults, (val) {
                if (val >= 1) {
                  setState(() => _adults = val);
                  setModalState(() {});
                }
              }),
              _buildPassengerCounterRow('Children (2-12 yrs)', _children, (val) {
                if (val >= 0) {
                  setState(() => _children = val);
                  setModalState(() {});
                }
              }),
              _buildPassengerCounterRow('Infants (under 2 yrs)', _infants, (val) {
                if (val >= 0 && val <= _adults) {
                  setState(() => _infants = val);
                  setModalState(() {});
                }
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CONFIRM PASSENGERS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerCounterRow(String title, int count, Function(int) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: [
              IconButton.outlined(
                onPressed: () => onChange(count - 1),
                icon: const Icon(Icons.remove, size: 18),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              IconButton.outlined(
                onPressed: () => onChange(count + 1),
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAirport({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _AirportSearchModal(
          isOrigin: isOrigin,
          onSelected: (code, fullName, city, country) {
            setState(() {
              if (isOrigin) {
                _originCode = code;
                _originName = fullName;
                _originCity = city;
                _originCountry = country;
              } else {
                _destinationCode = code;
                _destinationName = fullName;
                _destinationCity = city;
                _destinationCountry = country;
              }
            });
          },
        );
      },
    );
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _travelDates,
    );
    if (picked != null) {
      setState(() => _travelDates = picked);
    }
  }
}

class _AirportSearchModal extends StatefulWidget {
  final bool isOrigin;
  final Function(String code, String fullName, String city, String country) onSelected;

  const _AirportSearchModal({
    required this.isOrigin,
    required this.onSelected,
  });

  @override
  State<_AirportSearchModal> createState() => _AirportSearchModalState();
}

class _AirportSearchModalState extends State<_AirportSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _airports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAirports('');
  }

  Future<void> _fetchAirports(String query) async {
    setState(() => _isLoading = true);
    final results = await DuffelApiService.searchAirports(query);
    if (mounted) {
      setState(() {
        _airports = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isOrigin ? 'Select Origin Airport' : 'Select Destination Airport',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _searchController,
            onChanged: (val) => _fetchAirports(val),
            decoration: InputDecoration(
              hintText: 'Search city, airport or code (e.g. Delhi, DEL, Mumbai, KGL)...',
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF052469)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _fetchAirports('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF052469))),
            )
          else if (_airports.isEmpty)
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text('No exact matching standard airports found.')),
                  ),
                  if (_searchController.text.trim().isNotEmpty)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF78592E),
                        child: Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        'Use "${_searchController.text.trim()}" as custom location',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text('Custom origin/destination entry'),
                      onTap: () {
                        final rawText = _searchController.text.trim();
                        final derivedCode = rawText.length >= 3 ? rawText.substring(0, 3).toUpperCase() : 'CUSTOM';
                        widget.onSelected(derivedCode, '$rawText ($derivedCode)', rawText, 'Country');
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _airports.length,
                itemBuilder: (context, index) {
                  final airport = _airports[index];
                  final code = airport['code'] ?? 'APT';
                  final name = airport['name'] ?? '';
                  final city = airport['city'] ?? name;
                  final country = airport['country'] ?? '';
                  final fullName = '$name ($code)';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF052469).withValues(alpha: 0.1),
                      child: Text(
                        code,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF052469)),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(country.isNotEmpty ? '$city, $country' : city),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    onTap: () {
                      widget.onSelected(code, fullName, city.isEmpty ? name : city, country.isEmpty ? 'International' : country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
