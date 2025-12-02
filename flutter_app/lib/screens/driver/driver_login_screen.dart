import 'package:flutter/material.dart';
import '../../config/apple_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../services/auth_service.dart';
import 'driver_home_screen.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _phoneError = null;
      _passwordError = null;
      _errorMessage = null;
    });

    bool hasError = false;
    if (_phoneController.text.isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      hasError = true;
    } else if (_phoneController.text.length < 10) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      hasError = true;
    } else if (_passwordController.text.length < 4) {
      setState(() => _passwordError = 'Password must be at least 4 characters');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      // Add +91 prefix if not present
      String phone = _phoneController.text.trim();
      if (!phone.startsWith('+91')) {
        phone = '+91$phone';
      }
      final password = _passwordController.text;

      final success = await AuthService().login(phone, password);

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DriverHomeScreen(driverName: 'Driver'),
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Invalid phone number or password';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleColors.white,
      body: PremiumLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppleSpacing.screenHorizontal),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppleSpacing.base),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppleColors.labelPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: AppleSpacing.xxl),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppleColors.redGradient,
                        borderRadius: AppleRadius.lgAll,
                        boxShadow: AppleShadows.elevated,
                      ),
                      child: const Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontFamily: AppleTypography.fontFamily,
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: AppleColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppleSpacing.xl),

                  // Title
                  Text(
                    'Driver Login',
                    style: AppleTypography.largeTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppleSpacing.sm),
                  Text(
                    'Enter your credentials to continue',
                    style: AppleTypography.callout,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppleSpacing.xxxl),

                  // Phone field
                  PremiumTextField(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_rounded,
                    prefixText: '+91 ',
                    errorText: _phoneError,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),

                  const SizedBox(height: AppleSpacing.lg),

                  // Password field
                  PremiumTextField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_rounded,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: AppleColors.systemGray,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),

                  const SizedBox(height: AppleSpacing.xxl),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppleSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppleSpacing.base),
                      decoration: BoxDecoration(
                        color: AppleColors.error.withValues(alpha: 0.1),
                        borderRadius: AppleRadius.mdAll,
                        border: Border.all(
                          color: AppleColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppleColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppleSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppleTypography.subhead.copyWith(
                                color: AppleColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Login button
                  PremiumButton(
                    text: 'Login',
                    icon: Icons.login_rounded,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppleSpacing.xl),

                  // Info card
                  PremiumCard(
                    backgroundColor: AppleColors.systemGray6,
                    padding: const EdgeInsets.all(AppleSpacing.base),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppleColors.accentGold.withValues(alpha: 0.2),
                            borderRadius: AppleRadius.smAll,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: AppleColors.accentGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppleSpacing.md),
                        Expanded(
                          child: Text(
                            'Your session will never expire. You stay logged in permanently.',
                            style: AppleTypography.subhead,
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
    );
  }
}
