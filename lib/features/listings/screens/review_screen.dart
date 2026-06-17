import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/listing_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/review_provider.dart';
import '../../../core/theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  final ListingModel listing;

  const ReviewScreen({Key? key, required this.listing}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final reviewer = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reviewerName: reviewer.name,
      reviewerPhotoUrl: reviewer.photoUrl,
      targetUserId: widget.listing.userId,
      targetUserName: widget.listing.userName,
      targetListingId: widget.listing.id,
      rating: _rating,
      text: _reviewController.text.trim(),
      createdAt: DateTime.now(),
    );
    Provider.of<ReviewProvider>(context, listen: false).addReview(review);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted'), backgroundColor: Color(0xFF10B981)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Review', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate ${widget.listing.title}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Icon(
                    Icons.star_rounded,
                    color: starIndex <= _rating ? AppColors.accentOrange : AppColors.textLight,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Write your review... ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 && _reviewController.text.trim().isNotEmpty ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Submit Review', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
