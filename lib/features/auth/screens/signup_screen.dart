import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  
  final List<Map<String, String>> _countries = [
    {'name': 'USA', 'code': '+1', 'length': '10'},
    {'name': 'UK', 'code': '+44', 'length': '10'},
    {'name': 'India', 'code': '+91', 'length': '10'},
    {'name': 'Australia', 'code': '+61', 'length': '9'},
    {'name': 'Germany', 'code': '+49', 'length': '10'},
    {'name': 'Canada', 'code': '+1', 'length': '10'},
    {'name': 'France', 'code': '+33', 'length': '9'},
    {'name': 'UAE', 'code': '+971', 'length': '9'},
    {'name': 'Singapore', 'code': '+65', 'length': '8'},
    {'name': 'Japan', 'code': '+81', 'length': '10'},
    {'name': 'Brazil', 'code': '+55', 'length': '11'},
  ];
  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      auth.updateSignupData({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: _phoneController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back + Logo
                  Row(
                    children: [
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
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                      ),
                    ],
                  ).animate().fade(duration: 400.ms),

                  const SizedBox(height: 32),

                  Text(
                    'Create Account ✨',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Join thousands finding their perfect home and roommates',
                    style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 50.ms).fade(duration: 400.ms, delay: 50.ms),

                  const SizedBox(height: 32),

                  _buildField('Full Name', _nameController, Icons.person_outline_rounded, 'Jordan Taylor',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your name';
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Name should only contain letters';
                        return null;
                      },
                      delay: 100),
                  const SizedBox(height: 16),
                  _buildField('Email Address', _emailController, Icons.email_outlined, 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!RegExp(r'^[a-zA-Z][\w-\.]*@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                        return null;
                      },
                      delay: 150),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  Text(
                    'Password',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textLight),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 250.ms).fade(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 20),

                  // Terms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              text: 'I agree to the ',
                              style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(text: ' and ', style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 13)),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _signUp,
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                    ),
                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 300.ms).fade(duration: 400.ms, delay: 300.ms),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator, int delay = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textLight),
          ),
          validator: validator,
        ),
      ],
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: delay.ms).fade(duration: 400.ms, delay: delay.ms);
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, String>>(
                  value: _selectedCountry,
                  items: _countries.map((c) => DropdownMenuItem(
                    value: c, 
                    child: Text('${c['name']} (${c['code']})', style: GoogleFonts.outfit(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCountry = v!),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '${_selectedCountry['code']} Enter ${_selectedCountry['length']} digits',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textLight),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your phone number';
                  final digits = v.replaceAll(RegExp(r'\D'), '');
                  final requiredLen = int.tryParse(_selectedCountry['length'] ?? '10') ?? 10;
                  if (digits.length != requiredLen) {
                    return 'Must be exactly $requiredLen digits for ${_selectedCountry['name']}';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 200.ms).fade(duration: 400.ms, delay: 200.ms);
  }
}
