import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'hotel_checkout_modal.dart';

class HotelSearchResultsScreen extends StatefulWidget {
  final String destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int adults;
  final int children;

  const HotelSearchResultsScreen({
    super.key,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.children,
  });

  @override
  State<HotelSearchResultsScreen> createState() => _HotelSearchResultsScreenState();
}

class _HotelSearchResultsScreenState extends State<HotelSearchResultsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    // Filter hotels matching query or show catalog
    final query = widget.destination.toLowerCase();
    final hotels = appState.hotelCatalog.where((h) {
      if (_selectedFilter != 'All' && !h.amenities.contains(_selectedFilter)) {
        return false;
      }
      if (query.isEmpty) return true;
      return h.destination.toLowerCase().contains(query) ||
          h.name.toLowerCase().contains(query) ||
          h.locationTag.toLowerCase().contains(query);
    }).toList();

    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    final actualNights = nights <= 0 ? 1 : nights;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.destination.isEmpty ? 'Popular Hotel Destinations' : widget.destination,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.checkIn.month}/${widget.checkIn.day} - ${widget.checkOut.month}/${widget.checkOut.day} • $actualNights Night(s) • ${widget.rooms} Room, ${widget.adults} Guest(s)',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: ['All', 'Breakfast Included', 'Infinity Pool', 'Free WiFi', 'Beachfront', 'Spa & Fitness'].map((filter) {
                  final selected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selected,
                      label: Text(filter),
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: primaryNavy,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Hotel Cards List
            Expanded(
              child: hotels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: textMuted),
                          const SizedBox(height: 12),
                          Text('No hotels found matching criteria', style: TextStyle(color: textMuted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        final totalPrice = hotel.priceUsdPerNight * actualNights * widget.rooms;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hotel Image Container
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Container(
                                  height: 160,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                  ),
                                  child: Image.network(
                                    hotel.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) {
                                      return Container(
                                        color: const Color(0xFF052469),
                                        child: const Center(
                                          child: Icon(Icons.hotel_rounded, size: 48, color: Colors.white70),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Hotel Content Details
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            hotel.name,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${hotel.rating}',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          hotel.locationTag,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      hotel.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: textMuted, height: 1.3),
                                    ),
                                    const SizedBox(height: 12),

                                    // Amenities Pills
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: hotel.amenities.map((amenity) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: primaryNavy.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            amenity,
                                            style: TextStyle(fontSize: 10, color: primaryNavy, fontWeight: FontWeight.w600),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const Divider(height: 24),

                                    // Pricing & Action CTA
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'From ${appState.formatPrice(hotel.priceUsdPerNight)} / night',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Total: ${appState.formatPrice(totalPrice)}',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: primaryNavy,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (ctx) => HotelCheckoutModal(
                                                hotel: hotel,
                                                checkIn: widget.checkIn,
                                                checkOut: widget.checkOut,
                                                rooms: widget.rooms,
                                                adults: widget.adults,
                                                totalPriceUsd: totalPrice,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF052469),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                          child: const Text('SELECT ROOM & BOOK'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}
