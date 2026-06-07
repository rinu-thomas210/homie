import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/saved_listings_provider.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/message_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../messages/screens/chat_screen.dart';
import '../../listings/screens/listing_detail_screen.dart';
import '../../profile/screens/roommate_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/roommate_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserModel> _matches = [];
  late UserModel _currentUser;
  late UserModel _topMatch;

  void _initializeMatches(UserModel currentUser) {
    _matches = SampleData.users.map((u) {
      return u;
    }).toList();
    _matches.sort((a, b) => b.compatibilityWith(currentUser).compareTo(a.compatibilityWith(currentUser)));
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AuthProvider>();
    final roommateProvider = context.watch<RoommateProvider>();
    _currentUser = authProvider.currentUser ?? SampleData.currentUser;
    
    if (_matches.isEmpty) {
      _initializeMatches(_currentUser);
    }
    
    if (_matches.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    _topMatch = _matches.first;
    final topScore = _topMatch.compatibilityWith(_currentUser);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(_currentUser),
              const SizedBox(height: 20),
              _buildRentedListingCard(roommateProvider),
              _buildRoommateRequests(roommateProvider),
              _buildDailyMatch(topScore),
              const SizedBox(height: 28),
              _buildCompatibleSection(),
              const SizedBox(height: 28),
              _buildNearbyListings(),
              const SizedBox(height: 28),
              _buildExpenseSummary(expenses),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium),
              ),
              Text(
                currentUser.name.split(' ').first,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 22),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundImage: getUserImageProvider(currentUser.photoUrl),
          ),
        ],
      ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildDailyMatch(double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Daily Match',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RoommateProfileScreen(user: _topMatch, currentUser: _currentUser)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image with match badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          _topMatch.photoUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            color: AppColors.cardBg,
                            child: const Icon(Icons.person_rounded, size: 80, color: AppColors.textLight),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
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
                                '${(score * 100).toInt()}% Match',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_topMatch.isVerified)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.verified_rounded, color: AppColors.verified, size: 18),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${_topMatch.name}, ${_topMatch.age}',
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                            if (_topMatch.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, color: AppColors.verified, size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.work_outline_rounded, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(_topMatch.occupation, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
                            const SizedBox(width: 12),
                            const Icon(Icons.nightlight_round_outlined, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(_topMatch.sleepScheduleLabel, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
                            if (_topMatch.workFromHome) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.laptop_mac_rounded, size: 14, color: AppColors.textLight),
                              const SizedBox(width: 4),
                              Text('Remote', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${_topMatch.bio}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final msgProvider = context.read<MessageProvider>();
                                  msgProvider.startConversation(
                                    _topMatch.id,
                                    _topMatch.name,
                                    _topMatch.photoUrl,
                                    _topMatch.isVerified,
                                    score,
                                  );
                                  final conv = msgProvider.conversations.firstWhere((c) => c.otherUserId == _topMatch.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
                                  );
                                },
                                icon: Icon(
                                  context.read<RoommateProvider>().isRoommate(_topMatch.id)
                                      ? Icons.chat_bubble_rounded
                                      : Icons.waving_hand_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  context.read<RoommateProvider>().isRoommate(_topMatch.id)
                                      ? 'Chat with Roommate'
                                      : 'Say Hello',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                context.read<SavedListingsProvider>().toggleSave('match_${_topMatch.id}');
                              },
                              child: Consumer<SavedListingsProvider>(
                                builder: (context, savedProvider, _) {
                                  final isSaved = savedProvider.isSaved('match_${_topMatch.id}');
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isSaved ? AppColors.accent : AppColors.accent,
                                      size: 22,
                                    ),
                                  );
                                },
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
          ),
        ],
      ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildCompatibleSection() {
    final compatibleUsers = _matches.skip(1).take(4).toList();
    
    if (compatibleUsers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compatible For You',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: compatibleUsers.length,
          itemBuilder: (context, i) {
            final user = compatibleUsers[i];
            final score = user.compatibilityWith(_currentUser);
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RoommateProfileScreen(user: user, currentUser: _currentUser)),
              ),
              child: _CompatibleCard(user: user, score: score),
            ).animate().fade(duration: 400.ms, delay: (100 * i).ms).scale(begin: const Offset(0.95, 0.95));
          },
        ),
      ],
    );
  }

  Widget _buildNearbyListings() {
    final listings = context.watch<ListingsProvider>().listings.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Listings',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Explore Map',
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.only(right: i < listings.length - 1 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listings[i])),
                  ),
                  child: _ListingCard(listing: listings[i]),
                )
                    .animate()
                    .fade(duration: 400.ms, delay: (100 * i).ms)
                    .slideX(begin: 0.1),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseSummary(ExpenseProvider expenses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.expenseGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shared Expenses',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              expenses.netBalance >= 0
                  ? 'You\'re owed \$${expenses.netBalance.toStringAsFixed(0)}'
                  : 'You owe \$${(-expenses.netBalance).toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              expenses.netBalance >= 0
                  ? 'Your roommates owe you money'
                  : 'You have outstanding balances',
              style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Settle Up',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'Add Expense',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1)
    );
  }

  Widget _buildRoommateRequests(RoommateProvider roommateProvider) {
    final pendingReceived = roommateProvider.pendingReceivedRequests;
    if (pendingReceived.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Roommate Requests',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Text(
                  '${pendingReceived.length}',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pendingReceived.map((userId) {
            final user = SampleData.users.firstWhere((u) => u.id == userId, orElse: () => SampleData.users.first);
            final score = user.compatibilityWith(_currentUser);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RoommateProfileScreen(user: user, currentUser: _currentUser)),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name}, ${user.age}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                        ),
                        Text(
                          '${(score * 100).toInt()}% Match • ${user.occupation}',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          roommateProvider.rejectRoommateRequest(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Roommate request declined')),
                          );
                        },
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          roommateProvider.acceptRoommateRequest(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You and ${user.name.split(' ').first} are now roommates! 🏠'),
                              backgroundColor: AppColors.accentGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_rounded, color: AppColors.accentGreen, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.accentGreen.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 18),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildRentedListingCard(RoommateProvider roommateProvider) {
    if (!roommateProvider.hasRentedRoom) return const SizedBox.shrink();

    final listings = context.watch<ListingsProvider>().listings;
    final listing = listings.firstWhere(
      (l) => l.id == roommateProvider.rentedListingId,
      orElse: () => listings.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rented Property',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, AppColors.background],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      listing.photos.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          listing.location,
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Rented ✓',
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accentGreen),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${listing.monthlyRent.toInt()}/mo',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }
}

class _CompatibleCard extends StatelessWidget {
  final UserModel user;
  final double score;

  const _CompatibleCard({required this.user, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    user.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardBg,
                      child: const Icon(Icons.person_rounded, size: 40, color: AppColors.textLight),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.matchGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(score * 100).toInt()}%',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name.split(' ').first}, ${user.age}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  user.occupation,
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMedium),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  listing.photos.isNotEmpty ? listing.photos.first : 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    width: double.infinity,
                    color: AppColors.cardBg,
                    child: const Icon(Icons.home_rounded, size: 40, color: AppColors.textLight),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${listing.monthlyRent.toInt()}/mo',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        listing.location,
                        style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMedium),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: listing.currentRoommates == 0 ? 0 : 20.0 + (listing.currentRoommates - 1) * 16.0,
                      height: 20,
                      child: Stack(
                        children: List.generate(
                          listing.currentRoommates,
                          (i) => Positioned(
                            left: i * 16.0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.person_rounded, size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (listing.currentRoommates > 0) const SizedBox(width: 6),
                    Text(
                      '${listing.currentRoommates} roommates here',
                      style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
