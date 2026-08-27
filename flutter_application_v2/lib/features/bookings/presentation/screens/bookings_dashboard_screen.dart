import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/app_state.dart';
import '../../../../widgets/boarding_pass_widget.dart';

class BookingsDashboardScreen extends StatefulWidget {
  const BookingsDashboardScreen({super.key});

  @override
  State<BookingsDashboardScreen> createState() => _BookingsDashboardScreenState();
}

class _BookingsDashboardScreenState extends State<BookingsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    final primaryNavy = isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Centralized Bookings',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryNavy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryNavy,
              unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              indicatorColor: primaryNavy,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Flights'),
                Tab(text: 'Hotels'),
                Tab(text: 'Visas'),
                Tab(text: 'Holidays'),
              ],
            ),
            const Divider(height: 1),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllBookings(appState),
                  _buildFlightBookings(appState),
                  _buildHotelBookings(appState),
                  _buildVisaApplications(appState),
                  _buildHotelBookings(appState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllBookings(AppState appState) {
    if (appState.bookings.isEmpty && appState.hotelEnquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flight_land_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No journeys yet.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Your next adventure starts here.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...appState.bookings.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BoardingPassWidget(booking: b),
        )),
        ...appState.hotelEnquiries.map((e) => _buildEnquiryCard(e)),
      ],
    );
  }

  Widget _buildFlightBookings(AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: appState.bookings.map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: BoardingPassWidget(booking: b),
      )).toList(),
    );
  }

  Widget _buildHotelBookings(AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: appState.hotelEnquiries.map((e) => _buildEnquiryCard(e)).toList(),
    );
  }

  Widget _buildVisaApplications(AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: appState.visaApplications.map((v) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE ${v.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${v.applicantNationality} ➔ ${v.destinationCountry}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(v.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnquiryCard(HotelEnquiryItem e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ENQUIRY ${e.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(e.status, style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(e.destination, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Dates: ${e.checkIn} to ${e.checkOut}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
