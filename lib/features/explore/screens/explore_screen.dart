import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/providers/listings_provider.dart';
import '../../listings/screens/listing_detail_screen.dart';
import '../../profile/screens/roommate_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  double _maxBudget = 2000;
  String _selectedCity = 'All';

  final List<String> _filters = ['All', 'New Rooms', 'Join a Room'];
  final List<String> _cities = ['All', 'Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ListingModel> get _filteredListings {
    final listings = context.watch<ListingsProvider>().listings;
    return listings.where((l) {
      if (_selectedFilter == 'New Rooms') {
        if (!l.isOwnerPost || l.roommateIds.isNotEmpty) return false;
      } else if (_selectedFilter == 'Join a Room') {
        if (l.roommateIds.isEmpty) return false;
      }
      if (l.monthlyRent > _maxBudget) return false;
      if (_selectedCity != 'All' && !l.neighborhood.contains(_selectedCity)) return false;
      if (_searchController.text.isNotEmpty &&
          !l.title.toLowerCase().contains(_searchController.text.toLowerCase()) &&
          !l.location.toLowerCase().contains(_searchController.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<UserModel> get _filteredUsers {
    final currentUser = SampleData.currentUser;
    return SampleData.users.where((u) {
      if (_searchController.text.isNotEmpty &&
          !u.name.toLowerCase().contains(_searchController.text.toLowerCase()) &&
          !u.occupation.toLowerCase().contains(_searchController.text.toLowerCase())) {
        return false;
      }
      if (u.budgetRange.end > _maxBudget) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.compatibilityWith(currentUser).compareTo(a.compatibilityWith(currentUser)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListingsTab(),
                  _buildPeopleTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: GestureDetector(
              onTap: _showFiltersSheet,
              child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 22),
            ),
          ),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by neighborhood, city...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, color: AppColors.textLight),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ).animate().fade(duration: 400.ms, delay: 50.ms),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final selected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.outfit(
                    color: selected ? Colors.white : AppColors.textMedium,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Listings'),
          Tab(text: 'People'),
        ],
      ),
    );
  }

  Widget _buildListingsTab() {
    final listings = _filteredListings;
    if (listings.isEmpty) {
      return _buildEmptyState('No listings found', 'Try adjusting your filters', Icons.home_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: listings.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listings[i])),
            ),
            child: _ListingListCard(listing: listings[i]),
          ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideY(begin: 0.05),
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    final users = _filteredUsers;
    final currentUser = SampleData.currentUser;
    if (users.isEmpty) {
      return _buildEmptyState('No people found', 'Try adjusting your search', Icons.people_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final score = users[i].compatibilityWith(currentUser);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RoommateProfileScreen(user: users[i], currentUser: currentUser),
              ),
            ),
            child: _PeopleListCard(user: users[i], score: score),
          ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideY(begin: 0.05),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _maxBudget = 2000;
                          _selectedCity = 'All';
                          _selectedFilter = 'All';
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Reset', style: GoogleFonts.outfit(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Max Budget: \$${_maxBudget.toInt()}/mo',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                Slider(
                  value: _maxBudget,
                  min: 500,
                  max: 3000,
                  divisions: 25,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setSheetState(() => _maxBudget = v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Text('Neighborhood', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cities.map((c) {
                    final sel = _selectedCity == c;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() => _selectedCity = c);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(
                          c,
                          style: GoogleFonts.outfit(
                            color: sel ? Colors.white : AppColors.textMedium,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Apply Filters', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
    );
  }
}

class _ListingListCard extends StatelessWidget {
  final ListingModel listing;

  const _ListingListCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.network(
                  listing.photos.first,
                  width: 110,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 120,
                    color: AppColors.cardBg,
                    child: const Icon(Icons.home_rounded, size: 36, color: AppColors.textLight),
                  ),
                ),
              ),
              if (listing.isFeatured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Featured', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor(listing).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.isOwnerPost && listing.roommateIds.isEmpty
                              ? 'New Room'
                              : listing.roommateIds.isNotEmpty
                                  ? 'Join Room'
                                  : listing.typeLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _typeColor(listing),
                          ),
                        ),
                      ),
                      if (listing.isFurnished) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Furnished',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.title,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
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
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${listing.monthlyRent.toInt()}/mo',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      if (listing.utilitiesIncluded)
                        Text(
                          'Utils incl.',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.accentGreen),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(listing.userPhoto),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        listing.userName,
                        style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMedium),
                      ),
                      if (listing.userVerified) ...[
                        const SizedBox(width: 2),
                        const Icon(Icons.verified_rounded, size: 12, color: AppColors.verified),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(ListingModel listing) {
    if (listing.isOwnerPost && listing.roommateIds.isEmpty) {
      return AppColors.primary;
    } else if (listing.roommateIds.isNotEmpty) {
      return AppColors.accentGreen;
    } else {
      return AppColors.accentOrange;
    }
  }
}

class _PeopleListCard extends StatelessWidget {
  final UserModel user;
  final double score;

  const _PeopleListCard({required this.user, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: getUserImageProvider(user.photoUrl),
                backgroundColor: AppColors.cardBg,
              ),
              if (user.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
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
                Text(
                  '${user.name}, ${user.age}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
                ),
                Text(
                  user.occupation,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 2),
                    Text(
                      user.city,
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.payments_outlined, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 2),
                    Text(
                      user.budgetLabel,
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.matchGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(score * 100).toInt()}%',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 4),
              Text('match', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
