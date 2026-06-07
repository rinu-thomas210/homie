import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../../data/providers/notification_provider.dart';

class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _locationController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isOwnerPost = true;
  String _genderPreference = 'Any';
  
  final List<String> _selectedAmenities = [];
  final List<String> _selectedRoommates = [];

  final List<String> _availableAmenities = [
    'WiFi', 'Washer/Dryer', 'Gym', 'Rooftop', 'Doorman', 'Backyard', 'Near Subway', 'Parking', 'Pet Friendly', 'Elevator'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _locationController.dispose();
    _neighborhoodController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser ?? SampleData.currentUser;
    // Get all users except current user
    final potentialRoommates = SampleData.users.where((u) => u.id != currentUser.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post a Room',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Renter Type'),
                const SizedBox(height: 10),
                _buildRenterTypeSelector(),
                const SizedBox(height: 24),

                _buildSectionHeader('Room Information'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Listing Title',
                    hintText: 'e.g., Cozy Room in Williamsburg Loft',
                    prefixIcon: Icon(Icons.title_rounded, color: AppColors.textLight),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _rentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Rent (\$)',
                          hintText: 'e.g., 1100',
                          prefixIcon: Icon(Icons.payments_rounded, color: AppColors.textLight),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Deposit (\$)',
                          hintText: 'e.g., 1100',
                          prefixIcon: Icon(Icons.security_rounded, color: AppColors.textLight),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Full Address',
                    hintText: 'e.g., Williamsburg, Brooklyn, NY',
                    prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.textLight),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a location' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: const InputDecoration(
                    labelText: 'Neighborhood',
                    hintText: 'e.g., Williamsburg',
                    prefixIcon: Icon(Icons.map_rounded, color: AppColors.textLight),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a neighborhood' : null,
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('Description'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe the property, rooms, guidelines, and what you are looking for...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('Gender Preference'),
                const SizedBox(height: 10),
                _buildGenderPreferenceSelector(),
                const SizedBox(height: 24),

                _buildSectionHeader('Amenities'),
                const SizedBox(height: 10),
                _buildAmenitiesChips(),
                const SizedBox(height: 24),

                if (!_isOwnerPost) ...[
                  _buildSectionHeader('Select Current Roommates in this Room'),
                  const SizedBox(height: 10),
                  _buildRoommatesSelector(potentialRoommates),
                  const SizedBox(height: 24),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitForm(currentUser),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Post Listing',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildRenterTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isOwnerPost = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isOwnerPost ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isOwnerPost ? AppColors.primary : AppColors.border),
                boxShadow: _isOwnerPost
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(Icons.real_estate_agent_rounded, color: _isOwnerPost ? Colors.white : AppColors.textMedium),
                  const SizedBox(height: 6),
                  Text(
                    'I am the Owner',
                    style: GoogleFonts.outfit(
                      color: _isOwnerPost ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isOwnerPost = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !_isOwnerPost ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: !_isOwnerPost ? AppColors.primary : AppColors.border),
                boxShadow: !_isOwnerPost
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(Icons.people_rounded, color: !_isOwnerPost ? Colors.white : AppColors.textMedium),
                  const SizedBox(height: 6),
                  Text(
                    'I am a Roommate',
                    style: GoogleFonts.outfit(
                      color: !_isOwnerPost ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPreferenceSelector() {
    final preferences = ['Any', 'Male preferred', 'Female preferred'];
    return Wrap(
      spacing: 8,
      children: preferences.map((p) {
        final isSelected = _genderPreference == p;
        return ChoiceChip(
          label: Text(p),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _genderPreference = p);
            }
          },
          labelStyle: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          labelStyle: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoommatesSelector(List<UserModel> potentialRoommates) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: potentialRoommates.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final roommate = potentialRoommates[index];
          final isSelected = _selectedRoommates.contains(roommate.id);
          return CheckboxListTile(
            title: Text(roommate.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(roommate.occupation, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium)),
            value: isSelected,
            activeColor: AppColors.primary,
            secondary: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(roommate.photoUrl),
            ),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedRoommates.add(roommate.id);
                } else {
                  _selectedRoommates.remove(roommate.id);
                }
              });
            },
          );
        },
      ),
    );
  }

  void _submitForm(UserModel currentUser) {
    if (_formKey.currentState?.validate() ?? false) {
      final rent = double.parse(_rentController.text);
      final deposit = double.parse(_depositController.text);
      
      final newListing = ListingModel(
        id: 'user_listing_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser.id,
        userName: currentUser.name,
        userPhoto: currentUser.photoUrl,
        userVerified: currentUser.isVerified,
        type: ListingType.roomAvailable,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        monthlyRent: rent,
        securityDeposit: deposit,
        location: _locationController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        photos: [
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800' // Placeholder elegant bedroom image
        ],
        isFurnished: _selectedAmenities.contains('WiFi'),
        utilitiesIncluded: true,
        availableFrom: DateTime.now().add(const Duration(days: 7)),
        genderPreference: _genderPreference,
        currentRoommates: _isOwnerPost ? 0 : _selectedRoommates.length,
        totalRooms: _isOwnerPost ? 1 : _selectedRoommates.length + 1,
        rating: 4.8,
        views: 1,
        isFeatured: false,
        amenities: _selectedAmenities,
        isOwnerPost: _isOwnerPost,
        roommateIds: _isOwnerPost ? [] : List.from(_selectedRoommates),
      );

      // Save Listing
      context.read<ListingsProvider>().addListing(newListing);

      // Dynamic Notification
      context.read<NotificationProvider>().addNotification(
        icon: Icons.add_business_rounded,
        color: AppColors.primary,
        title: 'Listing Posted Successfully!',
        subtitle: 'Your listing "${newListing.title}" is now live for matching!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Listing "${newListing.title}" posted successfully! 🎉'),
          backgroundColor: AppColors.accentGreen,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
