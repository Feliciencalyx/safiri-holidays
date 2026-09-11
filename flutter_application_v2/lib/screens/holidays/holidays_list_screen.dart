import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../core/services/holiday_api_service.dart';
import 'holiday_detail_screen.dart';

class HolidaysListScreen extends StatefulWidget {
  const HolidaysListScreen({super.key});

  @override
  State<HolidaysListScreen> createState() => _HolidaysListScreenState();
}

class _HolidaysListScreenState extends State<HolidaysListScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  ServerStatusModel? _serverStatus;
  List<HolidayPackageModel> _livePackages = [];

  static const List<String> _categories = [
    'All',
    'Beach',
    'Nature',
    'Adventure',
    'Luxury',
    'Culture',
  ];

  @override
  void initState() {
    super.initState();
    _loadServerData();
  }

  Future<void> _loadServerData() async {
    setState(() => _isLoading = true);
    final status = await HolidayApiService.fetchServerStatus();
    final packages = await HolidayApiService.fetchPackages();

    if (mounted) {
      setState(() {
        _serverStatus = status;
        _livePackages = packages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;

    // Filter live packages
    final filteredPackages = _livePackages.where((pkg) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Beach' && (pkg.location.contains('Zanzibar') || pkg.location.contains('Goa') || pkg.location.contains('Bali') || pkg.location.contains('Mauritius'))) {
        return true;
      }
      if (_selectedCategory == 'Nature' && (pkg.location.contains('Rwanda') || pkg.location.contains('Kerala'))) {
        return true;
      }
      if (_selectedCategory == 'Adventure' && (pkg.location.contains('Akagera') || pkg.location.contains('Manali') || pkg.location.contains('Thailand'))) {
        return true;
      }
      if (_selectedCategory == 'Luxury' && (pkg.location.contains('Santorini') || pkg.location.contains('Dubai') || pkg.location.contains('Europe') || pkg.location.contains('Singapore'))) {
        return true;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safiri Holiday Packages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh safiriholidays.com Server Data',
            onPressed: _loadServerData,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // safiriholidays.com Live Server Integration Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2638), const Color(0xFF2C3954)]
                      : [const Color(0xFF052469), const Color(0xFF0D3FA9)],
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
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFED39D).withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: (_serverStatus?.online ?? true) ? const Color(0xFF00E676) : Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SERVER: ${HolidayApiService.serverDomain}',
                              style: const TextStyle(
                                color: Color(0xFFFED39D),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_serverStatus != null)
                        Text(
                          '${_serverStatus!.latencyMs} ms',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Handcrafted Holiday Vacations',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connected directly to ${HolidayApiService.serverDomain} servers for live rates & itineraries.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text(cat),
                      onSelected: (val) => setState(() => _selectedCategory = cat),
                      selectedColor: primaryNavy,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Packages Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Fetching live packages from safiriholidays.com...'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPackages.length,
                      itemBuilder: (context, index) {
                        final pkgModel = filteredPackages[index];
                        final packageItem = HolidayPackageItem(
                          id: pkgModel.id,
                          title: pkgModel.title,
                          destination: pkgModel.location,
                          duration: pkgModel.duration,
                          priceUsd: pkgModel.priceUsd,
                          category: _selectedCategory == 'All' ? 'Luxury' : _selectedCategory,
                          description: 'Live package sourced from ${pkgModel.serverSource}. Highlights include: ${pkgModel.highlights.join(", ")}.',
                          itineraryDays: [
                            'Day 1: Arrival & Concierge Welcome at ${pkgModel.location}',
                            'Day 2: Guided Destination Tour & Cultural Sightseeing',
                            'Day 3: Signature Excursions & Local Gourmet Dining',
                            'Day 4: Sunset Beach or Scenic Cruise Excursion',
                            'Day 5: Souvenir Shopping & Private Transfer Departure',
                          ],
                          inclusions: pkgModel.highlights,
                          isFeatured: true,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: MajesticHorizonTheme.radiusCard,
                            border: Border.all(
                              color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
                            ),
                            boxShadow: isDark ? MajesticHorizonTheme.darkCardShadow : MajesticHorizonTheme.lightCardShadow,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HolidayDetailScreen(packageItem: packageItem),
                                ),
                              );
                            },
                            borderRadius: MajesticHorizonTheme.radiusCard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Banner Header
                                Container(
                                  height: 130,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    gradient: LinearGradient(
                                      colors: _getCategoryGradient(packageItem.destination),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(
                                          Icons.card_travel_rounded,
                                          size: 80,
                                          color: Colors.white12,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${pkgModel.location.toUpperCase()} • ${pkgModel.duration}',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2E7D32),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'safiriholidays.com LIVE',
                                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            pkgModel.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Package Details
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Highlights Pills
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: pkgModel.highlights.take(3).map((hl) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: primaryNavy.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star_rounded, size: 13, color: primaryNavy),
                                                const SizedBox(width: 4),
                                                Text(hl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryNavy)),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const Divider(height: 24),

                                      // Price & View CTA
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Starting from', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              Text(
                                                '${appState.formatPrice(pkgModel.priceUsd)} / person',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: primaryNavy,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => HolidayDetailScreen(packageItem: packageItem),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                            label: const Text('VIEW ITINERARY'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF052469),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCategoryGradient(String location) {
    if (location.contains('Dubai') || location.contains('UAE')) {
      return [const Color(0xFFB45309), const Color(0xFFD97706)];
    }
    if (location.contains('Bali') || location.contains('Mauritius')) {
      return [const Color(0xFF0D9488), const Color(0xFF14B8A6)];
    }
    if (location.contains('Europe') || location.contains('Santorini')) {
      return [const Color(0xFF4338CA), const Color(0xFF6366F1)];
    }
    if (location.contains('Goa') || location.contains('Zanzibar')) {
      return [const Color(0xFF0284C7), const Color(0xFF38BDF8)];
    }
    return [const Color(0xFF052469), const Color(0xFF1D4ED8)];
  }
}
