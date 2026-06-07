import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import 'profile_preferences_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerified = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.verifyOtp(_otp);
    setState(() => _isVerified = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfilePreferencesScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textDark),
                ),
              ).animate().fade(duration: 300.ms),

              const SizedBox(height: 40),

              if (_isVerified)
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, size: 60, color: AppColors.success),
                    )
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut)
                        .fade(duration: 400.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Verified! ✓',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your phone number has been verified.\nTaking you to Homie...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
                    ),
                  ],
                )
              else ...[
                // Phone icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 36),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fade(duration: 300.ms),

                const SizedBox(height: 32),

                Text(
                  'Verify your number',
                  style: GoogleFonts.outfit(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms),

                const SizedBox(height: 10),

                RichText(
                  text: TextSpan(
                    text: 'We sent a 6-digit code to ',
                    style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
                    children: [
                      TextSpan(
                        text: widget.phone,
                        style: GoogleFonts.outfit(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // OTP fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          fillColor: _controllers[i].text.isNotEmpty
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.white,
                          filled: true,
                        ),
                        onChanged: (v) {
                          setState(() {});
                          if (v.isNotEmpty && i < 5) {
                            _focusNodes[i + 1].requestFocus();
                          } else if (v.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          if (_otp.length == 6) _verify();
                        },
                      ),
                    )
                        .animate()
                        .scale(duration: 300.ms, delay: (i * 50).ms, curve: Curves.easeOut)
                        .fade(duration: 300.ms, delay: (i * 50).ms);
                  }),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _verify,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Verify Code',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 300.ms).fade(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the code? ',
                      style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Resend',
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
