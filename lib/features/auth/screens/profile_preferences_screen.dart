import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../main.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/image_helper.dart';

class ProfilePreferencesScreen extends StatefulWidget {
  const ProfilePreferencesScreen({super.key});

  @override
  State<ProfilePreferencesScreen> createState() => _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState extends State<ProfilePreferencesScreen> {
  int _currentStep = 0;

  // Basic Info
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _occupationController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  String? _photoUrl;

  // Housing Preferences
  RangeValues _budgetRange = const RangeValues(800, 1500);
  final _locationController = TextEditingController();
  DateTime _moveInDate = DateTime.now().add(const Duration(days: 30));
  final _leaseDurationController = TextEditingController(text: '12 months');

  // Lifestyle Preferences
  String _sleepSchedule = 'flexible';
  int _cleanlinessLevel = 3;
  bool _smoking = false;
  bool _drinking = false;
  bool _pets = false;
  bool _workFromHome = false;
  int _socialActivityLevel = 3;
  int _guestFrequency = 2;

  final List<String> _interests = [];
  final _interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _genderController.text = 'Male';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _occupationController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _leaseDurationController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _addInterest() {
    if (_interestsController.text.isNotEmpty) {
      setState(() {
        _interests.add(_interestsController.text);
        _interestsController.clear();
      });
    }
  }

  void _removeInterest(int index) {
    setState(() {
      _interests.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _moveInDate) {
      setState(() => _moveInDate = picked);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_ageController.text.isEmpty ||
          _genderController.text.isEmpty ||
          _occupationController.text.isEmpty ||
          _cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return false;
      }
      final age = int.tryParse(_ageController.text);
      if (age == null || age <= 0 || age > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid age number'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (RegExp(r'\d').hasMatch(_cityController.text) || RegExp(r'\d').hasMatch(_occupationController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City and Occupation cannot contain numbers'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _savePreferences() async {
    if (!_validateCurrentStep()) return;

    final age = int.tryParse(_ageController.text) ?? 25;

    final auth = context.read<AuthProvider>();
    await auth.setUserPreferences({
      'age': age,
      'gender': _genderController.text,
      'occupation': _occupationController.text,
      'city': _cityController.text,
      'bio': _bioController.text,
      'photoUrl': _photoUrl,
      'budgetRange': _budgetRange,
      'preferredLocation': _locationController.text,
      'moveInDate': _moveInDate,
      'leaseDuration': _leaseDurationController.text,
      'sleepSchedule': _sleepSchedule,
      'cleanlinessLevel': _cleanlinessLevel,
      'smoking': _smoking,
      'drinking': _drinking,
      'pets': _pets,
      'workFromHome': _workFromHome,
      'socialActivityLevel': _socialActivityLevel,
      'guestFrequency': _guestFrequency,
      'interests': _interests,
    });

    auth.setAuthenticated(true);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Progress Indicator
                      Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: i <= _currentStep ? AppColors.primary : AppColors.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (_currentStep == 0) _buildBasicInfoStep(),
                      if (_currentStep == 1) _buildHousingPreferencesStep(),
                      if (_currentStep == 2) _buildLifestylePreferencesStep(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_validateCurrentStep()) return;
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _savePreferences();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentStep < 2 ? 'Next' : 'Complete',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Share some basic information so roommates know you',
          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
        ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 50.ms).fade(duration: 400.ms, delay: 50.ms),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              try {
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _photoUrl = pickedFile.path);
                }
              } catch (e) {
                // Ignore if cancelled or permission denied
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _photoUrl != null
                    ? buildUserImage(
                        _photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        iconSize: 30,
                        fallbackBgColor: Colors.transparent,
                        fallbackIconColor: AppColors.primary,
                      )
                    : const Icon(Icons.camera_alt_rounded, size: 30, color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel('Age*', _ageController, 'e.g., 25', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Gender*',
          _genderController.text,
          ['Male', 'Female', 'Non-binary', 'Other'],
          (value) => setState(() => _genderController.text = value!),
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel('Occupation*', _occupationController, 'e.g., Software Engineer'),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel('City*', _cityController, 'e.g., New York'),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel('Bio (Optional)', _bioController, 'Tell us about yourself...', keyboardType: TextInputType.multiline, maxLines: 3),
      ],
    );
  }

  Widget _buildHousingPreferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Housing Preferences',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Let us know your housing preferences',
          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
        ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 50.ms).fade(duration: 400.ms, delay: 50.ms),
        const SizedBox(height: 32),
        Text(
          'Monthly Budget: \$${_budgetRange.start.toInt()} - \$${_budgetRange.end.toInt()}',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _budgetRange,
          min: 500,
          max: 3000,
          divisions: 50,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (RangeValues values) {
            setState(() => _budgetRange = values);
          },
        ),
        const SizedBox(height: 24),
        _buildTextFieldWithLabel('Preferred Location', _locationController, 'e.g., Manhattan'),
        const SizedBox(height: 16),
        Text(
          'Move-in Date: ${_moveInDate.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today_rounded, size: 18),
          label: const Text('Select Date'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel('Lease Duration', _leaseDurationController, 'e.g., 12 months'),
      ],
    );
  }

  Widget _buildLifestylePreferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle Preferences',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fade(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Help us match you with compatible roommates',
          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMedium),
        ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 50.ms).fade(duration: 400.ms, delay: 50.ms),
        const SizedBox(height: 32),
        _buildDropdownField(
          'Sleep Schedule',
          _sleepSchedule,
          ['early_bird', 'night_owl', 'flexible'],
          (value) => setState(() => _sleepSchedule = value!),
        ),
        const SizedBox(height: 16),
        _buildSliderField('Cleanliness Level', _cleanlinessLevel, 1, 5, (value) {
          setState(() => _cleanlinessLevel = value.toInt());
        }),
        const SizedBox(height: 16),
        _buildSwitchField('Smoking', _smoking, (value) => setState(() => _smoking = value)),
        const SizedBox(height: 12),
        _buildSwitchField('Drinking', _drinking, (value) => setState(() => _drinking = value)),
        const SizedBox(height: 12),
        _buildSwitchField('Pets', _pets, (value) => setState(() => _pets = value)),
        const SizedBox(height: 12),
        _buildSwitchField('Work from Home', _workFromHome, (value) => setState(() => _workFromHome = value)),
        const SizedBox(height: 16),
        _buildSliderField('Social Activity Level', _socialActivityLevel, 1, 5, (value) {
          setState(() => _socialActivityLevel = value.toInt());
        }),
        const SizedBox(height: 16),
        _buildSliderField('Guest Frequency', _guestFrequency, 1, 5, (value) {
          setState(() => _guestFrequency = value.toInt());
        }),
        const SizedBox(height: 16),
        _buildInterestsField(),
      ],
    );
  }

  Widget _buildTextFieldWithLabel(String label, TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: AppColors.textLight),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField(String label, int value, int min, int max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min).toInt(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchField(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInterestsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests (Optional)',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interestsController,
                decoration: InputDecoration(
                  hintText: 'Add an interest...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addInterest,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_interests.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _interests.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _interests[i],
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeInterest(i),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
