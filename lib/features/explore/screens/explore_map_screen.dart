import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/providers/listings_provider.dart';
import '../../listings/screens/listing_detail_screen.dart';
import 'package:provider/provider.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  ListingModel? _selectedListing;

  // Generate deterministic position from a string (location + id)
  Offset _positionFor(ListingModel listing, Size mapSize) {
    final seed = listing.location.hashCode ^ listing.id.hashCode;
    final x = ((seed.abs() % 700) + 80).toDouble();
    final y = (((seed.abs() ~/ 7) % 600) + 120).toDouble();
    return Offset(x.clamp(40, mapSize.width - 40), y.clamp(40, mapSize.height - 40));
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().listings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Explore Map',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'No listings to show on the map',
                    style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textMedium),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Map background with grid
                InteractiveViewer(
                  maxScale: 3.0,
                  minScale: 0.5,
                  constrained: false,
                  child: SizedBox(
                    width: 1200,
                    height: 1000,
                    child: CustomPaint(
                      painter: _MapGridPainter(),
                      child: Stack(
                        children: listings.map((listing) {
                          final pos = _positionFor(listing, const Size(1200, 1000));
                          final isSelected = _selectedListing?.id == listing.id;

                          return Positioned(
                            top: pos.dy - 20,
                            left: pos.dx - 50,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedListing = listing),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Price bubble
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isSelected ? 0.2 : 0.08),
                                          blurRadius: isSelected ? 12 : 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isSelected ? Colors.white : AppColors.border,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      '\$${listing.monthlyRent.toInt()}/mo',
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? Colors.white : AppColors.textDark,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  // Pin pointer
                                  Container(
                                    width: 2,
                                    height: 10,
                                    color: isSelected ? AppColors.primary : AppColors.textLight,
                                  ),
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: isSelected ? AppColors.primary : AppColors.accent,
                                    size: 24,
                                  ),
                                  // Location label
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 100),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      listing.location,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        color: AppColors.textMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Selected listing detail card at bottom
                if (_selectedListing != null)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: _selectedListing!),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _selectedListing!.photos.isNotEmpty
                                  ? Image.network(
                                      _selectedListing!.photos.first,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedListing!.title,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textLight),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _selectedListing!.location,
                                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${_selectedListing!.monthlyRent.toInt()}/mo',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'View Details →',
                                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
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
                  ),

                // Close selected listing
                if (_selectedListing != null)
                  Positioned(
                    bottom: 110,
                    right: 24,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedListing = null),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.home_rounded, size: 32, color: AppColors.textLight),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF0EDE8),
    );

    // Grid roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    // Horizontal roads
    for (double y = 80; y < size.height; y += 120) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 100; x < size.width; x += 150) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Block fills (green parks / grey buildings)
    final parkPaint = Paint()..color = const Color(0xFFD5E8D4).withOpacity(0.5);
    final buildingPaint = Paint()..color = const Color(0xFFE0DDD8).withOpacity(0.4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(120, 100, 120, 100), const Radius.circular(8)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(400, 250, 130, 90), const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(700, 400, 100, 140), const Radius.circular(8)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(200, 500, 150, 100), const Radius.circular(8)),
      buildingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
