import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/providers/saved_listings_provider.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/message_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../messages/screens/chat_screen.dart';
import '../../profile/screens/roommate_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/roommate_provider.dart';
import 'review_screen.dart';
import '../../../data/providers/review_provider.dart';
import '../../../core/utils/image_helper.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildPhotoSliver(listing),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(listing),
                      const SizedBox(height: 20),
                      _buildPriceSection(listing),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 20),
                      _buildDetailsGrid(listing),
                      const SizedBox(height: 20),
                      _buildDescription(listing),
                      const SizedBox(height: 20),
                      _buildAmenities(listing),
                      _buildRoommatesSection(listing),
                      const SizedBox(height: 20),
                      _buildReviewsSection(listing),
                      const SizedBox(height: 20),
                      _buildHostSection(listing),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(listing),
        ],
      ),
    );
  }

  Widget _buildPhotoSliver(ListingModel listing) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textDark),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.read<SavedListingsProvider>().toggleSave(widget.listing.id);
          },
          child: Consumer<SavedListingsProvider>(
            builder: (context, savedProvider, _) {
              final isSaved = savedProvider.isSaved(widget.listing.id);
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isSaved ? AppColors.accent : AppColors.textDark,
                  size: 20,
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: const Icon(Icons.share_rounded, size: 20, color: AppColors.textDark),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
              itemCount: listing.photos.length,
              itemBuilder: (_, i) {
                return Image.network(
                  listing.photos[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.cardBg,
                    child: const Icon(Icons.home_rounded, size: 60, color: AppColors.textLight),
                  ),
                );
              },
            ),
            if (listing.photos.length > 1)
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_currentPhotoIndex + 1}/${listing.photos.length}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (listing.isFeatured)
              Positioned(
                top: 80,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Featured', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(ListingModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                listing.typeLabel,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            if (listing.isFurnished)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Furnished', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGreen)),
              ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text('${listing.views}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(listing.title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text(listing.location, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium)),
          ],
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildPriceSection(ListingModel listing) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${listing.monthlyRent.toInt()}/mo',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            if (listing.securityDeposit > 0)
              Text(
                'Deposit: \$${listing.securityDeposit.toInt()}',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
              ),
          ],
        ),
        const Spacer(),
        if (listing.utilitiesIncluded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.accentGreen, size: 16),
                const SizedBox(width: 4),
                Text('Utilities Included', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGreen)),
              ],
            ),
          ),
      ],
    ).animate().fade(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildDetailsGrid(ListingModel listing) {
    final details = [
      {'icon': Icons.people_rounded, 'label': 'Roommates', 'value': '${listing.currentRoommates}/${listing.totalRooms}'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Available', 'value': '${listing.availableFrom.day}/${listing.availableFrom.month}/${listing.availableFrom.year}'},
      {'icon': Icons.wc_rounded, 'label': 'Gender Pref', 'value': listing.genderPreference},
      {'icon': Icons.star_rounded, 'label': 'Rating', 'value': listing.rating.toString()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: details.length,
      itemBuilder: (context, i) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(details[i]['icon'] as IconData, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(details[i]['label'] as String, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textLight)),
                    Text(details[i]['value'] as String, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fade(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildDescription(ListingModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About This Place', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        Text(listing.description, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium, height: 1.6)),
      ],
    ).animate().fade(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildAmenities(ListingModel listing) {
    if (listing.amenities.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listing.amenities.map((a) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Text(a, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fade(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildHostSection(ListingModel listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(listing.userPhoto),
                backgroundColor: AppColors.cardBg,
              ),
              if (listing.userVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, size: 16, color: AppColors.verified),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.userName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text('Listed this property', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              final hostUser = UserModel(
                id: listing.userId,
                name: listing.userName,
                age: 25,
                gender: '',
                occupation: 'Property Manager',
                city: listing.neighborhood.isNotEmpty ? listing.neighborhood : listing.location,
                bio: 'Listed "${listing.title}"',
                photoUrl: listing.userPhoto,
                budgetRange: RangeValues(listing.monthlyRent * 0.8, listing.monthlyRent * 1.2),
                preferredLocation: listing.location,
                moveInDate: listing.availableFrom,
                leaseDuration: '12 months',
                sleepSchedule: '',
                cleanlinessLevel: 3,
                smoking: false,
                drinking: false,
                pets: false,
                workFromHome: false,
                socialActivityLevel: 3,
                guestFrequency: 2,
                isVerified: listing.userVerified,
              );
              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser!;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RoommateProfileScreen(
                    user: hostUser,
                    currentUser: currentUser,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildRoommatesSection(ListingModel listing) {
    if (listing.roommateIds.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Roommates',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listing.roommateIds.length,
            itemBuilder: (context, i) {
              final roommateId = listing.roommateIds[i];
              final roommateUser = UserModel(
                id: roommateId,
                name: 'Roommate',
                age: 25,
                gender: '',
                occupation: '',
                city: '',
                bio: '',
                photoUrl: '',
                budgetRange: const RangeValues(0, 0),
                preferredLocation: '',
                moveInDate: DateTime.now(),
                leaseDuration: '',
                sleepSchedule: '',
                cleanlinessLevel: 1,
                smoking: false,
                drinking: false,
                pets: false,
                workFromHome: false,
                socialActivityLevel: 1,
                guestFrequency: 1,
              );
              final currentUser = context.read<AuthProvider>().currentUser!;
              final score = roommateUser.compatibilityWith(currentUser);
              
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RoommateProfileScreen(
                        user: roommateUser,
                        currentUser: currentUser,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.cardBg,
                        child: const Icon(Icons.person_rounded, size: 22, color: AppColors.textLight),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            roommateUser.name.split(' ').first,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                          ),
                          Text(
                            '${(score * 100).toInt()}% Match',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fade(duration: 400.ms, delay: 280.ms);
  }

  Widget _buildReviewsSection(ListingModel listing) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final listingReviews = reviewProvider.reviewsForListing(listing.id);
        final hostReviews = reviewProvider.reviewsFor(listing.userId);
        final allReviews = [...listingReviews, ...hostReviews];
        // Deduplicate by id
        final seen = <String>{};
        final uniqueReviews = allReviews.where((r) => seen.add(r.id)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                if (uniqueReviews.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${uniqueReviews.isEmpty ? 0.0 : (uniqueReviews.fold<int>(0, (sum, r) => sum + r.rating) / uniqueReviews.length).toStringAsFixed(1)} • ${uniqueReviews.length} reviews',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (uniqueReviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 32, color: AppColors.textLight),
                    const SizedBox(height: 8),
                    Text(
                      'No reviews yet',
                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium),
                    ),
                    Text(
                      'Be the first to review this listing!',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
              )
            else
              ...uniqueReviews.take(5).map((review) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              review.reviewerName.isNotEmpty ? review.reviewerName.substring(0, 1) : '?',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review.reviewerName,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              review.rating,
                              (_) => const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.text,
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ).animate().fade(duration: 400.ms, delay: 290.ms);
      },
    );
  }

  void _handleRequest(ListingModel listing, RoommateProvider roommateProvider) {
    if (roommateProvider.hasRentedRoom) return;

    final notifProvider = context.read<NotificationProvider>();
    final msgProvider = context.read<MessageProvider>();
    roommateProvider.requestListing(listing.id);

    // Start or get conversation with listing owner/host
    msgProvider.startConversation(
      listing.userId,
      listing.userName,
      listing.userPhoto,
      listing.userVerified,
      0.85, // compatibility placeholder
    );
    // Send request message in chat
    final conv = msgProvider.conversations.firstWhere((c) => c.otherUserId == listing.userId);
    msgProvider.sendMessage(conv.id, 'I would like to request to join your listing "${listing.title}".');

    notifProvider.addNotification(
      icon: Icons.send_rounded,
      color: AppColors.primary,
      title: 'Room Request Sent',
      subtitle: 'Sent request to ${listing.isOwnerPost ? "Owner" : "Host"} of "${listing.title}".',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request sent to ${listing.isOwnerPost ? "Owner" : "Host"}!'),
        backgroundColor: AppColors.primary,
      ),
    );

    // Simulate response after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && roommateProvider.hasRequestedListing(listing.id)) {
        roommateProvider.acceptListingRequest(listing.id, listing.roommateIds);
        
        notifProvider.addNotification(
          icon: listing.isOwnerPost ? Icons.home_rounded : Icons.group_add_rounded,
          color: AppColors.accentGreen,
          title: listing.isOwnerPost ? 'Room Secured!' : 'Joined Room Group!',
          subtitle: listing.isOwnerPost 
              ? 'Owner accepted your request for "${listing.title}". Secured!'
              : 'Host accepted your request for "${listing.title}". You joined!',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(listing.isOwnerPost 
                ? 'Owner accepted request! Secured "${listing.title}"'
                : 'Host accepted request! Joined room group'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    });
  }

  Widget _buildBottomBar(ListingModel listing) {
    final roommateProvider = context.watch<RoommateProvider>();
    final isRented = roommateProvider.rentedListingId == listing.id;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${listing.monthlyRent.toInt()}/mo',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Text('per month', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                final msgProvider = context.read<MessageProvider>();
                msgProvider.startConversation(
                  listing.userId,
                  listing.userName,
                  listing.userPhoto,
                  listing.userVerified,
                  0.85,
                );
                final conv = msgProvider.conversations.firstWhere((c) => c.otherUserId == listing.userId);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReviewScreen(listing: listing)));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star_outline_rounded, color: AppColors.accent, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Builder(
                builder: (context) {
                  final isRequested = roommateProvider.hasRequestedListing(listing.id);
                  final hasRented = roommateProvider.hasRentedRoom;
                  final rentedId = roommateProvider.rentedListingId;
                  
                  if (isRented) {
                    return ElevatedButton(
                      onPressed: () {
                        roommateProvider.cancelRental();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Canceled rental agreement for ${listing.title}'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel Rent',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    );
                  } else if (hasRented && rentedId != listing.id) {
                    return ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Renting another property',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    );
                  } else if (isRequested) {
                    return ElevatedButton(
                      onPressed: () {
                        roommateProvider.cancelListingRequest(listing.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Canceled room request'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Request Sent (Cancel)',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () => _handleRequest(listing, roommateProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        listing.isOwnerPost ? 'Request Room' : 'Request to Join',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
