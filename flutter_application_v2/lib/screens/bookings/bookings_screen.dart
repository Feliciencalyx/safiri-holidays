import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/boarding_pass_widget.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../core/services/notification_service.dart';

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

    final notificationService = Provider.of<NotificationService>(context);

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
                    appState.tr('my_passes_bookings'),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryNavy,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                          );
                        },
                        tooltip: appState.tr('notifications'),
                      ),
                      if (notificationService.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${notificationService.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
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
                Tab(text: appState.tr('tab_all')),
                Tab(text: '${appState.tr('tab_upcoming')} (${appState.bookings.length})'),
                Tab(text: appState.tr('tab_completed')),
                Tab(text: '${appState.tr('tab_enquiries')} (${appState.hotelEnquiries.length})'),
              ],
            ),
            const Divider(height: 1),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(appState.bookings, appState.hotelEnquiries, appState),
                  _buildBookingsList(appState.bookings, [], appState),
                  _buildBookingsList([], [], appState),
                  _buildEnquiriesList(appState.hotelEnquiries, appState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingItem> bookings, List<HotelEnquiryItem> enquiries, AppState appState) {
    if (bookings.isEmpty && enquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.airplane_ticket_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              appState.tr('no_bookings'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            Text(
              appState.tr('no_bookings_desc'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          Text(
            appState.tr('tab_enquiries').toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ...enquiries.map((e) => _buildEnquiryCard(e)),
        ],
      ],
    );
  }

  Widget _buildEnquiriesList(List<HotelEnquiryItem> enquiries, AppState appState) {
    if (enquiries.isEmpty) {
      return Center(child: Text(appState.tr('no_enquiries')));
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
