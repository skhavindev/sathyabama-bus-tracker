import 'package:flutter/material.dart';

/// Apple-inspired color palette with red gradient and gold accents
class AppleColors {
  // Backgrounds
  static const white = Color(0xFFFFFFFF);
  static const systemGray6 = Color(0xFFF2F2F7);
  static const systemGray5 = Color(0xFFE5E5EA);
  static const systemGray4 = Color(0xFFD1D1D6);
  static const systemGray3 = Color(0xFFC7C7CC);
  static const systemGray2 = Color(0xFFAEAEB2);
  static const systemGray = Color(0xFF8E8E93);

  // Text colors
  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0xFF3C3C43);
  static const labelTertiary = Color(0xFF48484A);
  static const labelQuaternary = Color(0xFF636366);

  // Brand colors (preserved) - More saturated and darker
  static const primaryRed = Color(0xFFE53935);
  static const darkRed = Color(0xFFB71C1C);  // Much darker, more saturated
  static const lightRed = Color(0xFFD32F2F);  // Darker light red
  static const accentGold = Color(0xFFFFD700);
  static const darkGold = Color(0xFFFFA000);
  static const lightGold = Color(0xFFFFE082);

  // Semantic colors
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const info = Color(0xFF007AFF);

  // Blue theme colors
  static const primaryBlue = Color(0xFF1565C0);
  static const darkBlue = Color(0xFF0D47A1);
  static const lightBlue = Color(0xFF1976D2);

  // Purple theme colors
  static const primaryPurple = Color(0xFF7B1FA2);
  static const darkPurple = Color(0xFF4A148C);
  static const lightPurple = Color(0xFF6A1B9A);

  // Dark mode colors
  static const darkBackground = Color(0xFF000000);
  static const darkCard = Color(0xFF1C1C1E);
  static const darkGray = Color(0xFF2C2C2E);
  static const darkLabelPrimary = Color(0xFFFFFFFF);
  static const darkLabelSecondary = Color(0xFFEBEBF5);

  // Gradients - Dark to Light
  static const redGradient = LinearGradient(
    colors: [darkRed, lightRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [darkGold, accentGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gold accent gradient for highlights
  static const goldAccentGradient = LinearGradient(
    colors: [accentGold, lightGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Blue gradient
  static const blueGradient = LinearGradient(
    colors: [darkBlue, lightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Purple gradient
  static const purpleGradient = LinearGradient(
    colors: [darkPurple, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}

/// Apple-inspired typography scale
class AppleTypography {
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyText = 'SF Pro Text';


  // Large Title - 34pt Bold
  static const largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppleColors.labelPrimary,
  );

  // Title 1 - 28pt Bold
  static const title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppleColors.labelPrimary,
  );

  // Title 2 - 22pt Bold
  static const title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppleColors.labelPrimary,
  );

  // Title 3 - 20pt Semibold
  static const title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppleColors.labelPrimary,
  );

  // Headline - 17pt Semibold
  static const headline = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppleColors.labelPrimary,
  );

  // Body - 17pt Regular
  static const body = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelPrimary,
  );

  // Callout - 16pt Regular
  static const callout = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelSecondary,
  );

  // Subhead - 15pt Regular
  static const subhead = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelSecondary,
  );

  // Footnote - 13pt Regular
  static const footnote = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelTertiary,
  );

  // Caption 1 - 12pt Regular
  static const caption1 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelTertiary,
  );

  // Caption 2 - 11pt Regular
  static const caption2 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppleColors.labelQuaternary,
  );

  // Signature style - cursive/script (use with GoogleFonts.pacifico())
  static const signatureSize = 13.0;
  static const signatureLetterSpacing = 0.5;

  // White variants for dark backgrounds
  static TextStyle white(TextStyle style) {
    return style.copyWith(color: AppleColors.white);
  }
}

/// Spacing constants following Apple's 4pt grid
class AppleSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Screen margins
  static const double screenHorizontal = 20;
  static const double screenVertical = 16;

  // Card padding
  static const double cardPadding = 16;
  static const double cardPaddingLarge = 20;
}

/// Border radius constants
class AppleRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double xxl = 28;
  static const double full = 100;

  // Convenience BorderRadius objects
  static final smAll = BorderRadius.circular(sm);
  static final mdAll = BorderRadius.circular(md);
  static final lgAll = BorderRadius.circular(lg);
  static final xlAll = BorderRadius.circular(xl);
  static final fullAll = BorderRadius.circular(full);
}

/// Shadow definitions for elevation
class AppleShadows {
  // Subtle card shadow
  static const card = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Medium elevation shadow
  static const elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // Strong shadow for floating elements
  static const floating = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  // Button shadow with brand color
  static List<BoxShadow> buttonShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Animation durations
class AppleDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 350);
  static const splash = Duration(milliseconds: 800);
}

/// Animation curves
class AppleCurves {
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const spring = Curves.elasticOut;
  static const bounce = Curves.bounceOut;
}
