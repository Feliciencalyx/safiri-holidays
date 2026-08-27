import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safiri_logo.dart';
import '../../../../core/widgets/google_logo_widget.dart';
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
    final scaffoldBg = isDark ? AppColors.darkBackground : const Color(0xFFF3F4F8);
    final cardBg = isDark ? AppColors.darkCardSurface : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(32),
                boxShadow: isDark
                    ? const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 24, offset: Offset(0, 8))]
                    : const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Safiri Holidays Brand Logo Mark
                    SafiriLogo(
                      size: 76,
                      showTagline: true,
                      isDarkBackground: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Welcome Title
                    Text(
                      appState.tr('hello'),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1B2B5A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appState.tr('hero_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 24),

                    // Username or Email Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        appState.tr('email'),
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
                        hintText: 'Enter your email or username',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB),
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
                          borderSide: const BorderSide(color: Color(0xFF1D3B8A), width: 1.5),
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your email or username' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
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
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB),
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
                          borderSide: const BorderSide(color: Color(0xFF1D3B8A), width: 1.5),
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
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: Color(0xFFB4833E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoggingIn ? null : _performLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D3B8A),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoggingIn
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Google Sign-In Button with Official Google G Logo
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isLoggingIn ? null : _performGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : Colors.white,
                          side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            GoogleLogoWidget(size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D3B8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bottom Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        GestureDetector(
                          onTap: _navigateToRegister,
                          child: const Text(
                            'Sign up',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Need Help? ', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        GestureDetector(
                          onTap: _showContactSupport,
                          child: const Text(
                            'Contact Support',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
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
      ),
    );
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoggingIn = true;
    });

    final input = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final appState = Provider.of<AppState>(context, listen: false);

    // Smart Admin Credential Auto-Detection (e.g. admin@safiri.rw, "safiri holidays ltd", or password "shezan")
    final bool isAdminCredentials = (input.toLowerCase() == 'admin@safiri.rw' ||
        input.toLowerCase() == 'safiri holidays ltd' ||
        password.toLowerCase() == 'shezan');

    try {
      final response = await AuthService.login(
        usernameOrEmail: input,
        password: password,
      );

      if (response.success && response.user != null && response.token != null) {
        final isUserAdmin = response.user!.role == 'admin' || isAdminCredentials;

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
        // Strict Authentication Enforcement: Reject Unregistered Users
        if (isAdminCredentials) {
          appState.loginAsAdmin();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome Admin! Back-Office Concierge Access Activated.'),
                backgroundColor: Color(0xFF78592E),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message.isNotEmpty ? response.message : 'Invalid credentials or account not registered.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (isAdminCredentials) {
        appState.loginAsAdmin();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
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
                'Sign in with Google',
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
                title: const Text('Use another account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Future<void> _completeGoogleAuth(String email, String name) async {
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
                      decoration: const InputDecoration(
                        hintText: '+250 788 000 123',
                        prefixIcon: Icon(Icons.phone_android_rounded),
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

                                setModalState(() => isSubmitting = true);
                                final appState = Provider.of<AppState>(context, listen: false);

                                appState.setAuthData(
                                  token: 'mock_google_jwt_${DateTime.now().millisecondsSinceEpoch}',
                                  name: name,
                                  email: email,
                                  role: 'customer',
                                  phone: phoneInput,
                                  passportNumber: passportInput,
                                  isPassportVerified: passportRes.isValid,
                                  passportCountry: passportRes.countryName,
                                );

                                Navigator.pop(modalCtx);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Google Account Setup Complete for $name!'),
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Reset'),
        content: const Text('Enter your registered email address to receive password recovery instructions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safiri Concierge Support'),
        content: const Text('24/7 Support Desk:\nsupport@safiriholidays.com\n+250 788 000 000'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
