import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/listings_provider.dart';
import '../../listings/screens/listing_detail_screen.dart';
import '../../listings/screens/post_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final listingsProvider = context.watch<ListingsProvider>();
    
    if (user == null) return const Scaffold();

    final myListings = listingsProvider.listings.where((l) => l.userId == user.id).toList();

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
          'My Listings',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: myListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.maps_home_work_outlined, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t posted any listings yet.',
                    style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PostListingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Post a Room', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myListings.length,
              itemBuilder: (context, i) {
                final listing = myListings[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: listing.photos.isNotEmpty
                          ? Image.network(
                              listing.photos.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                    title: Text(
                      listing.title,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '\$${listing.monthlyRent.toInt()}/mo',
                          style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          listing.location,
                          style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textDark),
                      onSelected: (value) {
                        if (value == 'edit') {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Edit feature coming soon!')),
                           );
                        } else if (value == 'delete') {
                          listingsProvider.removeListing(listing.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing deleted')),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Listing'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.cardBg,
      child: const Icon(Icons.home_rounded, color: AppColors.textLight),
    );
  }
}
