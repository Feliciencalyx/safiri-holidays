import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../utils/passport_verifier.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

class UserProfileModal extends StatefulWidget {
  const UserProfileModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UserProfileModal(),
    );
  }

  @override
  State<UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends State<UserProfileModal> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passportController;
  PassportVerificationResult? _passportResult;

  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.currentUserName);
    _emailController = TextEditingController(text: appState.currentUserEmail);
    _phoneController = TextEditingController(text: appState.currentUserPhone);
    _passportController = TextEditingController(text: appState.currentUserPassportNumber);
    _passportResult = PassportVerifierService.verify(appState.currentUserPassportNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  void _saveProfileUpdates() {
    final appState = Provider.of<AppState>(context, listen: false);
    final passportInput = _passportController.text.trim();
    final passportRes = PassportVerifierService.verify(passportInput);

    appState.updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      passportNumber: passportInput,
      isPassportVerified: passportRes.isValid,
      passportCountry: passportRes.countryName,
    );

    setState(() {
      _passportResult = passportRes;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User profile credentials updated successfully across whole system!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  ImageProvider? _getAvatarProvider(String urlOrPath) {
    if (urlOrPath.isEmpty) return null;
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return NetworkImage(urlOrPath);
    }
    final file = File(urlOrPath);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return NetworkImage(urlOrPath);
  }

  Future<void> _pickImageFromDevice(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (!mounted) return;
        final appState = Provider.of<AppState>(context, listen: false);
        appState.updateUserAvatarUrl(image.path);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated from device!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAvatarPicker() {
    final appState = Provider.of<AppState>(context, listen: false);
    final customUrlController = TextEditingController(text: appState.currentUserAvatarUrl);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upload Profile Photo',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Choose a real photo directly from your device gallery or camera:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),

                // Device Gallery & Camera Pick Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImageFromDevice(ImageSource.gallery);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF052469),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.photo_library_rounded, size: 20),
                        label: const Text(
                          'DEVICE GALLERY',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImageFromDevice(ImageSource.camera);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF052469), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Color(0xFF052469)),
                        label: const Text(
                          'TAKE PHOTO',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Or select from sample avatars / custom link:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    itemBuilder: (ctx, index) {
                      final avatarUrl = _presetAvatars[index];
                      final isSelected = appState.currentUserAvatarUrl == avatarUrl;

                      return GestureDetector(
                        onTap: () {
                          appState.updateUserAvatarUrl(avatarUrl);
                          Navigator.pop(ctx);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF052469) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: customUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Photo Web URL',
                    hintText: 'https://example.com/photo.jpg',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (customUrlController.text.trim().isNotEmpty) {
                        appState.updateUserAvatarUrl(customUrlController.text.trim());
                        Navigator.pop(ctx);
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF78592E), foregroundColor: Colors.white),
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('SET PHOTO URL'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount() {
    final appState = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your user account? All your saved bookings, verified passport credentials, and system settings will be removed from the database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close profile sheet
                appState.deleteUserAccount();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your account has been deleted from the database.'),
                    backgroundColor: Colors.red,
                  ),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('PERMANENTLY DELETE'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    final appState = Provider.of<AppState>(context, listen: false);
    Navigator.pop(context); // Close modal
    appState.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        backgroundColor: Color(0xFF052469),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MajesticHorizonTheme.darkSurfaceCard : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black;

    final isVerified = appState.isPassportVerified;
    final passportInfo = PassportVerifierService.verify(appState.currentUserPassportNumber);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: User Profile Avatar & Basic Info
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF052469),
                      backgroundImage: appState.currentUserAvatarUrl.isNotEmpty
                          ? _getAvatarProvider(appState.currentUserAvatarUrl)
                          : null,
                      child: appState.currentUserAvatarUrl.isEmpty
                          ? Text(
                              appState.currentUserName.isNotEmpty ? appState.currentUserName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFED39D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: Color(0xFF052469)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.currentUserName,
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(appState.currentUserEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF052469).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${appState.currentUserTier} • ID: #USR-8492',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: const Color(0xFF052469)),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 32),

            // SECTION 1: USER CREDENTIALS & PASSPORT VERIFICATION STATUS
            if (!_isEditing) ...[
              const Text(
                'CONNECTED USER CREDENTIALS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
              ),
              const SizedBox(height: 12),

              _buildCredentialTile(
                icon: Icons.person_outline_rounded,
                title: 'Full Name',
                subtitle: appState.currentUserName,
              ),
              _buildCredentialTile(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle: appState.currentUserEmail,
              ),
              _buildCredentialTile(
                icon: Icons.phone_android_rounded,
                title: 'Phone Number',
                subtitle: appState.currentUserPhone,
              ),
              _buildCredentialTile(
                icon: Icons.badge_outlined,
                title: 'Passport Number',
                subtitle: appState.currentUserPassportNumber,
                badgeText: isVerified ? 'VERIFIED ICAO 9303' : 'UNVERIFIED',
                isVerified: isVerified,
              ),
              const SizedBox(height: 10),

              // Verifier Confidence Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green.withValues(alpha: 0.08) : Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isVerified ? Colors.green : Colors.amber),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user_rounded : Icons.info_outline_rounded,
                      color: isVerified ? Colors.green.shade800 : Colors.amber.shade900,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified ? passportInfo.verificationBadgeText : 'Passport Pending Automatic Verification',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isVerified ? Colors.green.shade900 : Colors.amber.shade900,
                            ),
                          ),
                          Text(
                            isVerified
                                ? '${passportInfo.countryName} • ${passportInfo.passportType}'
                                : 'Update your passport number to verify international flight dispatch eligibility.',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ACTION BUTTONS (Logout & Delete)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF052469)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF052469), size: 18),
                      label: const Text(
                        'LOG OUT',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF052469)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 18),
                      label: const Text(
                        'DELETE USER',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // SECTION 2: EDIT PROFILE FORM
              const Text(
                'UPDATE USER CREDENTIALS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_android_rounded)),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _passportController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Passport Number',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  suffixIcon: _passportResult != null
                      ? Icon(
                          _passportResult!.isValid ? Icons.verified_user : Icons.error_outline,
                          color: _passportResult!.isValid ? Colors.green : Colors.red,
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {
                    _passportResult = PassportVerifierService.verify(val);
                  });
                },
              ),
              if (_passportResult != null) ...[
                const SizedBox(height: 6),
                Text(
                  _passportResult!.isValid
                      ? _passportResult!.verificationBadgeText
                      : (_passportResult!.errorMessage ?? 'Invalid format'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _passportResult!.isValid ? Colors.green : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveProfileUpdates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF052469),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('SAVE UPDATES', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    bool isVerified = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF052469)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green : Colors.amber.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
