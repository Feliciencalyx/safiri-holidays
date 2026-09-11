import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_logo.dart';
import '../../../../core/widgets/google_logo_widget.dart';
import '../../../../core/widgets/ios_glass_widgets.dart';
import '../../../../core/utils/passport_verifier.dart';
import '../../../../providers/app_state.dart';
import '../../../../screens/main_navigation_screen.dart';

class CountryCodeItem {
  final String name;
  final String code;
  final String flag;
  final int expectedLength;

  const CountryCodeItem({
    required this.name,
    required this.code,
    required this.flag,
    required this.expectedLength,
  });
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  PassportVerificationResult? _passportResult;

  static const List<CountryCodeItem> _countries = [
    CountryCodeItem(name: 'Rwanda', code: '+250', flag: '🇷🇼', expectedLength: 9),
    CountryCodeItem(name: 'Kenya', code: '+254', flag: '🇰🇪', expectedLength: 9),
    CountryCodeItem(name: 'Tanzania', code: '+255', flag: '🇹🇿', expectedLength: 9),
    CountryCodeItem(name: 'Uganda', code: '+256', flag: '🇺🇬', expectedLength: 9),
    CountryCodeItem(name: 'United States', code: '+1', flag: '🇺🇸', expectedLength: 10),
    CountryCodeItem(name: 'United Kingdom', code: '+44', flag: '🇬🇧', expectedLength: 10),
    CountryCodeItem(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪', expectedLength: 9),
    CountryCodeItem(name: 'France', code: '+33', flag: '🇫🇷', expectedLength: 9),
    CountryCodeItem(name: 'India', code: '+91', flag: '🇮🇳', expectedLength: 10),
  ];

  CountryCodeItem _selectedCountry = _countries.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passportController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Strict Validation Rules
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address (e.g. name@domain.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Password must contain both letters and numbers';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    String cleanDigits = value.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.startsWith('0')) {
      cleanDigits = cleanDigits.substring(1);
    }
    if (cleanDigits.length != _selectedCountry.expectedLength) {
      return '${_selectedCountry.name} phone number must be ${_selectedCountry.expectedLength} digits';
    }
    return null;
  }

  Future<void> _handleGoogleSignUp() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoogleLogoWidget(size: 32),
              const SizedBox(height: 12),
              const Text(
                'Create Account with Google',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose an account to continue to Safiri Holidays',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),

              // Account 1: Felicien Calylx
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4285F4),
                  child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: const Text('Felicien Calylx', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('feliciencalylx@gmail.com'),
                onTap: () {
                  Navigator.pop(ctx);
                  _completeGoogleRegistration('feliciencalylx@gmail.com', 'Felicien Calylx');
                },
              ),

              // Account 2: Violet Nabise
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEA4335),
                  child: Text('V', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: const Text('Violet Nabise', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('violet.nabise@safiri.com'),
                onTap: () {
                  Navigator.pop(ctx);
                  _completeGoogleRegistration('violet.nabise@safiri.com', 'Violet Nabise');
                },
              ),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Use another account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _completeGoogleRegistration('user.google@safiri.rw', 'Safiri Explorer');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeGoogleRegistration(String email, String name) async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Check if user already has registered phone and passport credentials
    final existingUser = appState.registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => RegisteredUserItem(id: '', name: '', email: '', tier: '', memberSince: '', totalBookings: 0, phone: '', passportNumber: ''),
    );

    if (existingUser.phone.isNotEmpty && existingUser.passportNumber.isNotEmpty) {
      appState.setAuthData(
        token: 'mock_google_jwt_${DateTime.now().millisecondsSinceEpoch}',
        name: existingUser.name.isNotEmpty ? existingUser.name : name,
        email: email,
        role: 'customer',
        phone: existingUser.phone,
        passportNumber: existingUser.passportNumber,
        isPassportVerified: existingUser.isPassportVerified,
        passportCountry: existingUser.passportCountry,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${existingUser.name}! Signed in with Google.'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } else {
      _showGoogleCredentialsModal(email, name);
    }
  }

  void _showGoogleCredentialsModal(String email, String name) {
    final googlePhoneController = TextEditingController();
    final googlePassportController = TextEditingController();
    PassportVerificationResult? googlePassportResult;
    CountryCodeItem googleSelectedCountry = _countries.first;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        GoogleLogoWidget(size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Complete Account Details',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Authenticated as $name ($email). Please enter your real Phone Number & Passport Number to complete your account setup.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(height: 24),

                    // User Phone Number Field
                    const Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: googlePhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: googleSelectedCountry.expectedLength == 9 ? '788000123' : '5550199',
                        prefixIcon: InkWell(
                          onTap: () {
                            _showCountryPicker();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(googleSelectedCountry.flag, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 4),
                                Text(googleSelectedCountry.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Container(width: 1, height: 20, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // User Passport Number Field
                    const Text('Passport Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: googlePassportController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g. PC1234567 or AK098234',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        suffixIcon: googlePassportResult != null
                            ? Icon(
                                googlePassportResult!.isValid ? Icons.verified_user : Icons.error_outline,
                                color: googlePassportResult!.isValid ? Colors.green : Colors.red,
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          googlePassportResult = PassportVerifierService.verify(val, selectedNationality: googleSelectedCountry.name);
                        });
                      },
                    ),
                    if (googlePassportResult != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: googlePassportResult!.isValid ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: googlePassportResult!.isValid ? Colors.green : Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(googlePassportResult!.isValid ? Icons.check_circle : Icons.warning_amber_rounded, size: 16, color: googlePassportResult!.isValid ? Colors.green : Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                googlePassportResult!.isValid
                                    ? '${googlePassportResult!.verificationBadgeText} • ${googlePassportResult!.passportType}'
                                    : (googlePassportResult!.errorMessage ?? 'Invalid Passport Number'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: googlePassportResult!.isValid ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final phoneInput = googlePhoneController.text.trim();
                                final passportInput = googlePassportController.text.trim();

                                if (phoneInput.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter your phone number'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                final passportRes = PassportVerifierService.verify(passportInput, selectedNationality: googleSelectedCountry.name);
                                if (!passportRes.isValid) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(passportRes.errorMessage ?? 'Please enter a valid passport number'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                final appState = Provider.of<AppState>(context, listen: false);

                                String cleanDigits = phoneInput.replaceAll(RegExp(r'\D'), '');
                                if (cleanDigits.startsWith('0')) cleanDigits = cleanDigits.substring(1);
                                final fullPhone = '${googleSelectedCountry.code}$cleanDigits';

                                appState.setAuthData(
                                  token: 'mock_google_jwt_${DateTime.now().millisecondsSinceEpoch}',
                                  name: name,
                                  email: email,
                                  role: 'customer',
                                  phone: fullPhone,
                                  passportNumber: passportInput,
                                  isPassportVerified: passportRes.isValid,
                                  passportCountry: passportRes.countryName,
                                );

                                Navigator.pop(modalCtx);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Google Account Created & Verified for $name!'),
                                    backgroundColor: const Color(0xFF2E7D32),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D3B8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('COMPLETE ACCOUNT SETUP', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleStandardRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);

    // Format full international phone number with country code
    String cleanDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.startsWith('0')) {
      cleanDigits = cleanDigits.substring(1);
    }
    final fullPhone = '${_selectedCountry.code}$cleanDigits';

    try {
      final passportInput = _passportController.text.trim();
      final passportRes = PassportVerifierService.verify(passportInput, selectedNationality: _selectedCountry.name);

      final addressInput = _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : _selectedCountry.name;

      final res = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: fullPhone,
        address: addressInput,
        passportNumber: passportInput,
      );

      if (res.success && res.user != null) {
        appState.setAuthData(
          token: res.token ?? 'mock_jwt',
          name: res.user!.name,
          email: res.user!.email,
          role: res.user!.role,
          phone: fullPhone,
          address: addressInput,
          passportNumber: passportInput,
          isPassportVerified: passportRes.isValid,
          passportCountry: passportRes.countryName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully! Welcome, ${res.user!.name}.'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getCleanUserErrorMessage(res.message)), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getCleanUserErrorMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCleanUserErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') || lower.contains('clientexception') || lower.contains('connection refused') || lower.contains('errno = 111')) {
      return 'Unable to connect to Safiri servers. Please check your internet connection.';
    }
    if (lower.contains('cannot read properties') || lower.contains('undefined') || lower.contains('typeerror') || lower.contains('null')) {
      return 'Registration failed. Please check your details and try again.';
    }
    if (lower.contains('email') && (lower.contains('already') || lower.contains('exists') || lower.contains('taken'))) {
      return 'An account with this email address already exists. Please sign in.';
    }
    return raw.isEmpty ? 'Account creation failed. Please try again.' : raw;
  }

  void _showCountryPicker() {
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
                'Select Country Code',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final item = _countries[index];
                    final isSelected = _selectedCountry.code == item.code;

                    return ListTile(
                      leading: Text(item.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.code} (${item.expectedLength} digits)'),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF1D3B8A)) : null,
                      onTap: () {
                        setState(() => _selectedCountry = item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
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
              Text(
                appState.tr('select_language'),
                style: const TextStyle(
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
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1D3B8A)) : null,
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBackground : const Color(0xFFF3F5FA);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IosGlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                  child: IosGlassCard(
                    isDark: isDark,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),

                          // Symmetrical Centered Safiri Brand Mark
                          SafiriLogo(size: 76, showTagline: true, isDarkBackground: isDark),
                          const SizedBox(height: 24),

                          Text(
                            appState.tr('auth.create_account'),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1B2B5A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appState.tr('auth.join_safiri'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // GOOGLE SIGN-UP BUTTON with iOS Hover
                          IosHoverButton(
                            height: 50,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                            hoverColor: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF7F9FD),
                            borderRadius: 30,
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            normalShadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            hoverShadows: [
                              BoxShadow(
                                color: const Color(0xFF4285F4).withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            onPressed: _isLoading ? null : _handleGoogleSignUp,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const GoogleLogoWidget(size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  appState.tr('auth.create_account_google'),
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D3B8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(appState.tr('auth.or_register_email'), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: appState.tr('full_name'),
                              hintText: 'John Doe',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
                          ),
                          const SizedBox(height: 14),

                          // Email Field with Strict Format Validation
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: appState.tr('email_address'),
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),

                          // Phone Number Field with Country Code Picker
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: appState.tr('phone_number'),
                              hintText: '0780 000 000',
                              prefixIcon: InkWell(
                                onTap: _showCountryPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedCountry.code,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            validator: _validatePhone,
                          ),
                          const SizedBox(height: 14),

                          // Residential / City Address Field
                          TextFormField(
                            controller: _addressController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Residential / City Address',
                              hintText: 'e.g. Kigali, Rwanda',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Passport Number Field with Instant Verification Feedback
                          TextFormField(
                            controller: _passportController,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (val) {
                              setState(() {
                                _passportResult = PassportVerifierService.verify(
                                  val,
                                  selectedNationality: _selectedCountry.name,
                                );
                              });
                            },
                            decoration: InputDecoration(
                              labelText: appState.tr('passport_number'),
                              hintText: 'e.g. PC9920148X or A12345678',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              suffixIcon: _passportResult == null || _passportController.text.isEmpty
                                  ? null
                                  : Icon(
                                      _passportResult!.isValid ? Icons.verified_rounded : Icons.info_outline_rounded,
                                      color: _passportResult!.isValid ? const Color(0xFF2E7D32) : Colors.orange,
                                    ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your passport number';
                              }
                              final res = PassportVerifierService.verify(v.trim(), selectedNationality: _selectedCountry.name);
                              if (!res.isValid) {
                                return res.errorMessage ?? 'Invalid passport number format';
                              }
                              return null;
                            },
                          ),

                          // Live Passport Validation Card
                          if (_passportResult != null && _passportController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _passportResult!.isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _passportResult!.isValid ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _passportResult!.isValid ? Icons.check_circle : Icons.warning_amber_rounded,
                                      size: 16,
                                      color: _passportResult!.isValid ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _passportResult!.isValid
                                            ? 'Verified: ${_passportResult!.countryName} (${_passportResult!.passportType})'
                                            : (_passportResult!.errorMessage ?? 'Passport verification in progress...'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _passportResult!.isValid ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),

                          // Password Field with Visibility Toggle
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: appState.tr('auth.password'),
                              hintText: 'Min 8 chars (letters & numbers)',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 24),

                          // Standard CTA Submit Button with iOS Hover
                          IosHoverButton(
                            height: 52,
                            backgroundColor: const Color(0xFF1D3B8A),
                            hoverColor: const Color(0xFF23449E),
                            borderRadius: 30,
                            onPressed: _isLoading ? null : _handleStandardRegister,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    appState.tr('auth.create_account').toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Login Navigation Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${appState.tr('auth.already_have_account')} ", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    appState.tr('auth.sign_in'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Elevated Top-Right iOS Frosted Glass Language Switcher Button
              Positioned(
                top: 14,
                right: 18,
                child: IosGlassLanguageButton(
                  flag: AppState.supportedLocales[appState.currentLocale]?['flag'] ?? '🌐',
                  languageCode: appState.currentLocale,
                  onTap: () => _showLanguageSelector(context),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
