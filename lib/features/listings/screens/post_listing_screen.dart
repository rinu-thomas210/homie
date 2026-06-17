import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/roommate_provider.dart';

class PostListingScreen extends StatefulWidget {
  final ListingModel? existingListing;

  const PostListingScreen({super.key, this.existingListing});

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
  int _totalRooms = 1;
  int _currentRoommateCount = 0;

  final List<String> _selectedAmenities = [];
  final List<String> _selectedRoommates = [];
  final List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableAmenities = [
    'WiFi', 'Washer/Dryer', 'Gym', 'Rooftop', 'Doorman', 'Backyard', 'Near Subway', 'Parking', 'Pet Friendly', 'Elevator'
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingListing;
    if (existing != null) {
      _titleController.text = existing.title;
      _rentController.text = existing.monthlyRent.toInt().toString();
      _depositController.text = existing.securityDeposit.toInt().toString();
      _locationController.text = existing.location;
      _neighborhoodController.text = existing.neighborhood;
      _descriptionController.text = existing.description;
      _isOwnerPost = existing.isOwnerPost;
      _genderPreference = existing.genderPreference;
      _totalRooms = existing.totalRooms;
      _currentRoommateCount = existing.currentRoommates;
      _selectedAmenities.addAll(existing.amenities);
      _selectedRoommates.addAll(existing.roommateIds);
    }
  }

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

  Future<void> _pickPhotos() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      // Copy images to app directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/listing_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      for (final image in images) {
        final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}_${_selectedPhotos.length}.jpg';
        final savedFile = await File(image.path).copy('${photosDir.path}/$fileName');
        setState(() {
          _selectedPhotos.add(savedFile);
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/listing_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(image.path).copy('${photosDir.path}/$fileName');
      setState(() {
        _selectedPhotos.add(savedFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser!;

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
          widget.existingListing != null ? 'Edit Room' : 'Post a Room',
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

                // ── Photos Section ─────────────────────────────────────
                _buildSectionHeader('Room Photos'),
                const SizedBox(height: 10),
                _buildPhotoSection(),
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

                // ── Room Count Section ─────────────────────────────────
                _buildSectionHeader('Room Details'),
                const SizedBox(height: 12),
                _buildRoomCountSection(),
                const SizedBox(height: 24),

                _buildSectionHeader('Tag Roommates'),
                const SizedBox(height: 10),
                _buildRoommatesSelector(),
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
                      widget.existingListing != null ? 'Update Listing' : 'Post Listing',
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

  // ── Photo Section ──────────────────────────────────────────────────────

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedPhotos.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedPhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhotos.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: Text(
                  'Gallery',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  'Camera',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        if (_selectedPhotos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add at least one photo of the room',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
            ),
          ),
      ],
    );
  }

  // ── Room Count Section ─────────────────────────────────────────────────

  Widget _buildRoomCountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildCounterRow(
            label: 'Total Rooms',
            value: _totalRooms,
            onDecrement: () {
              if (_totalRooms > 1) {
                setState(() {
                  _totalRooms--;
                  if (_currentRoommateCount >= _totalRooms) {
                    _currentRoommateCount = _totalRooms - 1;
                  }
                });
              }
            },
            onIncrement: () {
              setState(() => _totalRooms++);
            },
          ),
          const Divider(color: AppColors.divider, height: 24),
          _buildCounterRow(
            label: 'Current Roommates',
            value: _currentRoommateCount,
            onDecrement: () {
              if (_currentRoommateCount > 0) {
                setState(() => _currentRoommateCount--);
              }
            },
            onIncrement: () {
              if (_currentRoommateCount < _totalRooms - 1) {
                setState(() => _currentRoommateCount++);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoommatesSelector() {
    // Dummy users to select from since there's no backend
    final dummyUsers = [
      {'id': 'user1', 'name': 'Sarah Jenkins', 'photo': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'},
      {'id': 'user2', 'name': 'Mike Chen', 'photo': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100'},
      {'id': 'user3', 'name': 'Alex Rivera', 'photo': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'},
      {'id': 'user4', 'name': 'Emma Wilson', 'photo': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedRoommates.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedRoommates.map((id) {
              final user = dummyUsers.firstWhere((u) => u['id'] == id, orElse: () => {'id': id, 'name': 'Roommate', 'photo': ''});
              return Container(
                padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6, left: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: user['photo'] != '' ? NetworkImage(user['photo']!) : null,
                      backgroundColor: AppColors.cardBg,
                      child: user['photo'] == '' ? const Icon(Icons.person, size: 14) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user['name']!,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textDark, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedRoommates.remove(id)),
                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textLight),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Add Roommates', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          ...dummyUsers.map((user) {
                            final isSelected = _selectedRoommates.contains(user['id']);
                            return ListTile(
                              leading: CircleAvatar(backgroundImage: NetworkImage(user['photo']!)),
                              title: Text(user['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                  : const Icon(Icons.circle_outlined, color: AppColors.border),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedRoommates.remove(user['id']);
                                  } else {
                                    _selectedRoommates.add(user['id']!);
                                  }
                                });
                                setModalState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Done', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            );
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text('Select Accounts', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              Text(
                label == 'Total Rooms' ? 'Number of rooms available' : 'People already living here',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_rounded, size: 18),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                color: AppColors.textMedium,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_rounded, size: 18),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
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

  void _submitForm(UserModel currentUser) {
    if (_formKey.currentState?.validate() ?? false) {
      final rent = double.parse(_rentController.text);
      final deposit = double.parse(_depositController.text);

      // Build photo paths list
      final List<String> photoPaths = _selectedPhotos.isNotEmpty
          ? _selectedPhotos.map((f) => f.path).toList()
          : (widget.existingListing?.photos ?? []);

      final isEditing = widget.existingListing != null;

      if (isEditing) {
        // Update existing listing
        final updated = widget.existingListing!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          monthlyRent: rent,
          securityDeposit: deposit,
          location: _locationController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          photos: photoPaths,
          isFurnished: _selectedAmenities.contains('WiFi'),
          genderPreference: _genderPreference,
          currentRoommates: _currentRoommateCount,
          totalRooms: _totalRooms,
          amenities: List.from(_selectedAmenities),
          isOwnerPost: _isOwnerPost,
          roommateIds: _isOwnerPost ? [] : List.from(_selectedRoommates),
        );

        context.read<ListingsProvider>().updateListing(updated);

        context.read<NotificationProvider>().addNotification(
          icon: Icons.edit_rounded,
          color: AppColors.primary,
          title: 'Listing Updated!',
          subtitle: 'Your listing "${updated.title}" has been updated.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing "${updated.title}" updated!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      } else {
        // Create new listing
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
          photos: photoPaths,
          isFurnished: _selectedAmenities.contains('WiFi'),
          utilitiesIncluded: true,
          availableFrom: DateTime.now().add(const Duration(days: 7)),
          genderPreference: _genderPreference,
          currentRoommates: _currentRoommateCount,
          totalRooms: _totalRooms,
          rating: 0.0,
          views: 1,
          isFeatured: false,
          amenities: _selectedAmenities,
          isOwnerPost: _isOwnerPost,
          roommateIds: _isOwnerPost ? [] : List.from(_selectedRoommates),
        );

        context.read<ListingsProvider>().addListing(newListing);

        context.read<NotificationProvider>().addNotification(
          icon: Icons.add_business_rounded,
          color: AppColors.primary,
          title: 'Listing Posted Successfully!',
          subtitle: 'Your listing "${newListing.title}" is now live for matching!',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing "${newListing.title}" posted successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }
}
