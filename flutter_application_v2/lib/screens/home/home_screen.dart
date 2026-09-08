import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/safiri_logo.dart';
import '../../core/widgets/user_profile_modal.dart';
import '../../core/widgets/ios_glass_widgets.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../flights/flight_search_screen.dart';
import '../visa/visa_eligibility_screen.dart';
import '../hotels/hotel_enquiry_screen.dart';
import '../hotels/hotel_search_results_screen.dart';
import '../holidays/holidays_list_screen.dart';
import '../bus/bus_booking_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../core/services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final notificationService = Provider.of<NotificationService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryNavy = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;
    final accentGold = isDark ? MajesticHorizonTheme.darkAccentGold : MajesticHorizonTheme.lightAccentGold;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : MajesticHorizonTheme.lightSurfaceCard;
    final textMuted = isDark ? MajesticHorizonTheme.darkTextMuted : MajesticHorizonTheme.lightTextMuted;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar & Profile Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Drawer Icon / Logo Mark
                    IconButton(
                      onPressed: () => _showSettingsModal(context),
                      icon: const Icon(Icons.menu_rounded, size: 28),
                      tooltip: 'Menu & Settings',
                    ),
                    const SizedBox(width: 8),
                    // Safiri Title & Tagline
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
                    // Multi-Currency Badge Selector
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryNavy,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Theme Switcher
                    IconButton(
                      onPressed: () => appState.toggleTheme(),
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 22,
                      ),
                      tooltip: 'Toggle Light/Dark Theme',
                    ),
                    // Notification Center Bell
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                            );
                          },
                          icon: const Icon(Icons.notifications_none_rounded, size: 24),
                          tooltip: 'Notifications',
                        ),
                        if (notificationService.unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
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
                    const SizedBox(width: 4),
                    // User Avatar with System-wide Profile Modal
                    InkWell(
                      onTap: () => UserProfileModal.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: primaryNavy.withValues(alpha: 0.2),
                        backgroundImage: appState.currentUserAvatarUrl.isNotEmpty
                            ? (appState.currentUserAvatarUrl.startsWith('http')
                                ? NetworkImage(appState.currentUserAvatarUrl)
                                : (File(appState.currentUserAvatarUrl).existsSync()
                                    ? FileImage(File(appState.currentUserAvatarUrl))
                                    : NetworkImage(appState.currentUserAvatarUrl) as ImageProvider))
                            : null,
                        child: appState.currentUserAvatarUrl.isEmpty
                            ? const Icon(Icons.person, color: MajesticHorizonTheme.lightPrimaryNavy)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Greeting Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appState.getTimeGreeting()},',
                      style: TextStyle(
                        fontSize: 16,
                        color: textMuted,
                      ),
                    ),
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

            // SECTION 1: 3 PRIMARY ACTION CARDS (Core Requirement)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: accentGold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.tr('primary_services').toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentGold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Flight Bookings Card
                    _buildPrimaryActionCard(
                      context: context,
                      title: appState.tr('flight_bookings'),
                      subtitle: 'Global Carrier Search & Dynamic E-Ticket Boarding Pass',
                      icon: Icons.flight_takeoff_rounded,
                      badgeText: 'Safiri Verified Fares',
                      gradientColors: isDark
                          ? [const Color(0xFF1E2638), const Color(0xFF2C3954)]
                          : [const Color(0xFF052469), const Color(0xFF0D3FA9)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // 2. Holiday Packages Card (safiriholidays.com Top Packages)
                    _buildPrimaryActionCard(
                      context: context,
                      title: appState.tr('holiday_packages'),
                      subtitle: 'Goa, Kerala, Dubai, Bali, Thailand, Europe & Mauritius',
                      icon: Icons.card_travel_rounded,
                      badgeText: 'Curated Itineraries',
                      gradientColors: isDark
                          ? [const Color(0xFF382B1E), const Color(0xFF54422C)]
                          : [const Color(0xFF78592E), const Color(0xFFA67C43)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HolidaysListScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Hotel Bookings & Stays
                    _buildPrimaryActionCard(
                      context: context,
                      title: appState.tr('hotels_holidays'),
                      subtitle: 'Over 30,000 Luxury rooms & budget stay deals worldwide',
                      icon: Icons.hotel_rounded,
                      badgeText: 'Free Cancellation',
                      gradientColors: isDark
                          ? [const Color(0xFF1B332F), const Color(0xFF294E48)]
                          : [const Color(0xFF0F4D4A), const Color(0xFF177A75)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelSearchResultsScreen(
                              destination: '',
                              checkIn: DateTime.now(),
                              checkOut: DateTime.now(),
                              rooms: 1,
                              adults: 2,
                              children: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 2: QUICK ACTIONS (Matching Uploaded UI & safiriholidays.com)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionButton(
                          context: context,
                          icon: Icons.card_travel_rounded,
                          label: 'Holidays\nPackages',
                          bgColor: const Color(0xFFF7EFE5),
                          iconColor: const Color(0xFF78592E),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HolidaysListScreen()),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          context: context,
                          icon: Icons.hotel_rounded,
                          label: 'Book\nHotel',
                          bgColor: const Color(0xFFE8EEF9),
                          iconColor: const Color(0xFF052469),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HotelSearchResultsScreen(
                                  destination: '',
                                  checkIn: DateTime.now(),
                                  checkOut: DateTime.now(),
                                  rooms: 1,
                                  adults: 2,
                                  children: 0,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          context: context,
                          icon: Icons.directions_bus_rounded,
                          label: 'Bus\nExpress',
                          bgColor: const Color(0xFFE6F4EA),
                          iconColor: const Color(0xFF137333),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BusBookingScreen()),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          context: context,
                          icon: Icons.badge_outlined,
                          label: 'Visa\nAssist',
                          bgColor: const Color(0xFFEBE8F9),
                          iconColor: const Color(0xFF4A3B9B),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VisaEligibilityScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 3: TRAVEL & ADVENTURE HERO CARDS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildHeroCategoryCard(
                        context: context,
                        title: 'Holiday\nPackages',
                        subtitle: 'Dubai, Bali, Europe',
                        color: const Color(0xFFF57C00),
                        icon: Icons.explore_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HolidaysListScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildHeroCategoryCard(
                        context: context,
                        title: 'Luxury Stays',
                        subtitle: 'Popular Hotel Deals',
                        color: const Color(0xFF052469),
                        icon: Icons.pool_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelSearchResultsScreen(
                                destination: '',
                                checkIn: DateTime.now(),
                                checkOut: DateTime.now(),
                                rooms: 1,
                                adults: 2,
                                children: 0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 4: SPECIAL OFFERS CAROUSEL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Special Offers',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HotelEnquiryScreen()),
                            );
                          },
                          child: Row(
                            children: [
                              Text('View All', style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Gorilla Trekking Special Offer Card
                    Container(
                      padding: const EdgeInsets.all(16),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Special Offer • Save 15%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Discover Gorilla Trekking & Volcanoes',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? MajesticHorizonTheme.darkTextPrimary : MajesticHorizonTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Experience the ultimate adventure in Rwanda with our exclusive luxury packages.',
                            style: TextStyle(
                              fontSize: 13,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // High quality illustration container
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: MajesticHorizonTheme.radiusCard,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Positioned(
                                  right: 20,
                                  bottom: 20,
                                  child: Icon(
                                    Icons.landscape_rounded,
                                    size: 100,
                                    color: Colors.white12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Volcanoes National Park',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Starting from ${appState.formatPrice(4200)}',
                                        style: const TextStyle(
                                          color: Color(0xFFFED39D),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HotelEnquiryScreen()),
                                );
                              },
                              child: const Text('GET MORE INFORMATION'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 5: VALUE PROPOSITIONS (Matching Uploaded UI)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF232834) : const Color(0xFFF3F5FA),
                    borderRadius: MajesticHorizonTheme.radiusCard,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildValuePropItem(
                        icon: Icons.verified_rounded,
                        label: 'Premium\nPartners',
                        color: accentGold,
                      ),
                      _buildValuePropItem(
                        icon: Icons.headset_mic_rounded,
                        label: '24/7\nConcierge',
                        color: accentGold,
                      ),
                      _buildValuePropItem(
                        icon: Icons.shield_rounded,
                        label: 'Secure\nBooking',
                        color: accentGold,
                      ),
                      _buildValuePropItem(
                        icon: Icons.language_rounded,
                        label: 'Global\nReach',
                        color: accentGold,
                      ),
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

  // Build Primary Action Card Widget with iOS Hover Animation
  Widget _buildPrimaryActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return IosHoverCard(
      onTap: onTap,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: MajesticHorizonTheme.radiusCard,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Circular Icon Button
  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // Hero Category Banner
  Widget _buildHeroCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: MajesticHorizonTheme.radiusCard,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: MajesticHorizonTheme.radiusCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: Colors.white30, size: 36),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuePropItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Multi-Currency',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: AppState.currencyData.entries.map((entry) {
                    final isSelected = appState.currentCurrency == entry.key;
                    final name = entry.value['name'] as String;
                    final symbol = entry.value['symbol'] as String;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? MajesticHorizonTheme.lightPrimaryNavy : Colors.grey.shade200,
                        child: Text(
                          symbol.trim(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.key),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: MajesticHorizonTheme.lightPrimaryNavy) : null,
                      onTap: () {
                        appState.setCurrency(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Safiri Holidays Preferences',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Language & Locale'),
                subtitle: Text(AppState.supportedLocales[appState.currentLocale]?['name'] ?? 'English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageSelector(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Currency Engine'),
                subtitle: Text(appState.currentCurrency),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showCurrencySelector(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select App Language',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...AppState.supportedLocales.entries.map((entry) {
                final isSelected = appState.currentLocale == entry.key;
                final flag = entry.value['flag']!;
                final native = entry.value['native']!;
                final name = entry.value['name']!;

                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 24)),
                  title: Text(native, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(name),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: MajesticHorizonTheme.lightPrimaryNavy) : null,
                  onTap: () {
                    appState.setLocale(entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
