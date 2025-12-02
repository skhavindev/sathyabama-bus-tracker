import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/apple_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_sharing_service.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String busNumber;
  final String routeName;

  const DriverTrackingScreen({
    super.key,
    required this.busNumber,
    required this.routeName,
  });

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final MapController _mapController = MapController();
  final LocationSharingService _sharingService = LocationSharingService();
  Timer? _uiUpdateTimer;

  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 80.2476;
  static const String osmTileUrl =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  LatLng _currentLocation =
      const LatLng(defaultLatitude, defaultLongitude);

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startSharing();
    _showLocationSharingNotification();
    _setupUIUpdates();
  }

  Future<void> _showLocationSharingNotification() async {
    await NotificationService().showLocationSharingNotification();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    // Don't stop sharing service - it continues in background
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await LocationService().requestPermissions();
  }

  void _startSharing() {
    _sharingService.startSharing();
  }

  void _setupUIUpdates() {
    // Update UI periodically based on service state
    _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        final position = _sharingService.currentPosition;
        if (position != null) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_currentLocation, 15.0);
        }
      }
    });
  }

  void _toggleSharing() {
    _sharingService.togglePause();
    setState(() {});
  }

  Future<void> _endShift() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppleColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppleRadius.xlAll),
        title: Text('End Shift?', style: AppleTypography.title3),
        content: Text(
          'Are you sure you want to end your shift?',
          style: AppleTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppleTypography.headline
                    .copyWith(color: AppleColors.systemGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('End Shift',
                style: AppleTypography.headline
                    .copyWith(color: AppleColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sharingService.stopSharing();
      await NotificationService().cancelLocationSharingNotification();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: osmTileUrl,
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppleColors.redGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppleColors.white, width: 4),
                        boxShadow: AppleShadows.floating,
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: AppleColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(AppleSpacing.base),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppleSpacing.base,
                    vertical: AppleSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppleColors.redGradient,
                    borderRadius: AppleRadius.lgAll,
                    boxShadow: AppleShadows.elevated,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppleColors.white),
                        onPressed: _endShift,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bus #${widget.busNumber}',
                              style: AppleTypography.headline.copyWith(
                                color: AppleColors.white,
                              ),
                            ),
                            Text(
                              widget.routeName,
                              style: AppleTypography.caption1.copyWith(
                                color: AppleColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PremiumStatusBadge(
                        text: _sharingService.isPaused ? 'Paused' : 'Active',
                        color: _sharingService.isPaused
                            ? AppleColors.warning
                            : AppleColors.success,
                      ),
                    ],
                  ),
                ),

                // Stats cards
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppleSpacing.base),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.speed_rounded,
                          label: 'Speed',
                          value: '${_sharingService.currentSpeed.toStringAsFixed(0)} km/h',
                        ),
                      ),
                      const SizedBox(width: AppleSpacing.md),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.access_time_rounded,
                          label: 'Elapsed',
                          value: _formatDuration(_sharingService.timeElapsed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom control panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppleSpacing.base),
                child: PremiumCard(
                  padding: const EdgeInsets.all(AppleSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status indicator
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _sharingService.isPaused
                                  ? AppleColors.warning
                                  : AppleColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppleSpacing.sm),
                          Text(
                            _sharingService.isPaused
                                ? 'Location sharing paused'
                                : 'Sharing location',
                            style: AppleTypography.subhead,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppleSpacing.lg),

                      // Control buttons
                      Row(
                        children: [
                          Expanded(
                            child: PremiumButton(
                              text: _sharingService.isPaused ? 'Resume' : 'Pause',
                              icon: _sharingService.isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              gradient: _sharingService.isPaused
                                  ? AppleColors.goldGradient
                                  : const LinearGradient(
                                      colors: [
                                        AppleColors.systemGray3,
                                        AppleColors.systemGray
                                      ],
                                    ),
                              onPressed: _toggleSharing,
                            ),
                          ),
                          const SizedBox(width: AppleSpacing.md),
                          Expanded(
                            child: PremiumOutlineButton(
                              text: 'End Shift',
                              icon: Icons.stop_rounded,
                              borderColor: AppleColors.error,
                              onPressed: _endShift,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppleSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: AppleColors.accentGold, size: 24),
          const SizedBox(height: AppleSpacing.sm),
          Text(label, style: AppleTypography.caption1),
          const SizedBox(height: AppleSpacing.xs),
          Text(value, style: AppleTypography.headline),
        ],
      ),
    );
  }
}
