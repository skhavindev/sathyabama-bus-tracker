import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/apple_theme.dart';
import '../config/theme_manager.dart';
import '../widgets/premium_widgets.dart';
import '../services/storage_service.dart';
import '../models/user_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _storageService.getProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: themeManager.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppleTypography.title3.copyWith(color: themeManager.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppleSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Text(
              'Appearance',
              style: AppleTypography.headline.copyWith(color: themeManager.textColor),
            ),
            const SizedBox(height: AppleSpacing.md),

            // Theme Color Selector
            PremiumCard(
              backgroundColor: themeManager.cardColor,
              padding: const EdgeInsets.all(AppleSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Color',
                    style: AppleTypography.subhead.copyWith(color: themeManager.textColor),
                  ),
                  const SizedBox(height: AppleSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ColorSwatch(
                        gradient: AppleColors.redGradient,
                        label: 'Red',
                        isSelected: themeManager.preferences.colorTheme == ColorTheme.red,
                        onTap: () => themeManager.setColorTheme(ColorTheme.red),
                      ),
                      _ColorSwatch(
                        gradient: AppleColors.blueGradient,
                        label: 'Blue',
                        isSelected: themeManager.preferences.colorTheme == ColorTheme.blue,
                        onTap: () => themeManager.setColorTheme(ColorTheme.blue),
                      ),
                      _ColorSwatch(
                        gradient: AppleColors.purpleGradient,
                        label: 'Purple',
                        isSelected: themeManager.preferences.colorTheme == ColorTheme.purple,
                        onTap: () => themeManager.setColorTheme(ColorTheme.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppleSpacing.md),

            // Dark Mode Toggle
            PremiumCard(
              backgroundColor: themeManager.cardColor,
              padding: const EdgeInsets.all(AppleSpacing.base),
              child: Row(
                children: [
                  Icon(
                    themeManager.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: themeManager.primaryColor,
                  ),
                  const SizedBox(width: AppleSpacing.md),
                  Expanded(
                    child: Text(
                      'Dark Mode',
                      style: AppleTypography.body.copyWith(color: themeManager.textColor),
                    ),
                  ),
                  Switch(
                    value: themeManager.isDarkMode,
                    onChanged: (value) {
                      themeManager.setBrightnessMode(
                        value ? BrightnessMode.dark : BrightnessMode.light,
                      );
                    },
                    activeColor: themeManager.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppleSpacing.xxl),

            // Profile Section
            Text(
              'Profile',
              style: AppleTypography.headline.copyWith(color: themeManager.textColor),
            ),
            const SizedBox(height: AppleSpacing.md),

            PremiumCard(
              backgroundColor: themeManager.cardColor,
              padding: const EdgeInsets.all(AppleSpacing.base),
              child: Row(
                children: [
                  if (_userProfile != null)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeManager.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/avatars/avatar_${_userProfile!.avatarIndex + 1}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: themeManager.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppleColors.white,
                        size: 28,
                      ),
                    ),
                  const SizedBox(width: AppleSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userProfile?.name ?? 'User',
                          style: AppleTypography.headline.copyWith(color: themeManager.textColor),
                        ),
                        Text(
                          'Tap to change profile',
                          style: AppleTypography.caption1.copyWith(color: themeManager.secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: themeManager.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final LinearGradient gradient;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.gradient,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppleColors.accentGold, width: 3)
                  : null,
              boxShadow: isSelected ? AppleShadows.elevated : AppleShadows.card,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: AppleColors.white,
                    size: 32,
                  )
                : null,
          ),
          const SizedBox(height: AppleSpacing.xs),
          Text(
            label,
            style: AppleTypography.caption1.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}