import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/saved_listings_provider.dart';
import 'data/providers/expense_provider.dart';
import 'data/providers/app_provider.dart';
import 'data/providers/message_provider.dart';
import 'data/providers/review_provider.dart';
import 'data/providers/roommate_provider.dart';
import 'data/providers/listings_provider.dart';
import 'data/providers/notification_provider.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/explore/screens/explore_screen.dart';
import 'features/messages/screens/messages_screen.dart';
import 'features/expenses/screens/expenses_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HomieApp());
}

class HomieApp extends StatelessWidget {
  const HomieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => SavedListingsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => RoommateProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(

        title: 'Homie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const MainApp();
            }
            return const SplashScreen();
          },
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MessagesScreen(),
    const ExpensesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final msgProvider = context.watch<MessageProvider>();
    final appProvider = context.watch<AppProvider>();
    final currentIndex = appProvider.currentNavIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, label: 'Home', index: 0, currentIndex: currentIndex, onTap: () => appProvider.setNavIndex(0)),
                _NavItem(icon: Icons.explore_rounded, outlinedIcon: Icons.explore_outlined, label: 'Explore', index: 1, currentIndex: currentIndex, onTap: () => appProvider.setNavIndex(1)),
                _NavItem(icon: Icons.chat_bubble_rounded, outlinedIcon: Icons.chat_bubble_outline_rounded, label: 'Messages', index: 2, currentIndex: currentIndex, onTap: () => appProvider.setNavIndex(2), badge: msgProvider.totalUnread),
                _NavItem(icon: Icons.account_balance_wallet_rounded, outlinedIcon: Icons.account_balance_wallet_outlined, label: 'Expenses', index: 3, currentIndex: currentIndex, onTap: () => appProvider.setNavIndex(3)),
                _NavItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, label: 'Profile', index: 4, currentIndex: currentIndex, onTap: () => appProvider.setNavIndex(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final int badge;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? icon : outlinedIcon,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
