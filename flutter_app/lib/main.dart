import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/apple_theme.dart';
import 'config/theme_manager.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppleColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: const SISTTransitPlusApp(),
    ),
  );
}

class SISTTransitPlusApp extends StatelessWidget {
  const SISTTransitPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
      title: 'SIST Transit+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppleTypography.fontFamily,
        primaryColor: themeManager.primaryColor,
        scaffoldBackgroundColor: themeManager.cardColor,
        brightness: themeManager.isDarkMode ? Brightness.dark : Brightness.light,
        colorScheme: themeManager.isDarkMode
            ? ColorScheme.dark(
                primary: themeManager.primaryColor,
                secondary: AppleColors.accentGold,
                surface: themeManager.cardColor,
                background: themeManager.backgroundColor,
                error: AppleColors.error,
              )
            : ColorScheme.light(
                primary: themeManager.primaryColor,
                secondary: AppleColors.accentGold,
                surface: themeManager.cardColor,
                background: themeManager.backgroundColor,
                error: AppleColors.error,
              ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        textTheme: TextTheme(
          displayLarge: AppleTypography.largeTitle,
          displayMedium: AppleTypography.title1,
          displaySmall: AppleTypography.title2,
          headlineMedium: AppleTypography.title3,
          headlineSmall: AppleTypography.headline,
          bodyLarge: AppleTypography.body,
          bodyMedium: AppleTypography.callout,
          bodySmall: AppleTypography.subhead,
          labelLarge: AppleTypography.headline,
          labelMedium: AppleTypography.footnote,
          labelSmall: AppleTypography.caption1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeManager.primaryColor,
            foregroundColor: AppleColors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: AppleRadius.mdAll,
            ),
            textStyle: AppleTypography.headline,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppleColors.accentGold,
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppleColors.accentGold, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: AppleRadius.mdAll,
            ),
            textStyle: AppleTypography.headline,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: themeManager.cardColor,
          border: OutlineInputBorder(
            borderRadius: AppleRadius.mdAll,
            borderSide: const BorderSide(color: AppleColors.systemGray4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppleRadius.mdAll,
            borderSide: const BorderSide(color: AppleColors.systemGray4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppleRadius.mdAll,
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppleRadius.mdAll,
            borderSide: const BorderSide(color: AppleColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppleSpacing.base,
            vertical: AppleSpacing.md,
          ),
          hintStyle: AppleTypography.body.copyWith(color: AppleColors.systemGray),
        ),
        cardTheme: CardThemeData(
          color: themeManager.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppleRadius.xlAll,
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: themeManager.cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppleRadius.xl),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: themeManager.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppleRadius.xlAll,
          ),
        ),
      ),
      home: const SplashScreen(),
        );
      },
    );
  }
}
