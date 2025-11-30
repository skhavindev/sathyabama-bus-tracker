import 'package:flutter/material.dart';
import '../../config/apple_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../services/api_service.dart';
import '../../models/driver_profile.dart';
import 'driver_tracking_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final String driverName;

  const DriverHomeScreen({super.key, required this.driverName});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String? _selectedBus;
  String? _selectedRoute;
  bool _isLoading = true;
  bool _isStartingShift = false;

  List<String> _buses = [];
  final List<Map<String, String>> _routes = [
    {'id': 'R1', 'name': 'Tambaram - Sathyabama'},
    {'id': 'R2', 'name': 'Velachery - Sathyabama'},
    {'id': 'R3', 'name': 'Adyar - Sathyabama'},
    {'id': 'R4', 'name': 'Guindy - Sathyabama via Velachery, Medavakkam'},
    {'id': 'R5', 'name': 'T.Nagar - Sathyabama via Saidapet, Guindy'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService().getDriverProfile();
      setState(() {
        _selectedBus = profile.assignedBus;
        _selectedRoute = profile.assignedRoute;
        // Only show assigned bus
        _buses = profile.assignedBus != null ? [profile.assignedBus!] : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _startShift() async {
    if (_selectedBus == null || _selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bus or route assigned. Contact admin.')),
      );
      return;
    }

    setState(() => _isStartingShift = true);

    try {
      // Get the route name from the route ID
      final routeMap = _routes.firstWhere(
        (r) => r['id'] == _selectedRoute,
        orElse: () => {'id': _selectedRoute!, 'name': 'Unknown Route'},
      );
      
      await ApiService().startShift(_selectedBus!, routeMap['name']!);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriverTrackingScreen(
              busNumber: _selectedBus!,
              routeName: routeMap['name']!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start shift: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingShift = false);
      }
    }
  }

  void _showCustomBusDialog() {
    final busController = TextEditingController();
    final routeController = TextEditingController();
    final viaPointsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppleColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppleRadius.xl),
            ),
          ),
          padding: const EdgeInsets.all(AppleSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppleColors.systemGray4,
                    borderRadius: AppleRadius.smAll,
                  ),
                ),
              ),
              const SizedBox(height: AppleSpacing.lg),
              Text('Request Custom Bus/Route',
                  style: AppleTypography.title2),
              const SizedBox(height: AppleSpacing.base),
              Text(
                'If your bus or route is not listed, submit a request for admin approval.',
                style: AppleTypography.subhead,
              ),
              const SizedBox(height: AppleSpacing.lg),
              PremiumTextField(
                labelText: 'Bus Number',
                hintText: 'e.g., 042',
                controller: busController,
              ),
              const SizedBox(height: AppleSpacing.base),
              PremiumTextField(
                labelText: 'Route Name',
                hintText: 'e.g., Campus to Guduvancherry',
                controller: routeController,
              ),
              const SizedBox(height: AppleSpacing.base),
              PremiumTextField(
                labelText: 'Via Points',
                hintText: 'e.g., Chromepet, Pallavaram',
                controller: viaPointsController,
                maxLines: 3,
              ),
              const SizedBox(height: AppleSpacing.lg),
              PremiumButton(
                text: 'Submit for Approval',
                icon: Icons.send_rounded,
                onPressed: () async {
                  if (busController.text.isEmpty ||
                      routeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  try {
                    await ApiService().requestCustomBus(
                      busController.text,
                      routeController.text,
                      viaPointsController.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Request submitted! You can use this bus now.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to submit: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final canStartShift = _selectedBus != null && _selectedRoute != null;

    return Scaffold(
      backgroundColor: AppleColors.systemGray6,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PremiumLoadingOverlay(
              isLoading: _isStartingShift,
              child: Column(
        children: [
          // Red gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: AppleColors.redGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppleRadius.xxl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppleSpacing.screenHorizontal,
                  AppleSpacing.md,
                  AppleSpacing.screenHorizontal,
                  AppleSpacing.xl,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppleColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppleShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          widget.driverName[0].toUpperCase(),
                          style: AppleTypography.title3.copyWith(
                            color: AppleColors.labelPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppleSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${widget.driverName}',
                            style: AppleTypography.headline.copyWith(
                              color: AppleColors.white,
                            ),
                          ),
                          Text(
                            'Ready for your shift?',
                            style: AppleTypography.subhead.copyWith(
                              color: AppleColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppleColors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppleSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppleSpacing.lg),

                  // Main card
                  PremiumCard(
                    padding: const EdgeInsets.all(AppleSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppleColors.redGradient,
                                borderRadius: AppleRadius.mdAll,
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: AppleColors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: AppleSpacing.md),
                            Text("Today I'm Driving",
                                style: AppleTypography.title3),
                          ],
                        ),

                        const SizedBox(height: AppleSpacing.xl),

                        // Assigned Bus Display
                        Text('Your Assigned Bus', style: AppleTypography.subhead),
                        const SizedBox(height: AppleSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppleSpacing.base),
                          decoration: BoxDecoration(
                            color: AppleColors.systemGray6,
                            borderRadius: AppleRadius.mdAll,
                            border: Border.all(color: AppleColors.systemGray5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppleColors.goldGradient,
                                  borderRadius: AppleRadius.smAll,
                                ),
                                child: const Icon(
                                  Icons.directions_bus_rounded,
                                  color: AppleColors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppleSpacing.md),
                              Expanded(
                                child: Text(
                                  _selectedBus ?? 'No bus assigned',
                                  style: AppleTypography.headline.copyWith(
                                    color: _selectedBus != null 
                                        ? AppleColors.labelPrimary 
                                        : AppleColors.systemGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppleSpacing.lg),

                        // Assigned Route Display
                        Text('Your Route', style: AppleTypography.subhead),
                        const SizedBox(height: AppleSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppleSpacing.base),
                          decoration: BoxDecoration(
                            color: AppleColors.systemGray6,
                            borderRadius: AppleRadius.mdAll,
                            border: Border.all(color: AppleColors.systemGray5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppleColors.redGradient,
                                  borderRadius: AppleRadius.smAll,
                                ),
                                child: const Icon(
                                  Icons.route_rounded,
                                  color: AppleColors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppleSpacing.md),
                              Expanded(
                                child: Text(
                                  _selectedRoute != null
                                      ? _routes.firstWhere(
                                          (r) => r['id'] == _selectedRoute,
                                          orElse: () => {'name': 'Unknown Route'},
                                        )['name']!
                                      : 'No route assigned',
                                  style: AppleTypography.body.copyWith(
                                    color: _selectedRoute != null 
                                        ? AppleColors.labelPrimary 
                                        : AppleColors.systemGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppleSpacing.md),

                        // Contact admin if no assignment
                        if (_selectedBus == null || _selectedRoute == null)
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please contact admin to assign a bus and route'),
                                ),
                              );
                            },
                            child: Text(
                            'No assignment? Contact admin',
                            style: AppleTypography.subhead.copyWith(
                              color: AppleColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppleSpacing.lg),

                  // Start button
                  AnimatedOpacity(
                    opacity: canStartShift ? 1.0 : 0.5,
                    duration: AppleDurations.base,
                    child: PremiumButton(
                      text: 'Start Shift',
                      icon: Icons.play_arrow_rounded,
                      gradient: AppleColors.goldGradient,
                      onPressed: canStartShift ? _startShift : null,
                    ),
                  ),

                  const SizedBox(height: AppleSpacing.xl),

                  // Info card
                  if (_selectedBus != null && _selectedRoute != null)
                    Container(
                      padding: const EdgeInsets.all(AppleSpacing.base),
                      decoration: BoxDecoration(
                        color: AppleColors.accentGold.withValues(alpha: 0.1),
                        borderRadius: AppleRadius.mdAll,
                        border: Border.all(
                          color: AppleColors.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppleColors.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: AppleSpacing.sm),
                          Expanded(
                            child: Text(
                              'Tap "Start Shift" to begin location sharing',
                              style: AppleTypography.caption1.copyWith(
                                color: AppleColors.labelPrimary,
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
        ],
      ),
            ),
    );
  }

  Widget _buildDropdown({
    String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppleColors.systemGray6,
        borderRadius: AppleRadius.mdAll,
        border: Border.all(color: AppleColors.systemGray5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppleSpacing.base),
            child: Text(hint, style: AppleTypography.body.copyWith(
              color: AppleColors.systemGray,
            )),
          ),
          isExpanded: true,
          dropdownColor: AppleColors.white,
          borderRadius: AppleRadius.mdAll,
          icon: const Padding(
            padding: EdgeInsets.only(right: AppleSpacing.base),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppleColors.systemGray),
          ),
          items: items,
          onChanged: onChanged,
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppleSpacing.base),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value != null
                        ? (item.child as Text).data ?? ''
                        : hint,
                    style: AppleTypography.body,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
