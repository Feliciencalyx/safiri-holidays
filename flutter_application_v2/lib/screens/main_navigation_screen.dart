import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'bookings/bookings_screen.dart';
import 'documents/documents_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    BookingsScreen(),
    DocumentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? MajesticHorizonTheme.darkPrimaryNavy : MajesticHorizonTheme.lightPrimaryNavy;

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: appState.selectedTabIndex,
          children: _screens,
        ),
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF131824).withValues(alpha: 0.82)
                    : Colors.white.withValues(alpha: 0.85),
                boxShadow: isDark ? MajesticHorizonTheme.darkCardShadow : MajesticHorizonTheme.lightCardShadow,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.85),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        context: context,
                        index: 0,
                        icon: Icons.home_rounded,
                        label: appState.tr('nav_home'),
                        isSelected: appState.selectedTabIndex == 0,
                        primaryColor: primaryColor,
                      ),
                      _buildNavItem(
                        context: context,
                        index: 1,
                        icon: Icons.calendar_month_rounded,
                        label: appState.tr('nav_bookings'),
                        isSelected: appState.selectedTabIndex == 1,
                        primaryColor: primaryColor,
                        badgeCount: appState.bookings.length,
                      ),
                      _buildNavItem(
                        context: context,
                        index: 2,
                        icon: Icons.assignment_outlined,
                        label: appState.tr('nav_documents'),
                        isSelected: appState.selectedTabIndex == 2,
                        primaryColor: primaryColor,
                        badgeCount: appState.visaApplications.length,
                      ),
                      _buildNavItem(
                        context: context,
                        index: 3,
                        icon: Icons.account_circle_outlined,
                        label: appState.tr('nav_profile'),
                        isSelected: appState.selectedTabIndex == 3,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    int badgeCount = 0,
  }) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark
        ? primaryColor.withValues(alpha: 0.2)
        : MajesticHorizonTheme.lightPrimaryNavy;
    final activeFg = isDark ? primaryColor : Colors.white;
    final inactiveFg = isDark
        ? MajesticHorizonTheme.darkTextMuted
        : MajesticHorizonTheme.lightTextMuted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => appState.setSelectedTab(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? activeFg : inactiveFg,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeFg : inactiveFg,
                    ),
                  ),
                ],
              ),
              if (badgeCount > 0 && !isSelected)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
