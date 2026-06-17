import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class FlashScreen extends StatelessWidget {
  const FlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.home_rounded, color: AppColors.primary, size: 48),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fade(duration: 400.ms),
            
            const SizedBox(height: 24),
            
            Text(
              'Homie',
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 200.ms).fade(duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Find your people. Find your place.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 400.ms).fade(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
