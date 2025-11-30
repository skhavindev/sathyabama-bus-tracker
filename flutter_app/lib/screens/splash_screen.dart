import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../config/apple_theme.dart';
import '../config/theme_manager.dart';
import '../services/storage_service.dart';
import 'profile_setup_screen.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppleDurations.splash,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        final storageService = StorageService();
        final isFirstTime = await storageService.isFirstTime();
        
        final nextScreen = isFirstTime
            ? const ProfileSetupScreen()
            : const RoleSelectionScreen();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  nextScreen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: AppleDurations.slow,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: themeManager.primaryGradient),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppleColors.white,
                            borderRadius: AppleRadius.xlAll,
                            boxShadow: AppleShadows.floating,
                          ),
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontFamily: AppleTypography.fontFamily,
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: themeManager.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppleSpacing.xl),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Text(
                            'Sathyabama',
                            style: AppleTypography.title1.copyWith(
                              color: AppleColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppleSpacing.xs),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Text(
                            'Bus Tracker',
                            style: AppleTypography.title2.copyWith(
                              color: AppleColors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppleSpacing.xxxl),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 1.5),
                          child: Text(
                            'Track your campus bus',
                            style: AppleTypography.body.copyWith(
                              color: AppleColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
