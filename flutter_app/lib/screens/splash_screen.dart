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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppleColors.goldAccentGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppleColors.accentGold.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/icons/app_icon.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // App name - Sathyabama
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: const Text(
                            'Sathyabama',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppleColors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // transit+ in gold
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppleColors.goldAccentGradient.createShader(bounds),
                            child: const Text(
                              'transit+',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppleColors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 1.5),
                          child: const Text(
                            'Track Your Campus Bus',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppleColors.systemGray,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // By line
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 1.5),
                          child: const Text(
                            'by',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppleColors.systemGray,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Developer name
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 1.5),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppleColors.goldAccentGradient.createShader(bounds),
                            child: const Text(
                              'S Khavin',
                              style: TextStyle(
                                fontSize: 31,
                                fontFamily: 'CaliforniaSignature',
                                color: AppleColors.white,
                                fontWeight: FontWeight.w400,
                              ),
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
