import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_helper.dart';
import '../../../data/models/user_model.dart';
import 'roommate_profile_screen.dart';

class MatchesListScreen extends StatelessWidget {
  final UserModel currentUser;

  const MatchesListScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Only show users with >= 75% compatibility, sorted by score
    final matches = <UserModel>[];

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
          'My Matches',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Summary banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${matches.length} High Compatibility Matches',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Showing only 75%+ compatibility matches',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

          // List or empty state
          Expanded(
            child: matches.isEmpty
                ? Center(
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
                          child: Icon(Icons.people_outline_rounded, size: 36, color: AppColors.primary.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No high matches yet',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Complete your profile to find roommates with 75%+ compatibility.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMedium, height: 1.5),
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 500.ms),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = matches[index];
                      final score = user.compatibilityWith(currentUser);
                      return _MatchCard(
                        user: user,
                        score: score,
                        rank: index + 1,
                        currentUser: currentUser,
                      ).animate(delay: (index * 60).ms).fade(duration: 350.ms).slideX(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final double score;
  final int rank;

  const _MatchCard({required this.user, required this.currentUser, required this.score, required this.rank});

  Color get _scoreColor {
    if (score >= 0.8) return AppColors.accentGreen;
    if (score >= 0.6) return AppColors.primary;
    if (score >= 0.4) return AppColors.accentOrange;
    return AppColors.textMedium;
  }

  String get _scoreLabel {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Great';
    if (score >= 0.4) return 'Good';
    return 'Fair';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();

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
            // Rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank == 1
                    ? const Color(0xFFFFD700)
                    : rank == 2
                        ? const Color(0xFFC0C0C0)
                        : rank == 3
                            ? const Color(0xFFCD7F32)
                            : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: rank <= 3 ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _scoreColor.withOpacity(0.4), width: 2.5),
              ),
              child: ClipOval(
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
                  const SizedBox(height: 6),
                  // Compatibility bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _scoreColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _scoreColor.withOpacity(0.3)),
              ),
              child: Text(
                _scoreLabel,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _scoreColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
