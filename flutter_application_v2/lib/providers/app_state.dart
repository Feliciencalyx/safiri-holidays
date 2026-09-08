import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_translations.dart';
import '../core/services/currency_api_service.dart';
import '../core/utils/passport_verifier.dart';

class FlightDetails {
  final String origin;
  final String originCode;
  final String destination;
  final String destinationCode;
  final String airline;
  final String airlineLogo;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String stops;
  final String cabinClass;
  final String seatNumber;

  FlightDetails({
    required this.origin,
    required this.originCode,
    required this.destination,
    required this.destinationCode,
    required this.airline,
    required this.airlineLogo,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.cabinClass,
    required this.seatNumber,
  });

  factory FlightDetails.fromJson(Map<String, dynamic> json) => FlightDetails(
        origin: json['origin'] ?? '',
        originCode: json['originCode'] ?? '',
        destination: json['destination'] ?? '',
        destinationCode: json['destinationCode'] ?? '',
        airline: json['airline'] ?? '',
        airlineLogo: json['airlineLogo'] ?? '',
        departureTime: json['departureTime'] ?? '',
        arrivalTime: json['arrivalTime'] ?? '',
        duration: json['duration'] ?? '',
        stops: json['stops'] ?? '',
        cabinClass: json['cabinClass'] ?? '',
        seatNumber: json['seatNumber'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'origin': origin,
        'originCode': originCode,
        'destination': destination,
        'destinationCode': destinationCode,
        'airline': airline,
        'airlineLogo': airlineLogo,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'duration': duration,
        'stops': stops,
        'cabinClass': cabinClass,
        'seatNumber': seatNumber,
      };
}

class BookingItem {
  final String id;
  final String title;
  final String userName;
  final String userTier;
  final String status; // Active, Completed, Pending
  final String type; // Safari, Flight, Hotel, Visa
  final String dateRange;
  final double priceUsd;
  final String qrCodeData;
  final FlightDetails? flightDetails;

  BookingItem({
    required this.id,
    required this.title,
    required this.userName,
    required this.userTier,
    required this.status,
    required this.type,
    required this.dateRange,
    required this.priceUsd,
    required this.qrCodeData,
    this.flightDetails,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        userName: json['userName'] ?? '',
        userTier: json['userTier'] ?? '',
        status: json['status'] ?? 'Active',
        type: json['type'] ?? 'Flight',
        dateRange: json['dateRange'] ?? '',
        priceUsd: (json['priceUsd'] as num?)?.toDouble() ?? 0.0,
        qrCodeData: json['qrCodeData'] ?? '',
        flightDetails: json['flightDetails'] != null ? FlightDetails.fromJson(json['flightDetails']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'userName': userName,
        'userTier': userTier,
        'status': status,
        'type': type,
        'dateRange': dateRange,
        'priceUsd': priceUsd,
        'qrCodeData': qrCodeData,
        'flightDetails': flightDetails?.toJson(),
      };
}

class VisaApplicationItem {
  final String id;
  final String destinationCountry;
  final String applicantNationality;
  int currentStep; // 1 to 4
  String status; // Submitted, Under Review, Approved, Action Required
  final Map<String, bool> documentsUploaded;
  final String submittedDate;

  VisaApplicationItem({
    required this.id,
    required this.destinationCountry,
    required this.applicantNationality,
    required this.currentStep,
    required this.status,
    required this.documentsUploaded,
    required this.submittedDate,
  });

  factory VisaApplicationItem.fromJson(Map<String, dynamic> json) => VisaApplicationItem(
        id: json['id'] ?? '',
        destinationCountry: json['destinationCountry'] ?? '',
        applicantNationality: json['applicantNationality'] ?? '',
        currentStep: json['currentStep'] ?? 1,
        status: json['status'] ?? 'Under Review',
        documentsUploaded: json['documentsUploaded'] is Map
            ? Map<String, bool>.from((json['documentsUploaded'] as Map).map((k, v) => MapEntry(k.toString(), v == true)))
            : {},
        submittedDate: json['submittedDate'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinationCountry': destinationCountry,
        'applicantNationality': applicantNationality,
        'currentStep': currentStep,
        'status': status,
        'documentsUploaded': documentsUploaded,
        'submittedDate': submittedDate,
      };
}

class HotelEnquiryItem {
  final String id;
  final String destination;
  final String checkIn;
  final String checkOut;
  final int rooms;
  final int adults;
  final int children;
  final int infants;
  final String status;
  final String submittedTime;
  final String? hotelName;
  final String? roomType;
  final double? priceUsd;

  HotelEnquiryItem({
    required this.id,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.infants,
    required this.status,
    required this.submittedTime,
    this.hotelName,
    this.roomType,
    this.priceUsd,
  });
}

class HolidayEnquiryBookingItem {
  final String id;
  final String packageTitle;
  final String destination;
  final String duration;
  final int adults;
  final int children;
  final String travelDate;
  final double priceUsd;
  final String status; // Enquiry Dispatched, Deposit Paid, Confirmed
  final String submittedTime;
  final String type; // Direct Deposit or Custom Quote

  HolidayEnquiryBookingItem({
    required this.id,
    required this.packageTitle,
    required this.destination,
    required this.duration,
    required this.adults,
    required this.children,
    required this.travelDate,
    required this.priceUsd,
    required this.status,
    required this.submittedTime,
    required this.type,
  });
}

class HotelCatalogItem {
  final String id;
  final String name;
  final String destination;
  final String locationTag;
  final double rating;
  final int reviewsCount;
  final double priceUsdPerNight;
  final String imageUrl;
  final List<String> amenities;
  final String description;

  HotelCatalogItem({
    required this.id,
    required this.name,
    required this.destination,
    required this.locationTag,
    required this.rating,
    required this.reviewsCount,
    required this.priceUsdPerNight,
    required this.imageUrl,
    required this.amenities,
    required this.description,
  });
}

class AdminFlightItem {
  final String id;
  final String flightNumber;
  final String airline;
  final String origin;
  final String originCode;
  final String destination;
  final String destinationCode;
  final String departureTime;
  final String arrivalTime;
  double priceUsd;
  int seatsAvailable;
  String status; // Scheduled, Delayed, Cancelled

  AdminFlightItem({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.origin,
    required this.originCode,
    required this.destination,
    required this.destinationCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.priceUsd,
    required this.seatsAvailable,
    this.status = 'Scheduled',
  });
}

class HolidayPackageItem {
  final String id;
  final String title;
  final String destination;
  final String duration;
  double priceUsd;
  final String category; // Beach, Honeymoon, Adventure, Culture, Luxury
  final String description;
  final List<String> itineraryDays;
  final List<String> inclusions;
  bool isFeatured;
  String status; // Active, Draft

  HolidayPackageItem({
    required this.id,
    required this.title,
    required this.destination,
    required this.duration,
    required this.priceUsd,
    required this.category,
    required this.description,
    required this.itineraryDays,
    required this.inclusions,
    this.isFeatured = false,
    this.status = 'Active',
  });
}

class RegisteredUserItem {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passportNumber;
  final bool isPassportVerified;
  final String passportCountry;
  String tier; // Standard, Premium Explorer, VIP Concierge
  final String memberSince;
  int totalBookings;
  String status; // Active, Suspended

  RegisteredUserItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '+250788000999',
    this.passportNumber = 'PC9920148X',
    this.isPassportVerified = true,
    this.passportCountry = 'Rwanda',
    required this.tier,
    required this.memberSince,
    required this.totalBookings,
    this.status = 'Active',
  });
}

class AppState extends ChangeNotifier {
  // Navigation
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Active Signed In User State & JWT Authorization
  String? _authToken;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  String _userRole = 'customer';
  String get userRole => _userRole;

  String _currentUserName = 'Violet Nabise';
  String get currentUserName => _currentUserName;
  String get userName => _currentUserName;

  String _currentUserEmail = 'violet.nabise@safiri.com';
  String get currentUserEmail => _currentUserEmail;
  String get userEmail => _currentUserEmail;

  String _currentUserPhone = '+250788000999';
  String get currentUserPhone => _currentUserPhone;
  String get userPhone => _currentUserPhone;

  String _currentUserPassportNumber = 'PC9920148X';
  String get currentUserPassportNumber => _currentUserPassportNumber;
  String get userPassportNumber => _currentUserPassportNumber;

  String _currentUserAvatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';
  String get currentUserAvatarUrl => _currentUserAvatarUrl;

  String _currentUserTier = 'Premium Explorer';
  String get currentUserTier => _currentUserTier;

  bool _isPassportVerified = true;
  bool get isPassportVerified => _isPassportVerified;

  void updateUserAvatarUrl(String newUrl) {
    _currentUserAvatarUrl = newUrl;
    notifyListeners();
    _savePreferences();
  }

  void deleteUserAccount() {
    _registeredUsers.removeWhere((u) => u.email.toLowerCase() == _currentUserEmail.toLowerCase());
    logout();
  }

  String _passportCountry = 'Rwanda';
  String get passportCountry => _passportCountry;

  bool get isCredentialVerified =>
      _currentUserName.trim().isNotEmpty &&
      _currentUserEmail.trim().isNotEmpty &&
      _currentUserPhone.trim().isNotEmpty &&
      _currentUserPassportNumber.trim().isNotEmpty &&
      _isPassportVerified;

  void setAuthData({
    required String token,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? passportNumber,
    bool? isPassportVerified,
    String? passportCountry,
  }) {
    _authToken = token;
    _currentUserName = name;
    _currentUserEmail = email;
    _userRole = role;
    _isAdmin = role == 'admin';

    // Check if user already exists in registered database
    final existingIndex = _registeredUsers.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase());

    if (phone != null && phone.isNotEmpty) {
      _currentUserPhone = phone;
    } else if (existingIndex != -1 && _registeredUsers[existingIndex].phone.isNotEmpty) {
      _currentUserPhone = _registeredUsers[existingIndex].phone;
    } else {
      _currentUserPhone = '';
    }

    if (passportNumber != null && passportNumber.isNotEmpty) {
      _currentUserPassportNumber = passportNumber;
      final verification = PassportVerifierService.verify(passportNumber);
      _isPassportVerified = verification.isValid;
      if (verification.isValid) _passportCountry = verification.countryName;
    } else if (existingIndex != -1 && _registeredUsers[existingIndex].passportNumber.isNotEmpty) {
      _currentUserPassportNumber = _registeredUsers[existingIndex].passportNumber;
      _isPassportVerified = _registeredUsers[existingIndex].isPassportVerified;
      _passportCountry = _registeredUsers[existingIndex].passportCountry;
    } else {
      _currentUserPassportNumber = '';
      _isPassportVerified = false;
      _passportCountry = 'Unspecified';
    }

    if (isPassportVerified != null) _isPassportVerified = isPassportVerified;
    if (passportCountry != null) _passportCountry = passportCountry;

    // Automatically sync with registered users database
    if (existingIndex != -1) {
      _registeredUsers[existingIndex] = RegisteredUserItem(
        id: _registeredUsers[existingIndex].id,
        name: name,
        email: email,
        phone: _currentUserPhone,
        passportNumber: _currentUserPassportNumber,
        isPassportVerified: _isPassportVerified,
        passportCountry: _passportCountry,
        tier: _registeredUsers[existingIndex].tier,
        memberSince: _registeredUsers[existingIndex].memberSince,
        totalBookings: _registeredUsers[existingIndex].totalBookings,
        status: _registeredUsers[existingIndex].status,
      );
    } else {
      _registeredUsers.insert(
        0,
        RegisteredUserItem(
          id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          name: name,
          email: email,
          phone: _currentUserPhone,
          passportNumber: _currentUserPassportNumber,
          isPassportVerified: _isPassportVerified,
          passportCountry: _passportCountry,
          tier: 'Premium Explorer',
          memberSince: DateTime.now().toString().split(' ').first,
          totalBookings: 1,
        ),
      );
    }
    notifyListeners();
    _savePreferences();
  }

  void updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? passportNumber,
    bool? isPassportVerified,
    String? passportCountry,
  }) {
    if (name != null && name.isNotEmpty) _currentUserName = name;
    if (email != null && email.isNotEmpty) _currentUserEmail = email;
    if (phone != null && phone.isNotEmpty) _currentUserPhone = phone;
    if (passportNumber != null && passportNumber.isNotEmpty) {
      _currentUserPassportNumber = passportNumber;
      final verification = PassportVerifierService.verify(passportNumber);
      _isPassportVerified = verification.isValid;
      if (verification.isValid) _passportCountry = verification.countryName;
    }
    if (isPassportVerified != null) _isPassportVerified = isPassportVerified;
    if (passportCountry != null) _passportCountry = passportCountry;
    notifyListeners();
    _savePreferences();
  }

  void logout() {
    _authToken = null;
    _userRole = 'customer';
    _isAdmin = false;
    _currentUserName = 'Guest';
    _currentUserEmail = '';
    _currentUserPhone = '';
    _currentUserPassportNumber = '';
    _isPassportVerified = false;
    notifyListeners();
    _savePreferences();
  }

  void loginUser(String input) {
    if (input.trim().isEmpty) {
      _currentUserName = 'Violet Nabise';
      _currentUserEmail = 'violet.nabise@safiri.com';
      _currentUserPhone = '+250788000999';
      _currentUserPassportNumber = 'PC9920148X';
      _isPassportVerified = true;
      _currentUserTier = 'Premium Explorer';
      notifyListeners();
      _savePreferences();
      return;
    }

    final trimmed = input.trim();
    final foundIndex = _registeredUsers.indexWhere(
      (u) => u.email.toLowerCase() == trimmed.toLowerCase() || u.name.toLowerCase() == trimmed.toLowerCase(),
    );

    if (foundIndex != -1) {
      final user = _registeredUsers[foundIndex];
      _currentUserName = user.name;
      _currentUserEmail = user.email;
      _currentUserPhone = user.phone;
      _currentUserPassportNumber = user.passportNumber;
      _isPassportVerified = user.isPassportVerified;
      _passportCountry = user.passportCountry;
      _currentUserTier = user.tier;
    } else {
      String displayName = trimmed;
      if (displayName.contains('@')) {
        displayName = displayName.split('@').first;
      }
      displayName = displayName
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .replaceAll('-', ' ')
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
          .join(' ');

      _currentUserName = displayName.isEmpty ? 'Valued Guest' : displayName;
      _currentUserEmail = trimmed.contains('@') ? trimmed : '$trimmed@safiri.com';
      _currentUserPhone = '+250788000999';
      _currentUserPassportNumber = 'PC9920148X';
      _isPassportVerified = true;
      _currentUserTier = 'Premium Explorer';

      _registeredUsers.insert(
        0,
        RegisteredUserItem(
          id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          name: _currentUserName,
          email: _currentUserEmail,
          phone: _currentUserPhone,
          passportNumber: _currentUserPassportNumber,
          isPassportVerified: _isPassportVerified,
          passportCountry: _passportCountry,
          tier: _currentUserTier,
          memberSince: DateTime.now().toString().split(' ').first,
          totalBookings: 1,
        ),
      );
    }
    notifyListeners();
    _savePreferences();
  }

  // Theme Engine
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _savePreferences();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _savePreferences();
  }

  // Multi-Currency Engine
  String _currentCurrency = 'USD';
  String get currentCurrency => _currentCurrency;

  Map<String, double> _liveExchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.78,
    'CAD': 1.36,
    'AUD': 1.52,
    'JPY': 155.0,
    'AED': 3.67,
    'RWF': 1320.0,
    'KES': 130.0,
    'ZAR': 18.5,
  };

  AppState() {
    refreshLiveExchangeRates();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('safiri_theme');
      if (theme != null) {
        _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
      final currency = prefs.getString('safiri_currency');
      if (currency != null && currencyData.containsKey(currency)) {
        _currentCurrency = currency;
      }
      final locale = prefs.getString('safiri_locale');
      if (locale != null && supportedLocales.containsKey(locale)) {
        _currentLocale = locale;
      }
      final token = prefs.getString('safiri_auth_token');
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        _currentUserName = prefs.getString('safiri_user_name') ?? _currentUserName;
        _currentUserEmail = prefs.getString('safiri_user_email') ?? _currentUserEmail;
        _currentUserPhone = prefs.getString('safiri_user_phone') ?? _currentUserPhone;
        _currentUserPassportNumber = prefs.getString('safiri_user_passport') ?? _currentUserPassportNumber;
        _passportCountry = prefs.getString('safiri_user_country') ?? _passportCountry;
        _isPassportVerified = prefs.getBool('safiri_user_verified') ?? _isPassportVerified;
        _currentUserTier = prefs.getString('safiri_user_tier') ?? _currentUserTier;
        _userRole = prefs.getString('safiri_user_role') ?? _userRole;
        _isAdmin = _userRole == 'admin';
        _currentUserAvatarUrl = prefs.getString('safiri_user_avatar') ?? _currentUserAvatarUrl;
      }
      final savedBookings = prefs.getString('safiri_saved_bookings');
      if (savedBookings != null && savedBookings.isNotEmpty) {
        final List decoded = jsonDecode(savedBookings);
        for (var item in decoded) {
          final b = BookingItem.fromJson(item);
          if (!_bookings.any((existing) => existing.id == b.id)) {
            _bookings.insert(0, b);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AppState] Error loading SharedPreferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('safiri_theme', _themeMode == ThemeMode.dark ? 'dark' : 'light');
      await prefs.setString('safiri_currency', _currentCurrency);
      await prefs.setString('safiri_locale', _currentLocale);
      if (_authToken != null && _authToken!.isNotEmpty) {
        await prefs.setString('safiri_auth_token', _authToken!);
        await prefs.setString('safiri_user_name', _currentUserName);
        await prefs.setString('safiri_user_email', _currentUserEmail);
        await prefs.setString('safiri_user_phone', _currentUserPhone);
        await prefs.setString('safiri_user_passport', _currentUserPassportNumber);
        await prefs.setString('safiri_user_country', _passportCountry);
        await prefs.setBool('safiri_user_verified', _isPassportVerified);
        await prefs.setString('safiri_user_tier', _currentUserTier);
        await prefs.setString('safiri_user_role', _userRole);
        await prefs.setString('safiri_user_avatar', _currentUserAvatarUrl);
      } else {
        await prefs.remove('safiri_auth_token');
      }
      final encodedBookings = jsonEncode(_bookings.map((b) => b.toJson()).toList());
      await prefs.setString('safiri_saved_bookings', encodedBookings);
    } catch (e) {
      debugPrint('[AppState] Error saving SharedPreferences: $e');
    }
  }

  Future<void> refreshLiveExchangeRates() async {
    final live = await CurrencyApiService.fetchLiveRates();
    if (live.isNotEmpty) {
      _liveExchangeRates = live;
      notifyListeners();
    }
  }

  static const Map<String, Map<String, dynamic>> currencyData = {
    'USD': {'symbol': '\$', 'rate': 1.0, 'name': 'US Dollar'},
    'EUR': {'symbol': '€', 'rate': 0.92, 'name': 'Euro'},
    'GBP': {'symbol': '£', 'rate': 0.78, 'name': 'British Pound'},
    'CAD': {'symbol': 'CA\$', 'rate': 1.36, 'name': 'Canadian Dollar'},
    'AUD': {'symbol': 'A\$', 'rate': 1.52, 'name': 'Australian Dollar'},
    'JPY': {'symbol': '¥', 'rate': 155.0, 'name': 'Japanese Yen'},
    'AED': {'symbol': 'AED ', 'rate': 3.67, 'name': 'UAE Dirham'},
    'RWF': {'symbol': 'FRw ', 'rate': 1320.0, 'name': 'Rwandan Franc'},
    'KES': {'symbol': 'KSh ', 'rate': 130.0, 'name': 'Kenyan Shilling'},
    'ZAR': {'symbol': 'R ', 'rate': 18.5, 'name': 'South African Rand'},
  };

  void setCurrency(String currencyCode) {
    if (currencyData.containsKey(currencyCode)) {
      _currentCurrency = currencyCode;
      notifyListeners();
      _savePreferences();
    }
  }

  String formatPrice(double amountUsd) {
    final data = currencyData[_currentCurrency] ?? currencyData['USD']!;
    final symbol = data['symbol'] as String;
    final rate = _liveExchangeRates[_currentCurrency] ?? (data['rate'] as double);
    final converted = amountUsd * rate;

    if (_currentCurrency == 'RWF' || _currentCurrency == 'KES' || _currentCurrency == 'JPY') {
      final formattedNum = converted.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
      return '$symbol$formattedNum';
    } else {
      return '$symbol${converted.toStringAsFixed(2)}';
    }
  }

  // Internationalization / Localization Engine
  String _currentLocale = 'en';
  String get currentLocale => _currentLocale;

  static const Map<String, Map<String, String>> supportedLocales = {
    'en': {'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    'fr': {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    'rw': {'name': 'Kinyarwanda', 'native': 'Kinyarwanda', 'flag': '🇷🇼'},
    'sw': {'name': 'Swahili', 'native': 'Kiswahili', 'flag': '🇰🇪'},
    'es': {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    'ar': {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
  };

  bool get isRtl => _currentLocale == 'ar';

  String tr(String key) {
    return AppTranslations.get(key, _currentLocale);
  }

  /// Returns time-sensitive greeting based on the user's local hour:
  /// 05:00 - 11:59: Good Morning / Bonjour / Mwaramutse
  /// 12:00 - 16:59: Good Afternoon / Bon Après-midi / Mwiriwe
  /// 17:00 - 04:59: Good Evening / Bonsoir / Mwiriwe Neza
  String getTimeGreeting({DateTime? overrideTime}) {
    final hour = (overrideTime ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return tr('greeting_morning');
    } else if (hour >= 12 && hour < 17) {
      return tr('greeting_afternoon');
    } else {
      return tr('greeting_evening');
    }
  }

  void setLocale(String localeCode) {
    if (supportedLocales.containsKey(localeCode)) {
      _currentLocale = localeCode;
      notifyListeners();
      _savePreferences();
    }
  }

  // Admin Role State
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void setAdminMode(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void loginAsAdmin() {
    _isAdmin = true;
    _selectedTabIndex = 0;
    notifyListeners();
  }

  // System Configurations
  double _markupPercentage = 5.0;
  double get markupPercentage => _markupPercentage;

  bool _isMaintenanceMode = false;
  bool get isMaintenanceMode => _isMaintenanceMode;

  String _adminSupportEmail = 'concierge@safiri.com';
  String get adminSupportEmail => _adminSupportEmail;

  bool _autoApproveVisas = false;
  bool get autoApproveVisas => _autoApproveVisas;

  void updateSystemConfig({
    double? markupPercentage,
    bool? isMaintenanceMode,
    String? adminSupportEmail,
    bool? autoApproveVisas,
  }) {
    if (markupPercentage != null) _markupPercentage = markupPercentage;
    if (isMaintenanceMode != null) _isMaintenanceMode = isMaintenanceMode;
    if (adminSupportEmail != null) _adminSupportEmail = adminSupportEmail;
    if (autoApproveVisas != null) _autoApproveVisas = autoApproveVisas;
    notifyListeners();
  }

  // Bookings List
  final List<BookingItem> _bookings = [
    BookingItem(
      id: '#SAF-2026-9841',
      title: 'Akagera Safari Adventure',
      userName: 'Violet Nabise',
      userTier: 'Premium Explorer',
      status: 'Active',
      type: 'Safari',
      dateRange: 'Oct 12 - Oct 18, 2026',
      priceUsd: 1450.0,
      qrCodeData: 'SAF-2026-9841-AKAGERA-VIOLET',
    ),
    BookingItem(
      id: '#FLT-2026-1102',
      title: 'KGL ➔ LHR Direct Flight',
      userName: 'Jean-Luc Habimana',
      userTier: 'VIP Concierge',
      status: 'Active',
      type: 'Flight',
      dateRange: 'Sep 02, 2026',
      priceUsd: 890.0,
      qrCodeData: 'FLT-2026-1102-RWA',
    ),
    BookingItem(
      id: '#HTL-2026-4421',
      title: 'Bisate Lodge Gorilla Trek Package',
      userName: 'Claire Dupont',
      userTier: 'Premium Explorer',
      status: 'Pending',
      type: 'Hotel',
      dateRange: 'Nov 10 - Nov 15, 2026',
      priceUsd: 3200.0,
      qrCodeData: 'HTL-2026-4421-BISATE',
    ),
  ];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);

  void addBooking(BookingItem booking) {
    _bookings.insert(0, booking);
    notifyListeners();
    _savePreferences();
  }

  void updateBookingStatus(String bookingId, String newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = BookingItem(
        id: old.id,
        title: old.title,
        userName: old.userName,
        userTier: old.userTier,
        status: newStatus,
        type: old.type,
        dateRange: old.dateRange,
        priceUsd: old.priceUsd,
        qrCodeData: old.qrCodeData,
        flightDetails: old.flightDetails,
      );
      notifyListeners();
      _savePreferences();
    }
  }

  // Visa Applications List
  final List<VisaApplicationItem> _visaApplications = [
    VisaApplicationItem(
      id: '#VISA-8492',
      destinationCountry: 'France (Schengen Area)',
      applicantNationality: 'Rwanda',
      currentStep: 2,
      status: 'Under Review',
      documentsUploaded: {
        'Passport Scan': true,
        'Proof of Funds': true,
        'Invitation Letter': false,
        'Biometrics Receipt': false,
      },
      submittedDate: '2026-08-15',
    ),
    VisaApplicationItem(
      id: '#VISA-8493',
      destinationCountry: 'United Kingdom',
      applicantNationality: 'Uganda',
      currentStep: 3,
      status: 'Documents Approved',
      documentsUploaded: {
        'Passport Scan': true,
        'Proof of Funds': true,
        'Invitation Letter': true,
        'Biometrics Receipt': true,
      },
      submittedDate: '2026-08-17',
    ),
  ];

  List<VisaApplicationItem> get visaApplications => List.unmodifiable(_visaApplications);

  void addVisaApplication(VisaApplicationItem app) {
    _visaApplications.insert(0, app);
    notifyListeners();
  }

  void toggleDocumentUpload(String visaId, String docName) {
    final app = _visaApplications.firstWhere((a) => a.id == visaId);
    app.documentsUploaded[docName] = !(app.documentsUploaded[docName] ?? false);
    
    // Auto advance step if all uploaded
    if (app.documentsUploaded.values.every((v) => v)) {
      app.currentStep = 3;
      app.status = 'Documents Approved';
    }
    notifyListeners();
  }

  void updateVisaStatus(String visaId, String newStatus) {
    final app = _visaApplications.firstWhere((a) => a.id == visaId);
    app.status = newStatus;
    notifyListeners();
  }

  // Hotel Enquiries List
  final List<HotelEnquiryItem> _hotelEnquiries = [
    HotelEnquiryItem(
      id: '#ENQ-9012',
      destination: 'Santorini Escape, Greece',
      checkIn: '2026-09-10',
      checkOut: '2026-09-17',
      rooms: 1,
      adults: 2,
      children: 0,
      infants: 0,
      status: 'Concierge Assigned',
      submittedTime: '2 hours ago',
    ),
  ];

  List<HotelEnquiryItem> get hotelEnquiries => List.unmodifiable(_hotelEnquiries);

  void addHotelEnquiry(HotelEnquiryItem enquiry) {
    _hotelEnquiries.insert(0, enquiry);
    notifyListeners();
  }

  // Admin Flights List
  final List<AdminFlightItem> _adminFlights = [
    AdminFlightItem(
      id: 'FL-101',
      flightNumber: 'WB-702',
      airline: 'RwandAir',
      origin: 'Kigali International',
      originCode: 'KGL',
      destination: 'London Heathrow',
      destinationCode: 'LHR',
      departureTime: '23:30',
      arrivalTime: '06:45 +1',
      priceUsd: 820.0,
      seatsAvailable: 42,
      status: 'Scheduled',
    ),
    AdminFlightItem(
      id: 'FL-102',
      flightNumber: 'KQ-442',
      airline: 'Kenya Airways',
      origin: 'Nairobi Jomo Kenyatta',
      originCode: 'NBO',
      destination: 'Dubai Intl',
      destinationCode: 'DXB',
      departureTime: '16:15',
      arrivalTime: '22:50',
      priceUsd: 650.0,
      seatsAvailable: 18,
      status: 'Scheduled',
    ),
    AdminFlightItem(
      id: 'FL-103',
      flightNumber: 'ET-808',
      airline: 'Ethiopian Airlines',
      origin: 'Addis Ababa Bole',
      originCode: 'ADD',
      destination: 'Paris Charles de Gaulle',
      destinationCode: 'CDG',
      departureTime: '01:20',
      arrivalTime: '07:30',
      priceUsd: 910.0,
      seatsAvailable: 8,
      status: 'Delayed',
    ),
  ];

  List<AdminFlightItem> get adminFlights => List.unmodifiable(_adminFlights);

  void addAdminFlight(AdminFlightItem flight) {
    _adminFlights.insert(0, flight);
    notifyListeners();
  }

  void updateAdminFlight(String flightId, {double? priceUsd, int? seatsAvailable, String? status}) {
    final index = _adminFlights.indexWhere((f) => f.id == flightId);
    if (index != -1) {
      if (priceUsd != null) _adminFlights[index].priceUsd = priceUsd;
      if (seatsAvailable != null) _adminFlights[index].seatsAvailable = seatsAvailable;
      if (status != null) _adminFlights[index].status = status;
      notifyListeners();
    }
  }

  void deleteAdminFlight(String flightId) {
    _adminFlights.removeWhere((f) => f.id == flightId);
    notifyListeners();
  }

  // Holiday Packages List (Matching safiriholidays.com Top Packages)
  final List<HolidayPackageItem> _holidayPackages = [
    HolidayPackageItem(
      id: 'PKG-GOA',
      title: 'Tropical Goa Beach & Heritage Escape',
      destination: 'Goa',
      duration: '4 Days / 3 Nights',
      priceUsd: 450.0,
      category: 'Beach',
      description: 'Experience golden sand beaches, sunset cruises, Portuguese architecture, and vibrant nightlife.',
      itineraryDays: [
        'Day 1: Arrival & Sunset Beach Stroll at Calangute',
        'Day 2: North Goa Sightseeing & Water Sports at Baga',
        'Day 3: Old Goa Churches & Mandovi River Sunset Cruise',
        'Day 4: Souvenir Shopping & Departure',
      ],
      inclusions: ['4-Star Hotel Stay', 'Daily Breakfast', 'Airport Transfers', 'Guided Tour & Sunset Cruise'],
      isFeatured: true,
      status: 'Active',
    ),
    HolidayPackageItem(
      id: 'PKG-KER',
      title: 'Kerala Backwaters & Houseboat Sanctuary',
      destination: 'Kerala',
      duration: '5 Days / 4 Nights',
      priceUsd: 620.0,
      category: 'Nature',
      description: 'Tranquil houseboat stays through Alleppey backwaters, tea plantation walks in Munnar, and Ayurvedic spa.',
      itineraryDays: [
        'Day 1: Arrival in Cochin & Transfer to Munnar Tea Gardens',
        'Day 2: Eravikulam National Park & Tea Museum Tour',
        'Day 3: Transfer to Alleppey & Deluxe Houseboat Check-in',
        'Day 4: Backwater Cruising & Authentic Keralan Cuisine',
        'Day 5: Transfer to Cochin Airport for Departure',
      ],
      inclusions: ['Luxury Houseboat Night', '3-Star Resorts', 'All Meals on Houseboat', 'Private AC Vehicle'],
      isFeatured: true,
      status: 'Active',
    ),
    HolidayPackageItem(
      id: 'PKG-MAN',
      title: 'Magical Manali & Himalayan Snow Pass',
      destination: 'Manali',
      duration: '6 Days / 5 Nights',
      priceUsd: 580.0,
      category: 'Adventure',
      description: 'Breathtaking Solang Valley adventures, snow points at Rohtang Pass, and scenic pine mountain vistas.',
      itineraryDays: [
        'Day 1: Arrival in Manali & Local Mall Road Walk',
        'Day 2: Hadimba Temple & Vashisht Hot Springs Visit',
        'Day 3: Solang Valley Paragliding & Cable Car Ride',
        'Day 4: Excursion to Rohtang Snow Pass & Glacier',
        'Day 5: Kasol & Manikaran Sahib Day Trip',
        'Day 6: Morning Shopping & Departure Transfer',
      ],
      inclusions: ['4-Star Mountain Resort', 'Breakfast & Dinner', 'Solang Valley Excursion', 'Private Driver'],
      isFeatured: true,
      status: 'Active',
    ),
    HolidayPackageItem(
      id: 'PKG-DXB',
      title: 'Dubai Glamour & Desert Safari Experience',
      destination: 'Dubai',
      duration: '5 Days / 4 Nights',
      priceUsd: 890.0,
      category: 'Luxury',
      description: 'Burj Khalifa Observation Deck, 4x4 Dune Bashing Desert Safari with BBQ Dinner, and Dubai Mall shopping.',
      itineraryDays: [
        'Day 1: Arrival in Dubai & Marina Dhow Dinner Cruise',
        'Day 2: Half-Day City Tour & Burj Khalifa 124th Floor Visit',
        'Day 3: 4x4 Dune Bashing Desert Safari & BBQ Dinner Show',
        'Day 4: Dubai Mall & Miracle Garden Exploration',
        'Day 5: Airport Departure Transfer',
      ],
      inclusions: ['4-Star City Hotel', 'Daily Breakfast', 'Desert Safari + Dinner', 'Dhow Cruise', 'Airport Transfers'],
      isFeatured: true,
      status: 'Active',
    ),
    HolidayPackageItem(
      id: 'PKG-THI',
      title: 'Thailand Paradise: Bangkok & Phuket Escape',
      destination: 'Thailand',
      duration: '6 Days / 5 Nights',
      priceUsd: 790.0,
      category: 'Beach',
      description: 'Speedboat tour to Phi Phi Islands, Grand Palace Bangkok, and vibrant night market street food tour.',
      itineraryDays: [
        'Day 1: Arrival in Phuket & Patong Beach Night Market',
        'Day 2: Phi Phi Islands Speedboat Excursion & Snorkeling',
        'Day 3: Phuket City Tour & Big Buddha Visit',
        'Day 4: Flight to Bangkok & Chao Phraya River Cruise',
        'Day 5: Grand Palace & Reclining Buddha Temple Tour',
        'Day 6: Shopping at MBK Center & Departure',
      ],
      inclusions: ['4-Star Hotels', 'Speedboat Phi Phi Ticket', 'Domestic Thailand Flight', 'Daily Breakfast'],
      isFeatured: true,
      status: 'Active',
    ),
    HolidayPackageItem(
      id: 'PKG-EUR',
      title: 'Grand Europe Explorer: Paris, Swiss Alps & Rome',
      destination: 'Europe',
      duration: '9 Days / 8 Nights',
      priceUsd: 2450.0,
      category: 'Culture',
      description: 'Eiffel Tower entry, Swiss Alps Mt. Titlis cable car, Venetian gondola ride, and Colosseum Rome tour.',
      itineraryDays: [
        'Day 1-2: Paris Eiffel Tower & Seine River Cruise',
        'Day 3-4: High-speed Train to Swiss Alps & Mt. Titlis Cable Car',
        'Day 5-6: Venice Canals & Gondola Ride',
        'Day 7-8: Rome Colosseum & Vatican Museums Tour',
        'Day 9: Departure from Rome Fiumicino Airport',
      ],
      inclusions: ['4-Star City Hotels', 'Inter-Europe Express Trains', 'Mt. Titlis Cable Car', 'Sightseeing Pass'],
      isFeatured: true,
      status: 'Active',
    ),
  ];

  List<HolidayPackageItem> get holidayPackages => List.unmodifiable(_holidayPackages);

  void addHolidayPackage(HolidayPackageItem package) {
    _holidayPackages.insert(0, package);
    notifyListeners();
  }

  // Holiday Enquiries / Bookings Container List
  final List<HolidayEnquiryBookingItem> _holidayEnquiries = [
    HolidayEnquiryBookingItem(
      id: '#HOL-7012',
      packageTitle: 'Dubai Glamour & Desert Safari Experience',
      destination: 'Dubai',
      duration: '5 Days / 4 Nights',
      adults: 2,
      children: 1,
      travelDate: '2026-11-15',
      priceUsd: 890.0,
      status: 'Enquiry Dispatched',
      submittedTime: '1 hour ago',
      type: 'Custom Quote',
    ),
  ];

  List<HolidayEnquiryBookingItem> get holidayEnquiries => List.unmodifiable(_holidayEnquiries);

  void addHolidayEnquiry(HolidayEnquiryBookingItem item) {
    _holidayEnquiries.insert(0, item);
    notifyListeners();
  }

  // Hotel Catalog Data Container (Matching safiriholidays.com hotel destinations)
  final List<HotelCatalogItem> _hotelCatalog = [
    HotelCatalogItem(
      id: 'HTL-DXB-01',
      name: 'Dubai Marina Luxury Resort & Spa',
      destination: 'Dubai',
      locationTag: 'Marina Waterfront, UAE',
      rating: 4.9,
      reviewsCount: 1240,
      priceUsdPerNight: 220.0,
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      amenities: ['Free WiFi', 'Breakfast Included', 'Infinity Pool', 'Spa & Fitness', 'Beachfront'],
      description: '5-Star luxury resort overlooking Dubai Marina with private beach access, temperature-controlled infinity pool, and fine dining restaurants.',
    ),
    HotelCatalogItem(
      id: 'HTL-BKK-01',
      name: 'Bangkok Grand Palace Riverside Hotel',
      destination: 'Bangkok',
      locationTag: 'Chao Phraya River, Thailand',
      rating: 4.7,
      reviewsCount: 890,
      priceUsdPerNight: 110.0,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      amenities: ['Free WiFi', 'Buffet Breakfast', 'Rooftop Pool', 'Airport Shuttle', 'Thai Spa'],
      description: 'Elegant riverside hotel offering serene Chao Phraya views, rooftop cocktail lounge, and seamless water taxi connections to temples.',
    ),
    HotelCatalogItem(
      id: 'HTL-SIN-01',
      name: 'Marina Bay Skyline Suites',
      destination: 'Singapore',
      locationTag: 'Marina Bay Sands Area, Singapore',
      rating: 4.8,
      reviewsCount: 1560,
      priceUsdPerNight: 280.0,
      imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      amenities: ['Free WiFi', 'Executive Breakfast', 'Sky Pool', 'Gym', 'Concierge Service'],
      description: 'Iconic skyscraper hotel with panoramic Marina Bay skyline views, world-class dining, and direct subway connection.',
    ),
    HotelCatalogItem(
      id: 'HTL-SAN-01',
      name: 'Santorini Sunset Cliff Villas',
      destination: 'Santorini',
      locationTag: 'Oia Cliffs, Greece',
      rating: 4.95,
      reviewsCount: 670,
      priceUsdPerNight: 340.0,
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
      amenities: ['Free WiFi', 'Champagne Breakfast', 'Private Plunge Pool', 'Sunset Balcony'],
      description: 'Cycladic whitewashed villa suites carved into Oia cliffs with unhindered Caldera views and private infinity plunge pools.',
    ),
    HotelCatalogItem(
      id: 'HTL-ZNZ-01',
      name: 'Zanzibar Turquoise Beach Resort',
      destination: 'Zanzibar',
      locationTag: 'Nungwi Beach, Tanzania',
      rating: 4.85,
      reviewsCount: 520,
      priceUsdPerNight: 190.0,
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
      amenities: ['Free WiFi', 'All-Inclusive Meals', 'Scuba Diving', 'Beach Bar', 'Spa'],
      description: 'Lush tropical beach sanctuary featuring authentic thatched roof bungalows, crystal-clear Indian Ocean waters, and coral reef excursions.',
    ),
    HotelCatalogItem(
      id: 'HTL-AKA-01',
      name: 'Akagera Wilderness Safari Lodge',
      destination: 'Akagera National Park',
      locationTag: 'Lake Ihema, Rwanda',
      rating: 4.9,
      reviewsCount: 310,
      priceUsdPerNight: 260.0,
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      amenities: ['Free WiFi', 'Full Board Meals', 'Game Drive Safari', 'Lake View Pool'],
      description: 'Eco-luxury tented lodge situated right on the banks of Lake Ihema inside Akagera National Park with guided Big-5 safaris.',
    ),
  ];

  List<HotelCatalogItem> get hotelCatalog => List.unmodifiable(_hotelCatalog);

  void updateHolidayPackage(String packageId, {double? priceUsd, bool? isFeatured, String? status}) {
    final index = _holidayPackages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      if (priceUsd != null) _holidayPackages[index].priceUsd = priceUsd;
      if (isFeatured != null) _holidayPackages[index].isFeatured = isFeatured;
      if (status != null) _holidayPackages[index].status = status;
      notifyListeners();
    }
  }

  void deleteHolidayPackage(String packageId) {
    _holidayPackages.removeWhere((p) => p.id == packageId);
    notifyListeners();
  }

  // Registered Users List
  final List<RegisteredUserItem> _registeredUsers = [
    RegisteredUserItem(
      id: 'USR-8001',
      name: 'Violet Nabise',
      email: 'violet.nabise@safiri.com',
      tier: 'Premium Explorer',
      memberSince: '2025-03-12',
      totalBookings: 8,
      status: 'Active',
    ),
    RegisteredUserItem(
      id: 'USR-8002',
      name: 'Jean-Luc Habimana',
      email: 'jl.habimana@safiri.com',
      tier: 'VIP Concierge',
      memberSince: '2024-11-05',
      totalBookings: 14,
      status: 'Active',
    ),
    RegisteredUserItem(
      id: 'USR-8003',
      name: 'Claire Dupont',
      email: 'claire.dupont@expedition.fr',
      tier: 'Standard',
      memberSince: '2026-01-20',
      totalBookings: 2,
      status: 'Active',
    ),
    RegisteredUserItem(
      id: 'USR-8004',
      name: 'Marcus Vance',
      email: 'marcus.vance@techcorp.io',
      tier: 'Premium Explorer',
      memberSince: '2025-08-14',
      totalBookings: 5,
      status: 'Suspended',
    ),
  ];

  List<RegisteredUserItem> get registeredUsers => List.unmodifiable(_registeredUsers);

  void updateUserTier(String userId, String newTier) {
    final index = _registeredUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _registeredUsers[index].tier = newTier;
      notifyListeners();
    }
  }

  void toggleUserStatus(String userId) {
    final index = _registeredUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _registeredUsers[index].status = _registeredUsers[index].status == 'Active' ? 'Suspended' : 'Active';
      notifyListeners();
    }
  }

  void addRegisteredUser(RegisteredUserItem user) {
    _registeredUsers.insert(0, user);
    notifyListeners();
  }
}
