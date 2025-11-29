import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/apple_theme.dart';
import '../config/theme_manager.dart';
import '../widgets/premium_widgets.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'role_selection_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  int? _selectedAvatarIndex;
  final StorageService _storageService = StorageService();
  bool _isValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValid = _nameController.text.trim().length >= 2 &&
          _nameController.text.trim().length <= 30 &&
          _selectedAvatarIndex != null;
    });
  }

  Future<void> _continue() async {
    if (!_isValid) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      avatarIndex: _selectedAvatarIndex!,
      isFirstTime: false,
    );

    await _storageService.saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppleSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppleSpacing.xxl),

              // Header
              Container(
                padding: const EdgeInsets.all(AppleSpacing.xl),
                decoration: BoxDecoration(
                  gradient: themeManager.primaryGradient,
                  borderRadius: AppleRadius.xlAll,
                  boxShadow: AppleShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome!',
                          style: AppleTypography.largeTitle.copyWith(
                            color: AppleColors.white,
                          ),
                        ),
                        const SizedBox(width: AppleSpacing.md),
                        const Text('👋', style: TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(height: AppleSpacing.xs),
                    Text(
                      'Let\'s personalize your experience',
                      style: AppleTypography.body.copyWith(
                        color: AppleColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppleSpacing.xxxl),

              // Choose Avatar Section
              Text(
                'Choose Your Avatar',
                style: AppleTypography.title2.copyWith(color: themeManager.textColor),
              ),
              const SizedBox(height: AppleSpacing.base),
              Text(
                'Select an avatar that represents you',
                style: AppleTypography.callout.copyWith(color: themeManager.secondaryTextColor),
              ),

              const SizedBox(height: AppleSpacing.lg),

              // Avatar Grid
              _buildAvatarGrid(),

              const SizedBox(height: AppleSpacing.xxxl),

              // Name Input
              Text(
                'Your Name',
                style: AppleTypography.title2.copyWith(color: themeManager.textColor),
              ),
              const SizedBox(height: AppleSpacing.base),
              PremiumTextField(
                controller: _nameController,
                hintText: 'Enter your name...',
                onChanged: (_) => _validateInput(),
                maxLength: 30,
              ),
              const SizedBox(height: AppleSpacing.xs),
              Text(
                '2-30 characters',
                style: AppleTypography.caption1.copyWith(
                  color: AppleColors.systemGray,
                ),
              ),

              const SizedBox(height: AppleSpacing.xxxl),

              // Continue Button
              PremiumButton(
                text: 'Continue',
                icon: Icons.arrow_forward_rounded,
                gradient: _isValid
                    ? AppleColors.goldAccentGradient
                    : const LinearGradient(
                        colors: [
                          AppleColors.systemGray4,
                          AppleColors.systemGray3,
                        ],
                      ),
                onPressed: _isValid ? _continue : null,
              ),

              const SizedBox(height: AppleSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppleSpacing.md,
        mainAxisSpacing: AppleSpacing.md,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final isSelected = _selectedAvatarIndex == index;
        return _AvatarOption(
          index: index,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedAvatarIndex = index;
            });
            _validateInput();
          },
        );
      },
    );
  }
}

class _AvatarOption extends StatefulWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AvatarOption> createState() => _AvatarOptionState();
}

class _AvatarOptionState extends State<_AvatarOption>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppleColors.white,
            borderRadius: AppleRadius.mdAll,
            border: Border.all(
              color: widget.isSelected
                  ? AppleColors.accentGold
                  : AppleColors.systemGray5,
              width: widget.isSelected ? 3 : 1,
            ),
            boxShadow: widget.isSelected ? AppleShadows.elevated : AppleShadows.card,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.isSelected ? AppleRadius.md - 3 : AppleRadius.md - 1,
            ),
            child: Stack(
              children: [
                // Avatar Image (placeholder for now)
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _getAvatarGradient(widget.index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: AppleTypography.title3.copyWith(
                          color: AppleColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Selected indicator
                if (widget.isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        gradient: AppleColors.goldAccentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: AppleColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getAvatarGradient(int index) {
    final gradients = [
      AppleColors.redGradient,
      AppleColors.goldAccentGradient,
      const LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
      ),
      const LinearGradient(
        colors: [Color(0xFF7B1FA2), Color(0xFF6A1B9A)],
      ),
      const LinearGradient(
        colors: [Color(0xFF00897B), Color(0xFF26A69A)],
      ),
      const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFFF5252)],
      ),
      const LinearGradient(
        colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
      ),
    ];
    return gradients[index % gradients.length];
  }
}
