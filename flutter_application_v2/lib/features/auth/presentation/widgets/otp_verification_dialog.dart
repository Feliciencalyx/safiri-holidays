import 'dart:async';
import 'package:material_ui/material_ui.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String target;
  final String? debugCode;
  final Future<String?> Function(String code) onVerify;
  final Future<bool> Function()? onResend;

  const OtpVerificationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.target,
    this.debugCode,
    required this.onVerify,
    this.onResend,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String target,
    String? debugCode,
    required Future<String?> Function(String code) onVerify,
    Future<bool> Function()? onResend,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OtpVerificationDialog(
        title: title,
        subtitle: subtitle,
        target: target,
        debugCode: debugCode,
        onVerify: onVerify,
        onResend: onResend,
      ),
    );
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendTimerSeconds = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendTimerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() => _resendTimerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _errorMessage = null);

    // Handle paste of complete 6-digit code
    if (value.length > 1) {
      final cleanDigits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < cleanDigits.length; i++) {
        _controllers[i].text = cleanDigits[i];
      }
      if (cleanDigits.length >= 6) {
        _focusNodes[5].requestFocus();
        _handleVerify();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentCode.length == 6) {
          _handleVerify();
        }
      }
    }
  }

  Future<void> _handleVerify() async {
    final code = _currentCode;
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final error = await widget.onVerify(code);
      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isVerifying = false;
          _errorMessage = error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleResend() async {
    if (_resendTimerSeconds > 0 || _isResending || widget.onResend == null) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final success = await widget.onResend!();
    if (!mounted) return;

    setState(() => _isResending = false);

    if (success) {
      _startResendTimer();
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new 6-digit verification code has been dispatched.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } else {
      setState(() => _errorMessage = 'Failed to resend code. Please try again in a moment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? const Color(0xFF161B26) : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: surfaceBg,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Icon with subtle glowing container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D3B8A), Color(0xFF031B4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D3B8A).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle & Masked Target
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: '${widget.subtitle}\n'),
                  TextSpan(
                    text: widget.target,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D3B8A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6-Digit OTP Input Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 44,
                  height: 54,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1F2430) : const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1D3B8A), width: 2),
                      ),
                    ),
                    onChanged: (val) => _onDigitChanged(index, val),
                  ),
                );
              }),
            ),

            // Error Display
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Dev helper preview (if provided)
            if (widget.debugCode != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final code = widget.debugCode!;
                  for (int i = 0; i < 6 && i < code.length; i++) {
                    _controllers[i].text = code[i];
                  }
                  setState(() => _errorMessage = null);
                },
                child: Text(
                  'Auto-fill code for testing: ${widget.debugCode}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D3B8A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Verify & Confirm',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 14),

            // Resend Code Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
                TextButton(
                  onPressed: _resendTimerSeconds == 0 && !_isResending ? _handleResend : null,
                  child: Text(
                    _resendTimerSeconds > 0 ? 'Resend in ${_resendTimerSeconds}s' : 'Resend Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _resendTimerSeconds == 0 ? const Color(0xFF1D3B8A) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
