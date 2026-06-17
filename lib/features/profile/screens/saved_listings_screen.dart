import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_helper.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/saved_listings_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../listings/screens/listing_detail_screen.dart';
import 'roommate_profile_screen.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Saved Profiles & Rooms',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMedium,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Saved Profiles'),
            Tab(text: 'Saved Rooms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SavedProfilesTab(),
          _SavedRoomsTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Saved Profiles Tab
// ──────────────────────────────────────────────────────────────────────────────

class _SavedProfilesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedListingsProvider>();
    final likedIds = provider.likedUserIds;
    final liked = <UserModel>[];

    if (liked.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved profiles yet',
        subtitle: 'Tap the bookmark icon on a roommate profile to save them here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: liked.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _RoommateCard(user: liked[index])
            .animate(delay: (index * 60).ms)
            .fade(duration: 350.ms)
            .slideY(begin: 0.05, end: 0);
      },
    );
  }
}

class _RoommateCard extends StatelessWidget {
  final UserModel user;
  const _RoommateCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SavedListingsProvider>();
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser!;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RoommateProfileScreen(user: user, currentUser: currentUser)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: buildUserImage(user.photoUrl, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: AppColors.verified, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.occupation} • ${user.city}',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.accentOrange),
                      const SizedBox(width: 3),
                      Text(
                        '${user.rating} (${user.reviewCount} reviews)',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.budgetLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Unlike button
            GestureDetector(
              onTap: () => provider.toggleLike(user.id),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Saved Rooms Tab
// ──────────────────────────────────────────────────────────────────────────────

class _SavedRoomsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedListingsProvider>();
    final savedIds = provider.savedListingIds;
    final listings = context.watch<ListingsProvider>().listings;
    final saved = listings.where((l) => savedIds.contains(l.id)).toList();

    if (saved.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved rooms yet',
        subtitle: 'Tap the bookmark icon on any property to save it here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: saved.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ListingCard(listing: saved[index])
            .animate(delay: (index * 60).ms)
            .fade(duration: 350.ms)
            .slideY(begin: 0.05, end: 0);
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SavedListingsProvider>();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  buildUserImage(
                    listing.photos.isNotEmpty ? listing.photos.first : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                  // Type badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        listing.typeLabel,
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => provider.toggleSave(listing.id),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          provider.isSaved(listing.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: AppColors.primary, 
                          size: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${listing.monthlyRent.toInt()}/mo',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (listing.isFurnished)
                        _Tag(label: 'Furnished', color: AppColors.primary),
                      if (listing.utilitiesIncluded)
                        _Tag(label: 'Utilities Included', color: AppColors.accentGreen),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.accentOrange),
                      const SizedBox(width: 3),
                      Text(
                        listing.rating.toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ──────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium, height: 1.5),
            ),
          ),
        ],
      ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}
