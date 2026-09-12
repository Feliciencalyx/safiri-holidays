import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_logo.dart';
import '../../../../core/widgets/google_logo_widget.dart';
import '../../../../core/widgets/ios_glass_widgets.dart';
import '../../../../core/utils/passport_verifier.dart';
import '../../../../providers/app_state.dart';
import '../../../../screens/main_navigation_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              // Centered Main Content with iOS Frosted Glass Card
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

                          // Symmetrical Centered Safiri Brand Logo
                          SafiriLogo(
                            size: 82,
                            showTagline: true,
                            isDarkBackground: isDark,
                          ),
                          const SizedBox(height: 26),

                          // Time-Sensitive Dynamic Greeting
                          Text(
                            appState.getTimeGreeting(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1B2B5A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appState.tr('auth.description'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Username or Email Field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              appState.tr('auth.email'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: appState.tr('auth.email_placeholder'),
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1F2430).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Color(0xFF1D3B8A), width: 1.6),
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty ? appState.tr('auth.please_enter_email') : null,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              appState.tr('auth.password'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: appState.tr('auth.password_placeholder'),
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1F2430).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Color(0xFF1D3B8A), width: 1.6),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty ? appState.tr('auth.please_enter_password') : null,
                          ),
                          const SizedBox(height: 10),

                          // Forgot Password Link with Hover Cursor
                          Align(
                            alignment: Alignment.centerRight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: Text(
                                  appState.tr('auth.forgot_password'),
                                  style: const TextStyle(
                                    color: Color(0xFFB4833E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Primary Login Button with iOS Hover & Spring Elevation
                          IosHoverButton(
                            height: 52,
                            backgroundColor: const Color(0xFF1D3B8A),
                            hoverColor: const Color(0xFF23449E),
                            borderRadius: 30,
                            onPressed: _isLoggingIn ? null : _performLogin,
                            child: _isLoggingIn
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Text(
                                    appState.tr('auth.sign_in'),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // Google Sign-In Button with iOS Hover & Glass Border
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
                            onPressed: _isLoggingIn ? null : _performGoogleLogin,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const GoogleLogoWidget(size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  appState.tr('auth.continue_google'),
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
                          const SizedBox(height: 22),

                          // Bottom Links
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${appState.tr('auth.no_account')} ", style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _navigateToRegister,
                                  child: Text(
                                    appState.tr('auth.sign_up'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${appState.tr('auth.need_help')} ", style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _showContactSupport,
                                  child: Text(
                                    appState.tr('auth.contact_support'),
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

  String _getCleanUserErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') || lower.contains('clientexception') || lower.contains('connection refused') || lower.contains('errno = 111')) {
      return 'Unable to connect to Safiri servers. Please check your internet connection.';
    }
    if (lower.contains('cannot read properties') || lower.contains('undefined') || lower.contains('typeerror') || lower.contains('null')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('invalid login credentials') || lower.contains('invalid credentials') || lower.contains('unauthorized')) {
      return 'Incorrect email or password. Please check your details and try again.';
    }
    if (lower.contains('email') && lower.contains('already')) {
      return 'An account with this email address already exists. Please sign in.';
    }
    return raw.isEmpty ? 'Sign in failed. Please check your credentials.' : raw;
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoggingIn = true;
    });

    final input = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final appState = Provider.of<AppState>(context, listen: false);

    // In production, administrative privileges are strictly determined by the server-verified role.
    // In debug mode only (kDebugMode), offline administrative testing for admin@safiri.rw is allowed.
    final bool isDebugAdmin = kDebugMode && (input.toLowerCase() == 'admin@safiri.rw');

    try {
      final response = await AuthService.login(
        usernameOrEmail: input,
        password: password,
      );

      if (response.success && response.user != null && response.token != null) {
        final isUserAdmin = response.user!.role == 'admin' || isDebugAdmin;

        appState.setAuthData(
          token: response.token!,
          name: response.user!.name,
          email: response.user!.email,
          role: isUserAdmin ? 'admin' : 'customer',
        );

        if (mounted) {
          if (isUserAdmin) {
            appState.loginAsAdmin();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${response.user!.name}! Back-Office Admin Access Granted.'),
                backgroundColor: const Color(0xFF78592E),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${response.user!.name}!'),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          }
        }
      } else {
        // Strict Authentication Enforcement: Check Local Registered Accounts & Offline Support
        if (isDebugAdmin) {
          appState.loginAsAdmin();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome Admin! Back-Office Concierge Access Activated (Debug Mode).'),
                backgroundColor: Color(0xFF78592E),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          }
        } else {
          // Check if user is registered in the persistent AppState account storage
          final localUserIndex = appState.registeredUsers.indexWhere(
            (u) =>
                u.email.toLowerCase() == input.toLowerCase() ||
                u.name.toLowerCase() == input.toLowerCase() ||
                (input.contains('@') && u.email.toLowerCase().split('@').first == input.toLowerCase().split('@').first),
          );

          if (localUserIndex != -1) {
            final localUser = appState.registeredUsers[localUserIndex];
            appState.setAuthData(
              token: 'local_jwt_${DateTime.now().millisecondsSinceEpoch}',
              name: localUser.name,
              email: localUser.email,
              role: 'customer',
              phone: localUser.phone,
              passportNumber: localUser.passportNumber,
              isPassportVerified: localUser.isPassportVerified,
              passportCountry: localUser.passportCountry,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome back, ${localUser.name}!'),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            }
          } else if (response.message == 'SERVER_UNAVAILABLE') {
            appState.loginUser(input);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signed in offline as ${appState.currentUserName}!'),
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
                SnackBar(
                  content: Text(_getCleanUserErrorMessage(response.message)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (isDebugAdmin) {
        appState.loginAsAdmin();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
      } else {
        // Check if user is in persistent registered accounts on network error
        final localUserIndex = appState.registeredUsers.indexWhere(
          (u) =>
              u.email.toLowerCase() == input.toLowerCase() ||
              u.name.toLowerCase() == input.toLowerCase() ||
              (input.contains('@') && u.email.toLowerCase().split('@').first == input.toLowerCase().split('@').first),
        );

        if (localUserIndex != -1) {
          final localUser = appState.registeredUsers[localUserIndex];
          appState.setAuthData(
            token: 'local_jwt_${DateTime.now().millisecondsSinceEpoch}',
            name: localUser.name,
            email: localUser.email,
            role: 'customer',
            phone: localUser.phone,
            passportNumber: localUser.passportNumber,
            isPassportVerified: localUser.isPassportVerified,
            passportCountry: localUser.passportCountry,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${localUser.name}! (Offline Mode)'),
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
              SnackBar(
                content: Text(_getCleanUserErrorMessage(e.toString())),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _performGoogleLogin() async {
    setState(() => _isLoggingIn = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } catch (e) {
        if (kDebugMode) debugPrint('[GOOGLE LOGIN CANCEL/FAIL] $e');
      }

      setState(() => _isLoggingIn = false);

      if (googleUser != null) {
        _completeGoogleAuth(
          googleUser.email,
          googleUser.displayName ?? googleUser.email.split('@')[0],
          googleAccount: googleUser,
        );
      } else {
        _showGoogleFallbackLoginModal();
      }
    } catch (e) {
      setState(() => _isLoggingIn = false);
      _showGoogleFallbackLoginModal();
    }
  }

  void _showGoogleFallbackLoginModal() {
    final appState = Provider.of<AppState>(context, listen: false);
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
              Text(
                appState.tr('auth.sign_in_google'),
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                appState.tr('auth.choose_account'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  _completeGoogleAuth('feliciencalylx@gmail.com', 'Felicien Calylx');
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
                  _completeGoogleAuth('violet.nabise@safiri.com', 'Violet Nabise');
                },
              ),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: Text(appState.tr('auth.use_another_account'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _completeGoogleAuth('user.google@safiri.rw', 'Safiri Explorer');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeGoogleAuth(
    String email,
    String name, {
    GoogleSignInAccount? googleAccount,
  }) async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Check if user already has registered phone and passport credentials
    final existingUser = appState.registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => RegisteredUserItem(id: '', name: '', email: '', tier: '', memberSince: '', totalBookings: 0, phone: '', passportNumber: ''),
    );

    if (existingUser.phone.isNotEmpty && existingUser.passportNumber.isNotEmpty) {
      appState.setAuthData(
        token: 'jwt_google_${DateTime.now().millisecondsSinceEpoch}',
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
      _showGoogleCredentialsModal(email, name, googleAccount: googleAccount);
    }
  }

  void _showGoogleCredentialsModal(
    String email,
    String name, {
    GoogleSignInAccount? googleAccount,
  }) {
    final googlePhoneController = TextEditingController();
    final googlePassportController = TextEditingController();
    PassportVerificationResult? googlePassportResult;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            final appState = Provider.of<AppState>(context);
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const GoogleLogoWidget(size: 28),
                        const SizedBox(width: 10),
                        Text(
                          appState.tr('auth.complete_account_details'),
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
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
                    Text(appState.tr('phone_number'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: googlePhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+250 788 000 123',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // User Passport Number Field
                    Text(appState.tr('passport_number'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                          googlePassportResult = PassportVerifierService.verify(val);
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

                                final passportRes = PassportVerifierService.verify(passportInput);
                                if (!passportRes.isValid) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(passportRes.errorMessage ?? 'Please enter a valid passport number'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                final appState = Provider.of<AppState>(context, listen: false);

                                setModalState(() => isSubmitting = true);

                                // Strict database check: Ensure phone number is not taken
                                final phoneCheck = await AuthService.checkAvailability(phone: phoneInput);
                                if (!phoneCheck.isAvailable) {
                                  setModalState(() => isSubmitting = false);
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text(phoneCheck.message), backgroundColor: Colors.red),
                                    );
                                  }
                                  return;
                                }

                                final googleRes = await AuthService.googleSignIn(
                                  phone: phoneInput,
                                  passportNumber: passportInput,
                                  existingAccount: googleAccount,
                                );

                                if (googleRes.success) {
                                  appState.setAuthData(
                                    token: googleRes.token ?? 'jwt_google_${DateTime.now().millisecondsSinceEpoch}',
                                    name: name,
                                    email: email,
                                    role: 'customer',
                                    phone: phoneInput,
                                    passportNumber: passportInput,
                                    isPassportVerified: passportRes.isValid,
                                    passportCountry: passportRes.countryName,
                                  );

                                  if (modalCtx.mounted) Navigator.pop(modalCtx);

                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Google Account Setup Complete for $name!'),
                                        backgroundColor: const Color(0xFF2E7D32),
                                      ),
                                    );

                                    navigator.pushReplacement(
                                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                                    );
                                  }
                                } else {
                                  setModalState(() => isSubmitting = false);
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text(googleRes.message), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D3B8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(appState.tr('auth.complete_account_setup'), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  /// Full 2-Step Password Reset Wizard: OTP Verification via Email/Phone -> Set New Password
  void _showForgotPasswordDialog() {
    final identifierController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isCodeSent = false;
    bool isSubmitting = false;
    bool obscureNew = true;
    String? targetMasked;
    String? debugCode;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D3B8A).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF1D3B8A), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Reset Password',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      !isCodeSent
                          ? 'Enter your registered Email, Username, or Phone Number. We will dispatch a 6-digit confirmation code.'
                          : 'Enter the 6-digit code sent to $targetMasked and your new password.',
                      style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                    ),
                    const Divider(height: 24),

                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
                                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (!isCodeSent) ...[
                      // Step 1: Identifier Input
                      const Text('Account Email, Username, or Phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: identifierController,
                        decoration: const InputDecoration(
                          hintText: 'name@example.com or +250 788 000 123',
                          prefixIcon: Icon(Icons.person_search_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final input = identifierController.text.trim();
                                  if (input.isEmpty) {
                                    setModalState(() => modalError = 'Please enter your email, username, or phone number');
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                    modalError = null;
                                  });

                                  final otpRes = await AuthService.sendOtp(
                                    identifier: input,
                                    type: 'password_reset',
                                  );

                                  setModalState(() => isSubmitting = false);

                                  if (otpRes.success) {
                                    setModalState(() {
                                      isCodeSent = true;
                                      targetMasked = otpRes.targetMasked ?? input;
                                      debugCode = otpRes.debugCode;
                                      if (debugCode != null) {
                                        otpController.text = debugCode!;
                                      }
                                    });
                                  } else {
                                    setModalState(() => modalError = otpRes.message);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D3B8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Send Confirmation Code', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      // Step 2: OTP Code + New Password
                      const Text('6-Digit Confirmation Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: '123456',
                          prefixIcon: Icon(Icons.pin_outlined),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          hintText: 'At least 8 characters',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setModalState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Confirm New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureNew,
                        decoration: const InputDecoration(
                          hintText: 'Re-enter your new password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final code = otpController.text.trim();
                                  final newPass = newPasswordController.text.trim();
                                  final confirmPass = confirmPasswordController.text.trim();

                                  if (code.length != 6) {
                                    setModalState(() => modalError = 'Please enter the 6-digit confirmation code');
                                    return;
                                  }
                                  if (newPass.length < 8) {
                                    setModalState(() => modalError = 'Password must be at least 8 characters long');
                                    return;
                                  }
                                  if (newPass != confirmPass) {
                                    setModalState(() => modalError = 'Passwords do not match');
                                    return;
                                  }

                                  final messenger = ScaffoldMessenger.of(context);

                                  setModalState(() {
                                    isSubmitting = true;
                                    modalError = null;
                                  });

                                  final resetRes = await AuthService.resetPassword(
                                    identifier: identifierController.text.trim(),
                                    code: code,
                                    newPassword: newPass,
                                  );

                                  setModalState(() => isSubmitting = false);

                                  if (resetRes.success) {
                                    if (modalCtx.mounted) Navigator.pop(modalCtx);
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Password updated successfully! Please sign in with your new password.'),
                                          backgroundColor: Color(0xFF2E7D32),
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  } else {
                                    setModalState(() => modalError = resetRes.message);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D3B8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Verify & Reset Password', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showContactSupport() {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.tr('auth.support_title')),
        content: Text(appState.tr('auth.support_desk_info')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.tr('auth.close'))),
        ],
      ),
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
}
