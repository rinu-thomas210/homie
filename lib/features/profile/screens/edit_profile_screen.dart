import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _occupationController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _leaseDurationController;

  late RangeValues _budgetRange;
  late DateTime _moveInDate;
  late String _sleepSchedule;
  late int _cleanlinessLevel;
  late bool _smoking;
  late bool _drinking;
  late bool _pets;
  late bool _workFromHome;
  late int _socialActivityLevel;
  late int _guestFrequency;
  late List<String> _interests;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    
    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age.toString());
    _genderController = TextEditingController(text: user.gender);
    _occupationController = TextEditingController(text: user.occupation);
    _cityController = TextEditingController(text: user.city);
    _bioController = TextEditingController(text: user.bio);
    _locationController = TextEditingController(text: user.preferredLocation);
    _leaseDurationController = TextEditingController(text: user.leaseDuration);

    _budgetRange = user.budgetRange;
    _moveInDate = user.moveInDate;
    _sleepSchedule = user.sleepSchedule;
    _cleanlinessLevel = user.cleanlinessLevel;
    _smoking = user.smoking;
    _drinking = user.drinking;
    _pets = user.pets;
    _workFromHome = user.workFromHome;
    _socialActivityLevel = user.socialActivityLevel;
    _guestFrequency = user.guestFrequency;
    _interests = List.from(user.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _occupationController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _leaseDurationController.dispose();
    super.dispose();
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

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _occupationController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser!;

    final updatedUser = UserModel(
      id: currentUser.id,
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? currentUser.age,
      gender: _genderController.text,
      occupation: _occupationController.text,
      city: _cityController.text,
      bio: _bioController.text,
      photoUrl: currentUser.photoUrl,
      isVerified: currentUser.isVerified,
      rating: currentUser.rating,
      reviewCount: currentUser.reviewCount,
      budgetRange: _budgetRange,
      preferredLocation: _locationController.text,
      moveInDate: _moveInDate,
      leaseDuration: _leaseDurationController.text,
      sleepSchedule: _sleepSchedule,
      cleanlinessLevel: _cleanlinessLevel,
      smoking: _smoking,
      drinking: _drinking,
      pets: _pets,
      workFromHome: _workFromHome,
      socialActivityLevel: _socialActivityLevel,
      guestFrequency: _guestFrequency,
      matches: currentUser.matches,
      interests: _interests,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    auth.updateUserProfile(updatedUser);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Name*', _nameController),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Age*', _ageController, keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Gender*', _genderController),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Occupation*', _occupationController),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('City*', _cityController),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Bio (Optional)', _bioController, keyboardType: TextInputType.multiline, maxLines: 3),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Housing Preferences'),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel('Preferred Location', _locationController),
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
                          _buildTextFieldWithLabel('Lease Duration', _leaseDurationController),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Lifestyle Preferences'),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Profile',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  Widget _buildTextFieldWithLabel(String label, TextEditingController controller,
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
}
