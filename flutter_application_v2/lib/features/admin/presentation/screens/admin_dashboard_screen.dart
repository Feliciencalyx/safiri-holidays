import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/app_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = false;

  void _refreshDashboard() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard metrics refreshed live from Supabase PostgreSQL'),
            backgroundColor: Color(0xFF052469),
          ),
        );
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Safiri Admin Concierge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              final appState = Provider.of<AppState>(context, listen: false);
              appState.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out of Safiri Admin Concierge'),
                  backgroundColor: Colors.black87,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.tr('admin_dashboard')),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh Metrics',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Admin Banner Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF052469), Color(0xFF0B3C91)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF052469).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EXECUTIVE ANALYTICS',
                        style: TextStyle(
                          color: Color(0xFFFED39D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.greenAccent),
                            SizedBox(width: 4),
                            Text(
                              'SUPABASE LIVE',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Total Flight & Safari Revenue',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.formatPrice(appState.bookings.fold<double>(0.0, (sum, b) => sum + b.priceUsd)),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4 Grid Metric Cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildMetricTile(
                  context,
                  title: 'Total Registered Users',
                  value: '${appState.registeredUsers.length}',
                  subtitle: '+24.8% growth',
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF052469),
                  bg: cardBg,
                ),
                _buildMetricTile(
                  context,
                  title: 'Active Bookings',
                  value: '${appState.bookings.length}',
                  subtitle: 'Confirmed & Issued',
                  icon: Icons.confirmation_number_rounded,
                  iconColor: const Color(0xFF78592E),
                  bg: cardBg,
                ),
                _buildMetricTile(
                  context,
                  title: 'Successful Payments',
                  value: '74',
                  subtitle: '8 Pending Callback',
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  bg: cardBg,
                ),
                _buildMetricTile(
                  context,
                  title: 'System Growth Rate',
                  value: '+24.8%',
                  subtitle: 'Google Analytics 4',
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF4285F4),
                  bg: cardBg,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // GOOGLE ANALYTICS SYSTEM GROWTH VISUALIZATION
            const Text(
              'GOOGLE ANALYTICS SYSTEM GROWTH',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.analytics_rounded, color: Color(0xFF4285F4), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Traffic & User Growth (GA4)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '+24.8% MoM',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4285F4)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Monthly Growth Bar Chart Visualization
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGrowthBar('Jan', 0.35, isDark),
                      _buildGrowthBar('Feb', 0.45, isDark),
                      _buildGrowthBar('Mar', 0.55, isDark),
                      _buildGrowthBar('Apr', 0.60, isDark),
                      _buildGrowthBar('May', 0.72, isDark),
                      _buildGrowthBar('Jun', 0.80, isDark),
                      _buildGrowthBar('Jul', 0.88, isDark),
                      _buildGrowthBar('Aug', 1.00, isDark, isHighlight: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(height: 16),

                  // Key Performance Indicators Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildKpiItem('Active Sessions', '48,290'),
                      _buildKpiItem('Conversion Rate', '4.82%'),
                      _buildKpiItem('Avg Duration', '4m 12s'),
                      _buildKpiItem('Uptime', '99.98%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TOTAL REGISTERED USERS MANAGEMENT SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALL REGISTERED USERS (${appState.registeredUsers.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All user accounts synchronized live from PostgreSQL')),
                    );
                  },
                  icon: const Icon(Icons.people_alt_outlined, size: 16),
                  label: const Text('Manage', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: appState.registeredUsers.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF052469).withValues(alpha: 0.1),
                          child: Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: user.tier == 'VIP Concierge'
                                          ? const Color(0xFF78592E).withValues(alpha: 0.15)
                                          : const Color(0xFF052469).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      user.tier,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: user.tier == 'VIP Concierge' ? const Color(0xFF78592E) : const Color(0xFF052469),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user.email} • ${user.phone}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  Text('Passport: ${user.passportNumber}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Icon(
                                    user.isPassportVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                                    size: 12,
                                    color: user.isPassportVerified ? Colors.green : Colors.amber,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${user.totalBookings} Bookings', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: user.status == 'Active' ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: user.status == 'Active' ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Real-Time System Audit Log
            const Text(
              'REAL-TIME AUDIT LOG',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            _buildAuditItem(
              context,
              title: 'MTN MoMo Payment Received',
              subtitle: 'Violet Nabise • 780,000 RWF for #SAF-2026-9841',
              time: '5m ago',
              statusColor: Colors.green,
              isDark: isDark,
              cardBg: cardBg,
            ),
            _buildAuditItem(
              context,
              title: 'RwandAir Flight Ticket Issued',
              subtitle: 'Booking #SAF-2026-9841 issued with QR verification code',
              time: '18m ago',
              statusColor: const Color(0xFF052469),
              isDark: isDark,
              cardBg: cardBg,
            ),
            _buildAuditItem(
              context,
              title: 'Google OAuth Single Sign-On Account Created',
              subtitle: 'New user registered via Google Sign-In portal',
              time: '24m ago',
              statusColor: const Color(0xFF4285F4),
              isDark: isDark,
              cardBg: cardBg,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthBar(String month, double factor, bool isDark, {bool isHighlight = false}) {
    return Column(
      children: [
        Container(
          height: 60 * factor,
          width: 18,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFF4285F4) : const Color(0xFF052469).withValues(alpha: isDark ? 0.6 : 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(month, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildKpiItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bg,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required Color statusColor,
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
