import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/boarding_pass_widget.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header matching Image 1
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Passes & Bookings',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryNavy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                    tooltip: 'Notifications',
                  ),
                ],
              ),
            ),

            // Tab Bar matching Image 1 (All, Upcoming, Completed, Enquiries)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryNavy,
              unselectedLabelColor: isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted,
              indicatorColor: primaryNavy,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                const Tab(text: 'All'),
                Tab(text: 'Upcoming (${appState.bookings.length})'),
                const Tab(text: 'Completed'),
                Tab(text: 'Enquiries (${appState.hotelEnquiries.length})'),
              ],
            ),
            const Divider(height: 1),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(appState.bookings, appState.hotelEnquiries),
                  _buildBookingsList(appState.bookings, []),
                  _buildBookingsList([], []),
                  _buildEnquiriesList(appState.hotelEnquiries),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingItem> bookings, List<HotelEnquiryItem> enquiries) {
    if (bookings.isEmpty && enquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.airplane_ticket_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No completed bookings yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Your past travel itineraries will appear here.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...bookings.map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: BoardingPassWidget(booking: booking),
          );
        }),
        if (enquiries.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'ACTIVE HOTEL ENQUIRIES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ...enquiries.map((e) => _buildEnquiryCard(e)),
        ],
      ],
    );
  }

  Widget _buildEnquiriesList(List<HotelEnquiryItem> enquiries) {
    if (enquiries.isEmpty) {
      return const Center(child: Text('No active hotel enquiries.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: enquiries.map((e) => _buildEnquiryCard(e)).toList(),
    );
  }

  Widget _buildEnquiryCard(HotelEnquiryItem enquiry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard,
        borderRadius: MajesticHorizonTheme.radiusCard,
        border: Border.all(
          color: isDark ? MajesticHorizonTheme.darkBorder : MajesticHorizonTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENQUIRY ${enquiry.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF052469).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  enquiry.status,
                  style: const TextStyle(color: Color(0xFF052469), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(enquiry.destination, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Dates: ${enquiry.checkIn} to ${enquiry.checkOut}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            'Guests: ${enquiry.adults} Adults, ${enquiry.children} Children • ${enquiry.rooms} Room(s)',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
