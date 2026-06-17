import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/message_provider.dart';
import '../../../data/providers/saved_listings_provider.dart';
import '../../../data/models/review_model.dart';
import '../../../data/providers/review_provider.dart';
import '../../messages/screens/chat_screen.dart';
import '../../../data/providers/roommate_provider.dart';

class RoommateProfileScreen extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;

  const RoommateProfileScreen({super.key, required this.user, required this.currentUser});

  @override
  State<RoommateProfileScreen> createState() => _RoommateProfileScreenState();
}

class _RoommateProfileScreenState extends State<RoommateProfileScreen> {
  late double _overallScore;
  late double _budgetScore;
  late double _cleanScore;
  late double _sleepScore;
  late double _smokingScore;
  late double _workScore;
  late double _socialScore;
  
  @override
  void initState() {
    super.initState();
    final u = widget.user;
    final me = widget.currentUser;
    _overallScore = u.compatibilityWith(me);

    // Breakdown
    final budgetOverlap = _rangeOverlap(u.budgetRange, me.budgetRange);
    _budgetScore = budgetOverlap;
    final cleanDiff = (u.cleanlinessLevel - me.cleanlinessLevel).abs().toDouble();
    _cleanScore = 1 - (cleanDiff / 4);
    _sleepScore = u.sleepSchedule == me.sleepSchedule ? 1.0 : 0.5;
    _smokingScore = u.smoking == me.smoking ? 1.0 : 0.0;
    _workScore = u.workFromHome == me.workFromHome ? 1.0 : 0.6;
    final socialDiff = (u.socialActivityLevel - me.socialActivityLevel).abs().toDouble();
    _socialScore = 1 - (socialDiff / 4);
  }

  double _rangeOverlap(RangeValues a, RangeValues b) {
    double overlapStart = [a.start, b.start].reduce((x, y) => x > y ? x : y);
    double overlapEnd = [a.end, b.end].reduce((x, y) => x < y ? x : y);
    if (overlapEnd < overlapStart) return 0.0;
    double overlap = overlapEnd - overlapStart;
    double minRange = [(a.end - a.start), (b.end - b.start)].reduce((x, y) => x < y ? x : y);
    if (minRange <= 0) return 1.0;
    return (overlap / minRange).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(),
                      const SizedBox(height: 20),
                      _buildCompatibilityCard(),
                      const SizedBox(height: 20),
                      _buildLifestyleSection(),
                      const SizedBox(height: 20),
                      _buildHousingPrefs(),
                      const SizedBox(height: 20),
                      _buildInterests(),
                      const SizedBox(height: 20),
                      _buildReviewsPreview(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textDark),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.read<SavedListingsProvider>().toggleLike(widget.user.id);
          },
          child: Consumer<SavedListingsProvider>(
            builder: (context, savedProvider, _) {
              final isLiked = savedProvider.isLiked(widget.user.id);
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLiked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isLiked ? AppColors.primary : AppColors.textDark,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            buildUserImage(
              widget.user.photoUrl,
              fit: BoxFit.cover,
              iconSize: 80,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.white.withOpacity(0.95)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.matchGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${(_overallScore * 100).toInt()}% Match',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${widget.user.name}, ${widget.user.age}',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  if (widget.user.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: AppColors.verified, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.work_outline_rounded, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(widget.user.occupation, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(widget.user.city, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.user.rating} (${widget.user.reviewCount} reviews)',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 6,
          percent: _overallScore,
          center: Text(
            '${(_overallScore * 100).toInt()}%',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          progressColor: AppColors.primary,
          backgroundColor: AppColors.border,
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildCompatibilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compatibility Breakdown', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _CompatibilityRow(label: 'Budget', score: _budgetScore, weight: '25%'),
          _CompatibilityRow(label: 'Cleanliness', score: _cleanScore, weight: '20%'),
          _CompatibilityRow(label: 'Sleep Schedule', score: _sleepScore, weight: '15%'),
          _CompatibilityRow(label: 'Smoking', score: _smokingScore, weight: '15%'),
          _CompatibilityRow(label: 'Work Style', score: _workScore, weight: '10%'),
          _CompatibilityRow(label: 'Social Life', score: _socialScore, weight: '15%'),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildLifestyleSection() {
    final prefs = [
      {'icon': Icons.nightlight_round, 'label': widget.user.sleepScheduleLabel},
      {'icon': widget.user.smoking ? Icons.smoking_rooms_rounded : Icons.smoke_free_rounded, 'label': widget.user.smoking ? 'Smoker' : 'Non-Smoker'},
      {'icon': widget.user.pets ? Icons.pets_rounded : Icons.do_not_disturb_alt_rounded, 'label': widget.user.pets ? 'Has Pets' : 'No Pets'},
      {'icon': widget.user.workFromHome ? Icons.laptop_mac_rounded : Icons.business_rounded, 'label': widget.user.workFromHome ? 'Work from Home' : 'Works Onsite'},
      {'icon': Icons.cleaning_services_rounded, 'label': 'Clean: ${widget.user.cleanlinessLevel}/5'},
      {'icon': Icons.people_rounded, 'label': 'Social: ${widget.user.socialActivityLevel}/5'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifestyle', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: prefs.map((p) {
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
                  Icon(p['icon'] as IconData, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(p['label'] as String, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fade(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildHousingPrefs() {
    return Container(
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
          _PrefRow(label: 'Budget', value: widget.user.budgetLabel),
          _PrefRow(label: 'Location', value: widget.user.preferredLocation),
          _PrefRow(label: 'Move-in', value: '${widget.user.moveInDate.day}/${widget.user.moveInDate.month}/${widget.user.moveInDate.year}'),
          _PrefRow(label: 'Lease', value: widget.user.leaseDuration),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInterests() {
    if (widget.user.interests.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.user.interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                interest,
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fade(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildReviewsPreview() {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final globalReviews = reviewProvider.reviewsFor(widget.user.id);
        final displayReviews = globalReviews
            .map((r) => {'name': r.reviewerName, 'rating': r.rating, 'text': r.text})
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reviews', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.user.rating} • ${displayReviews.length} reviews',
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...displayReviews.map((r) {
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
                            (r['name'] as String).substring(0, 1),
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(r['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            r['rating'] as int,
                            (_) => const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r['text'] as String, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showWriteReviewModal(),
                icon: const Icon(Icons.rate_review_rounded, size: 18),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                label: Text(
                  'Write a Review',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ).animate().fade(duration: 400.ms, delay: 300.ms);
      },
    );
  }

  Widget _buildBottomBar() {
    final roommateProvider = context.watch<RoommateProvider>();
    final isRoommate = roommateProvider.isRoommate(widget.user.id);
    final hasSent = roommateProvider.hasSentRequest(widget.user.id);
    final hasReceived = roommateProvider.hasReceivedRequest(widget.user.id);

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
            GestureDetector(
              onTap: () {
                final msgProvider = context.read<MessageProvider>();
                msgProvider.startConversation(
                  widget.user.id,
                  widget.user.name,
                  widget.user.photoUrl,
                  widget.user.isVerified,
                  _overallScore,
                );
                final conv = msgProvider.conversations.firstWhere((c) => c.otherUserId == widget.user.id);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
                );
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
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isRoommate) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove Roommate'),
                            content: Text('Are you sure you want to remove ${widget.user.name.split(' ').first} as your roommate?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  roommateProvider.removeRoommate(widget.user.id);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Removed ${widget.user.name.split(' ').first} from roommates')),
                                  );
                                },
                                child: const Text('Remove', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
                      label: Text('Roommates ✓', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    );
                  } else if (hasReceived) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              roommateProvider.rejectRoommateRequest(widget.user.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Roommate request declined')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Decline', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              roommateProvider.acceptRoommateRequest(widget.user.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You and ${widget.user.name.split(' ').first} are now roommates!'),
                                  backgroundColor: AppColors.accentGreen,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text('Accept', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
                          ),
                        ),
                      ],
                    );
                  } else if (hasSent) {
                    return ElevatedButton(
                      onPressed: () {
                        roommateProvider.cancelRoommateRequest(widget.user.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Roommate request canceled')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Cancel Request', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        roommateProvider.sendRoommateRequest(widget.user.id);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Roommate request sent to ${widget.user.name.split(' ').first}!')),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          if (roommateProvider.hasSentRequest(widget.user.id)) {
                            roommateProvider.acceptRoommateRequest(widget.user.id);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${widget.user.name.split(' ').first} accepted your roommate request!'),
                                backgroundColor: AppColors.accentGreen,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                      label: Text('Be Roommate', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
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

  void _showWriteReviewModal() {
    final textController = TextEditingController();
    int selectedRating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Write a Review for ${widget.user.name.split(' ').first}',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Rating', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.accentOrange,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Share your experience living with ${widget.user.name.split(' ').first}...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          final reviewProvider = context.read<ReviewProvider>();
                          reviewProvider.addReview(ReviewModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            reviewerName: widget.currentUser.name,
                            reviewerPhotoUrl: widget.currentUser.photoUrl,
                            targetUserId: widget.user.id,
                            targetUserName: widget.user.name,
                            rating: selectedRating,
                            text: textController.text.trim(),
                            createdAt: DateTime.now(),
                          ));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review posted successfully!'),
                              backgroundColor: AppColors.accentGreen,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please write your review first'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Submit Review', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CompatibilityRow extends StatelessWidget {
  final String label;
  final double score;
  final String weight;

  const _CompatibilityRow({required this.label, required this.score, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
              ),
              Text(
                '${(score * 100).toInt()}%',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(width: 8),
              Text(weight, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                score >= 0.8 ? AppColors.accentGreen : score >= 0.5 ? AppColors.accentOrange : AppColors.accent,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final String label;
  final String value;

  const _PrefRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
