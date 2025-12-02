import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/apple_theme.dart';
import '../config/theme_manager.dart';
import '../widgets/premium_widgets.dart';
import 'student/student_home_screen.dart';
import 'driver/driver_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
    ));

    _controller.forward();
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
      backgroundColor: themeManager.backgroundColor,
      body: Column(
            children: [
              // Curved gradient header
              Container(
                decoration: BoxDecoration(
                  gradient: themeManager.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppleRadius.xxl),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppleSpacing.screenHorizontal,
                      AppleSpacing.lg,
                      AppleSpacing.screenHorizontal,
                      AppleSpacing.xxxl,
                    ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showDriverLoginOption(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: themeManager.cardColor,
                            borderRadius: AppleRadius.mdAll,
                            boxShadow: AppleShadows.card,
                          ),
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontFamily: AppleTypography.fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: themeManager.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppleSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sathyabama',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppleColors.white,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => AppleColors.goldAccentGradient.createShader(bounds),
                              child: const Text(
                                'transit+',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppleColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

              // Content
              Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppleSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppleSpacing.xl),

                  // Welcome text with decorative element
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome',
                              style: AppleTypography.largeTitle.copyWith(
                                color: themeManager.textColor,
                              ),
                            ),
                            const SizedBox(width: AppleSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(AppleSpacing.xs),
                              decoration: BoxDecoration(
                                gradient: AppleColors.goldAccentGradient,
                                borderRadius: AppleRadius.smAll,
                              ),
                              child: const Icon(
                                Icons.waving_hand_rounded,
                                color: AppleColors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppleSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: themeManager.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: AppleSpacing.xs),
                            Expanded(
                              child: Text(
                                'Track campus buses in real-time',
                                style: AppleTypography.callout.copyWith(
                                  color: themeManager.secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppleSpacing.xxl),

                  // Student card (main action)
                  SlideTransition(
                    position: _slideAnimation1,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _RoleCard(
                        icon: Icons.directions_bus_rounded,
                        title: 'Track Buses',
                        description: 'See all buses and their live locations',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const StudentHomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverLoginOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppleColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppleRadius.xlAll),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppleColors.redGradient,
                borderRadius: AppleRadius.smAll,
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  color: AppleColors.white, size: 22),
            ),
            const SizedBox(width: AppleSpacing.md),
            Text('Driver Access', style: AppleTypography.title3),
          ],
        ),
        content: Text(
          'Are you a bus driver? Login to start your shift and share your location.',
          style: AppleTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppleTypography.headline
                    .copyWith(color: AppleColors.systemGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DriverLoginScreen(),
                ),
              );
            },
            child: Text('Driver Login',
                style: AppleTypography.headline
                    .copyWith(color: AppleColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDriver;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    this.isDriver = false,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: PremiumCard(
          backgroundColor: themeManager.cardColor,
          padding: const EdgeInsets.all(AppleSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.isDriver
                      ? themeManager.primaryGradient
                      : AppleColors.goldGradient,
                  borderRadius: AppleRadius.mdAll,
                  boxShadow: AppleShadows.card,
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: AppleColors.white,
                ),
              ),
              const SizedBox(width: AppleSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppleTypography.title3.copyWith(
                        color: themeManager.textColor,
                      ),
                    ),
                    const SizedBox(height: AppleSpacing.xs),
                    Text(
                      widget.description,
                      style: AppleTypography.callout.copyWith(
                        color: themeManager.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: themeManager.secondaryTextColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
