import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/utils/image_helper.dart';
import 'edit_profile_screen.dart';
import 'matches_list_screen.dart';
import 'saved_listings_screen.dart';
import '../../listings/screens/post_listing_screen.dart';
import 'my_reviews_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser ?? SampleData.currentUser;
    final matchesCount = SampleData.users.where((u) => u.id != user.id && u.compatibilityWith(user) >= 0.75).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, user),
              _buildStats(context, user, matchesCount),
              const SizedBox(height: 24),
              _buildAboutSection(user),
              const SizedBox(height: 20),
              _buildLifestyleSection(user),
              const SizedBox(height: 20),
              _buildHousingPrefs(user),
              const SizedBox(height: 20),
              _buildMenuSection(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Profile',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.settings_outlined, color: AppColors.textDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthProvider>().signOut();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.logout_rounded, color: AppColors.accent, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fade(duration: 400.ms),

          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => _pickImage(context, user),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: buildUserImage(
                      user.photoUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      iconSize: 50,
                      fallbackBgColor: Colors.transparent,
                      fallbackIconColor: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ),
                if (user.isVerified)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.verified.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.verified_rounded, size: 16, color: AppColors.verified),
                    ),
                  ),
              ],
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fade(duration: 300.ms),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, color: AppColors.verified, size: 20),
              ],
            ],
          ).animate().fade(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 4),

          Text(
            '${user.occupation} • ${user.city}',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium),
          ).animate().fade(duration: 400.ms, delay: 150.ms),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${user.rating} (${user.reviewCount} reviews)',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
              ),
            ],
          ).animate().fade(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
            label: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ).animate().fade(duration: 400.ms, delay: 250.ms),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, UserModel user) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final auth = context.read<AuthProvider>();
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          age: user.age,
          gender: user.gender,
          occupation: user.occupation,
          city: user.city,
          bio: user.bio,
          photoUrl: pickedFile.path,
          isVerified: user.isVerified,
          rating: user.rating,
          reviewCount: user.reviewCount,
          budgetRange: user.budgetRange,
          preferredLocation: user.preferredLocation,
          moveInDate: user.moveInDate,
          leaseDuration: user.leaseDuration,
          sleepSchedule: user.sleepSchedule,
          cleanlinessLevel: user.cleanlinessLevel,
          smoking: user.smoking,
          drinking: user.drinking,
          pets: user.pets,
          workFromHome: user.workFromHome,
          socialActivityLevel: user.socialActivityLevel,
          guestFrequency: user.guestFrequency,
          matches: user.matches,
          interests: user.interests,
        );
        auth.updateUserProfile(updatedUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  Widget _buildStats(BuildContext context, UserModel user, int matchesCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _StatItem(
              value: '$matchesCount',
              label: 'Matches',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MatchesListScreen(currentUser: user),
                  ),
                );
              },
            ),
            _Divider(),
            _StatItem(value: '${user.reviewCount}', label: 'Reviews'),
            _Divider(),
            _StatItem(value: user.isVerified ? '✓' : '✗', label: 'Verified'),
          ],
        ),
      ).animate().fade(duration: 400.ms, delay: 300.ms),
    );
  }

  Widget _buildAboutSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Me', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(user.bio, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium, height: 1.6)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.interests.map((i) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(i, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms, delay: 350.ms),
    );
  }

  Widget _buildLifestyleSection(UserModel user) {
    final items = [
      {'icon': Icons.nightlight_round, 'label': 'Sleep', 'value': user.sleepScheduleLabel},
      {'icon': Icons.cleaning_services_rounded, 'label': 'Cleanliness', 'value': '${user.cleanlinessLevel}/5'},
      {'icon': user.smoking ? Icons.smoking_rooms_rounded : Icons.smoke_free_rounded, 'label': 'Smoking', 'value': user.smoking ? 'Yes' : 'No'},
      {'icon': user.pets ? Icons.pets_rounded : Icons.do_not_disturb_alt_rounded, 'label': 'Pets', 'value': user.pets ? 'Yes' : 'No'},
      {'icon': user.workFromHome ? Icons.laptop_mac_rounded : Icons.business_rounded, 'label': 'Work', 'value': user.workFromHome ? 'Remote' : 'Onsite'},
      {'icon': Icons.people_rounded, 'label': 'Social', 'value': '${user.socialActivityLevel}/5'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lifestyle', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i]['icon'] as IconData, size: 20, color: AppColors.primary),
                      const SizedBox(height: 4),
                      Text(items[i]['label'] as String, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textLight)),
                      Text(items[i]['value'] as String, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms, delay: 400.ms),
    );
  }

  Widget _buildHousingPrefs(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Housing Preferences', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _PrefRow2(icon: Icons.attach_money_rounded, label: 'Budget', value: user.budgetLabel),
            _PrefRow2(icon: Icons.location_on_rounded, label: 'Location', value: user.preferredLocation),
            _PrefRow2(icon: Icons.calendar_today_rounded, label: 'Move-in', value: '${user.moveInDate.day}/${user.moveInDate.month}/${user.moveInDate.year}'),
            _PrefRow2(icon: Icons.access_time_rounded, label: 'Lease', value: user.leaseDuration),
          ],
        ),
      ).animate().fade(duration: 400.ms, delay: 450.ms),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {'icon': Icons.add_business_outlined, 'label': 'Post a Room', 'color': AppColors.primary},
      {'icon': Icons.bookmark_outlined, 'label': 'Saved Profiles & Listings', 'color': AppColors.primary},
      {'icon': Icons.star_outline_rounded, 'label': 'My Reviews', 'color': AppColors.accentOrange},
      {'icon': Icons.notifications_outlined, 'label': 'Notifications', 'color': AppColors.accentGreen},
      {'icon': Icons.shield_outlined, 'label': 'Privacy & Safety', 'color': AppColors.verified},
      {'icon': Icons.help_outline_rounded, 'label': 'Help & Support', 'color': AppColors.textMedium},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: menuItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
                  ),
                  title: Text(item['label'] as String, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                  onTap: () {
                    if (item['label'] == 'Post a Room') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PostListingScreen(),
                        ),
                      );
                    } else if (item['label'] == 'Saved Profiles & Listings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedListingsScreen(),
                        ),
                      );
                    } else if (item['label'] == 'My Reviews') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyReviewsScreen(),
                        ),
                      );
                    } else if (item['label'] == 'Notifications') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['label']} is coming soon!')),
                      );
                    }
                  },
                ),
                if (i < menuItems.length - 1)
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
              ],
            );
          }).toList(),
        ),
      ).animate().fade(duration: 400.ms, delay: 500.ms),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}

class _PrefRow2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PrefRow2({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
