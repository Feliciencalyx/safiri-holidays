import 'package:material_ui/material_ui.dart';

class SafiriNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  bool isRead;

  SafiriNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  final List<SafiriNotification> _notifications = [
    SafiriNotification(
      id: 'notif_1',
      title: 'Booking Confirmed (#SAF-2026-9841)',
      body: 'Your Akagera Safari Adventure flight pass & e-ticket has been issued. Tap to view QR verification code.',
      time: '10 mins ago',
      icon: Icons.airplane_ticket_rounded,
      color: const Color(0xFF052469),
      isRead: false,
    ),
    SafiriNotification(
      id: 'notif_2',
      title: 'Visa Application Update (#VSA-8492)',
      body: 'Your Schengen France visa application has advanced to Stage 2: Consultation Under Review.',
      time: '2 hours ago',
      icon: Icons.assignment_turned_in_rounded,
      color: const Color(0xFF78592E),
      isRead: false,
    ),
    SafiriNotification(
      id: 'notif_3',
      title: 'MTN MoMo Payment Successful',
      body: '780,000 RWF received via MoMo for booking #SAF-2026-9841. Payment reference: PAY-MOMO-9021.',
      time: '3 hours ago',
      icon: Icons.payment_rounded,
      color: const Color(0xFF2E7D32),
      isRead: true,
    ),
    SafiriNotification(
      id: 'notif_4',
      title: 'Hotel Concierge Response (#HOL-9012)',
      body: 'A dedicated concierge agent has been assigned to your Santorini Escape enquiry. Expect a callback within 24h.',
      time: '1 day ago',
      icon: Icons.hotel_rounded,
      color: const Color(0xFF0F4D4A),
      isRead: true,
    ),
  ];

  List<SafiriNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    _notifications.insert(
      0,
      SafiriNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        time: 'Just now',
        icon: icon,
        color: color,
        isRead: false,
      ),
    );
    notifyListeners();
  }
}
