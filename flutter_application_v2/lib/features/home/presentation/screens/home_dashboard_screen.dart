import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_logo.dart';
import '../../../../core/widgets/user_profile_modal.dart';
import '../../../../providers/app_state.dart';
import '../../../../screens/flights/flight_search_screen.dart';
import '../../../../screens/visa/visa_eligibility_screen.dart';
import '../../../../screens/hotels/hotel_enquiry_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 28),
                      onPressed: () => _showSettingsModal(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SafiriLogo(
                          size: 38,
                          isHorizontal: true,
                          isDarkBackground: isDark,
                        ),
                      ),
                    ),
                    // Multi-Language Selector
                    InkWell(
                      onTap: () => _showLanguageSelector(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: primaryNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryNavy.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppState.supportedLocales[appState.currentLocale]?['flag'] ?? '🇺🇸',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appState.currentLocale.toUpperCase(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    // Multi-Currency Selector
                    InkWell(
                      onTap: () => _showCurrencySelector(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryNavy.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              appState.currentCurrency,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 22),
                      onPressed: () => appState.toggleTheme(),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => UserProfileModal.show(context),
                      borderRadius: BorderRadius.circular(18),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryNavy,
                        backgroundImage: appState.currentUserAvatarUrl.isNotEmpty
                            ? NetworkImage(appState.currentUserAvatarUrl)
                            : null,
                        child: appState.currentUserAvatarUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${appState.tr('hello')},', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                    Text(
                      appState.currentUserName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // HERO SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF031B4E), Color(0xFF052469), Color(0xFF0D3FA9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.tr('your_journey'),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appState.tr('hero_subtitle'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PRIMARY SERVICE CARDS (3 Cards)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.tr('primary_services'),
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Card 1: Flight Bookings
                    _buildServiceCard(
                      context: context,
                      title: appState.tr('flight_bookings'),
                      description: appState.tr('flight_bookings_desc'),
                      ctaText: appState.tr('search_flights'),
                      icon: Icons.flight_takeoff_rounded,
                      color: const Color(0xFF052469),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Card 2: Visa Application
                    _buildServiceCard(
                      context: context,
                      title: appState.tr('visa_application'),
                      description: appState.tr('visa_desc'),
                      ctaText: appState.tr('start_application'),
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFF78592E),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VisaEligibilityScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Card 3: Hotels & Holidays
                    _buildServiceCard(
                      context: context,
                      title: appState.tr('hotels_holidays'),
                      description: appState.tr('hotels_desc'),
                      ctaText: appState.tr('plan_my_trip'),
                      icon: Icons.hotel_rounded,
                      color: const Color(0xFF0F4D4A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HotelEnquiryScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // MY UPCOMING JOURNEY SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Upcoming Journey',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (appState.bookings.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const SafiriLogo(size: 28, showText: false),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        appState.bookings.first.id,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('ACTIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(appState.bookings.first.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(appState.bookings.first.dateRange, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.flight_outlined, size: 36, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('Your next adventure starts here.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
                                  );
                                },
                                child: const Text('Explore Flights'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // POPULAR DESTINATIONS SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Destinations',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDestinationCard('Paris', 'France', 'From \$1,200', const Color(0xFF1D3557)),
                          const SizedBox(width: 12),
                          _buildDestinationCard('Santorini', 'Greece', 'From \$4,200', const Color(0xFF457B9D)),
                          const SizedBox(width: 12),
                          _buildDestinationCard('Zanzibar', 'Tanzania', 'From \$1,800', const Color(0xFF2A9D8F)),
                          const SizedBox(width: 12),
                          _buildDestinationCard('Akagera', 'Rwanda', 'From \$1,450', const Color(0xFFE76F51)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TRAVEL SERVICES GRID
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Travel Services',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildServiceTile(context, Icons.directions_car_rounded, 'Airport\nTransfers'),
                        _buildServiceTile(context, Icons.health_and_safety_rounded, 'Travel\nInsurance'),
                        _buildServiceTile(context, Icons.car_rental_rounded, 'Car Hire'),
                        _buildServiceTile(context, Icons.card_travel_rounded, 'Holiday\nPackages'),
                        _buildServiceTile(context, Icons.business_center_rounded, 'Corporate\nTravel'),
                        _buildServiceTile(context, Icons.support_agent_rounded, 'Travel\nConsultation'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // TRUST SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF232834) : const Color(0xFFF3F5FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTrustItem(Icons.verified_rounded, 'Secure\nPayments'),
                      _buildTrustItem(Icons.headset_mic_rounded, 'Expert\nAssistance'),
                      _buildTrustItem(Icons.public_rounded, 'Global\nDestinations'),
                      _buildTrustItem(Icons.star_rounded, 'Dedicated\nConcierge'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String description,
    required String ctaText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(36, 60, 128, 0.06), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ctaText,
                        style: const TextStyle(color: Color(0xFFFED39D), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFED39D), size: 14),
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

  Widget _buildDestinationCard(String city, String country, String price, Color bg) {
    return Container(
      width: 130,
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(country, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(city, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(color: Color(0xFFFED39D), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HotelEnquiryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryNavy, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGold, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentGold, height: 1.2),
        ),
      ],
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Multi-Currency Engine', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...AppState.currencyData.entries.map((e) {
              return ListTile(
                title: Text('${e.value['name']} (${e.key})'),
                trailing: appState.currentCurrency == e.key ? const Icon(Icons.check, color: AppColors.primaryNavy) : null,
                onTap: () {
                  appState.setCurrency(e.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('System Language / Ururimi', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...AppState.supportedLocales.entries.map((e) {
              final code = e.key;
              final info = e.value;
              return ListTile(
                leading: Text(info['flag'] ?? '', style: const TextStyle(fontSize: 24)),
                title: Text('${info['name']} (${info['native']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: appState.currentLocale == code ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryNavy) : null,
                onTap: () {
                  appState.setLocale(code);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Safiri Holidays Navigation', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ListTile(leading: Icon(Icons.flight_takeoff), title: Text('Flight Search')),
              ListTile(leading: Icon(Icons.assignment), title: Text('Visa Concierge')),
              ListTile(leading: Icon(Icons.hotel), title: Text('Hotels & Holidays')),
            ],
          ),
        );
      },
    );
  }
}
