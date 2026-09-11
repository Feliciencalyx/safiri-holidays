import 'package:material_ui/material_ui.dart';
import '../../theme/app_theme.dart';

class FacilityFinderScreen extends StatefulWidget {
  const FacilityFinderScreen({super.key});

  @override
  State<FacilityFinderScreen> createState() => _FacilityFinderScreenState();
}

class _FacilityFinderScreenState extends State<FacilityFinderScreen> {
  String _selectedCategory = 'All';
  bool _isMapView = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _facilities = [
    {
      'name': 'Global Visa Hub',
      'category': 'Visa Centers',
      'badge': 'Visa Center',
      'rating': 4.8,
      'location': '1.2 miles away',
      'desc': 'Premium processing center for Schengen and UK visas with priority lounge access.',
      'btnText': 'Book Now',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFF78592E),
    },
    {
      'name': 'Oasis Departure Lounge',
      'category': 'Luxury Lounges',
      'badge': 'Luxury Lounge',
      'rating': 4.9,
      'location': 'Terminal 2, Int. Airport',
      'desc': 'Exclusive access with complimentary gourmet dining, spa services, and private suites.',
      'btnText': 'Reserve Entry',
      'icon': Icons.airline_seat_recline_extra_rounded,
      'color': Color(0xFF052469),
    },
    {
      'name': 'The Grandeur Suites',
      'category': 'Partner Hotels',
      'badge': 'Partner Hotel',
      'rating': 4.7,
      'location': '3.5 miles away',
      'desc': '5-star accommodations with priority booking and special rates for Safiri members.',
      'btnText': 'View Rates',
      'icon': Icons.hotel_rounded,
      'color': Color(0xFF0F4D4A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    final filtered = _facilities.where((f) {
      final matchesCategory = _selectedCategory == 'All' || f['category'] == _selectedCategory;
      final matchesSearch = f['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          f['desc'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Facility'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Controls matching Image 10
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search for centers, lounges...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter & View Toggle Row
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('Filters'),
                      ),
                      const SizedBox(width: 12),

                      // Segmented List / Map Toggle matching Image 10
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isMapView = false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !_isMapView ? cardBg : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.list_rounded, size: 16, color: !_isMapView ? primaryNavy : textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            'List',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: !_isMapView ? FontWeight.bold : FontWeight.normal,
                                              color: !_isMapView ? primaryNavy : textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isMapView = true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isMapView ? cardBg : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.map_outlined, size: 16, color: _isMapView ? primaryNavy : textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Map',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: _isMapView ? FontWeight.bold : FontWeight.normal,
                                              color: _isMapView ? primaryNavy : textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category Chips Bar matching Image 10
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Visa Centers',
                        'Luxury Lounges',
                        'Partner Hotels',
                      ].map((cat) {
                        final isSelected = _selectedCategory == cat;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: primaryNavy,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Main Content Area (List View vs Map View)
            Expanded(
              child: _isMapView
                  ? Container(
                      color: isDark ? const Color(0xFF1E2430) : const Color(0xFFE5ECF6),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_rounded, size: 64, color: primaryNavy),
                            const SizedBox(height: 12),
                            const Text('Interactive Global Map View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Displaying ${filtered.length} locations near you.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: filtered.map((fac) {
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
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Facility Image Placeholder Banner matching Image 10
                              Container(
                                height: 140,
                                color: (fac['color'] as Color).withValues(alpha: 0.12),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(fac['icon'] as IconData, size: 64, color: fac['color'] as Color),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          fac['badge'],
                                          style: const TextStyle(color: Color(0xFF78592E), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 18,
                                        child: IconButton(
                                          icon: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Facility Card Body matching Image 10
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          fac['name'],
                                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${fac['rating']}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(fac['location'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(fac['desc'], style: TextStyle(fontSize: 12, color: textMuted)),
                                    const SizedBox(height: 14),

                                    // Action Buttons Row matching Image 10
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Booking request sent for ${fac['name']}!'),
                                                  backgroundColor: const Color(0xFF2E7D32),
                                                ),
                                              );
                                            },
                                            child: Text(fac['btnText']),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: const Icon(Icons.navigation_rounded, size: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
