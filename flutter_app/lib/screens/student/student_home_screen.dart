import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/apple_theme.dart';
import '../../config/theme_manager.dart';
import '../../widgets/premium_widgets.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../models/bus_location.dart';
import '../../models/tracked_bus.dart';
import '../../models/pinned_bus.dart';
import '../settings_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<TrackedBus> _trackedBuses = [];
  List<PinnedBus> _pinnedBuses = [];
  String? _followingBus;
  String _userName = 'Student';
  final StorageService _storageService = StorageService();
  List<BusLocation> _activeBuses = [];
  List<BusLocation> _filteredBuses = [];
  Timer? _refreshTimer;
  Timer? _proximityTimer;
  Position? _currentPosition;
  final Set<String> _notifiedBuses = {};
  final Set<String> _nearNotifiedBuses = {};

  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 80.2476;
  static const double defaultZoom = 13.0;
  static const String osmTileUrl =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Student's current location (from device GPS)
  LatLng _studentLocation = const LatLng(12.9710, 80.2470);

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadBuses();
    _loadTrackedBuses();
    _loadPinnedBuses();
    _getCurrentLocation();
    _loadUserProfile();
    _startAutoRefresh();
    _startProximityChecking();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _refreshTimer?.cancel();
    _proximityTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _storageService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _userName = profile.name;
      });
    }
  }

  Future<void> _loadBuses() async {
    try {
      // Get active buses for map display (buses currently sharing location)
      final activeBuses = await ApiService().getActiveBuses();
      
      // Get all routes from database
      final allRoutes = await ApiService().getAllRoutes();
      
      // Convert all routes to BusLocation format
      final allBuses = allRoutes.map((route) {
        final busNumber = route['busNumber'] ?? '';
        final isSharingLocation = route['isSharingLocation'] == true;
        
        print('📍 Bus $busNumber - isSharingLocation: $isSharingLocation');
        
        // Check if this bus is currently active (sharing location)
        final activeBus = activeBuses.firstWhere(
          (b) => b.busNumber == busNumber,
          orElse: () => BusLocation(
            busNumber: '',
            route: '',
            latitude: 0,
            longitude: 0,
            speed: 0,
            lastUpdate: DateTime.now(),
            status: 'offline',
          ),
        );
        
        // If bus is actively sharing location, use its real data
        if (activeBus.busNumber.isNotEmpty) {
          print('✅ Bus $busNumber is active with location data');
          return BusLocation(
            busNumber: busNumber,
            route: route['routeName'] ?? '',
            latitude: activeBus.latitude,
            longitude: activeBus.longitude,
            speed: activeBus.speed,
            lastUpdate: activeBus.lastUpdate,
            status: 'active',
          );
        } else {
          // Bus exists in database but not sharing location
          print('❌ Bus $busNumber is offline');
          return BusLocation(
            busNumber: busNumber,
            route: route['routeName'] ?? '',
            latitude: 12.9716, // Default location (won't show on map)
            longitude: 80.2476,
            speed: 0,
            lastUpdate: DateTime.now(),
            status: 'offline',
          );
        }
      }).toList();
      
      if (mounted) {
        setState(() {
          _activeBuses = allBuses;
          _filteredBuses = allBuses;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load buses: $e')),
        );
      }
    }
  }

  Future<void> _loadTrackedBuses() async {
    final buses = await _storageService.getTrackedBuses();
    setState(() => _trackedBuses = buses);
  }

  Future<void> _loadPinnedBuses() async {
    final buses = await _storageService.getPinnedBuses();
    setState(() => _pinnedBuses = buses);
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadBuses();
    });
  }

  void _startProximityChecking() {
    _proximityTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _currentPosition = await LocationService().getCurrentPosition();
      if (_currentPosition == null) return;

      // Check tracked buses for proximity notifications
      for (final trackedBus in _trackedBuses) {
        final bus = _activeBuses.firstWhere(
          (b) => b.busNumber == trackedBus.busNumber,
          orElse: () => BusLocation(
            busNumber: '',
            route: '',
            latitude: 0,
            longitude: 0,
            speed: 0,
            lastUpdate: DateTime.now(),
            status: 'offline',
          ),
        );

        // Only process if bus is found and actively sharing location
        if (bus.busNumber.isNotEmpty && bus.status == 'active') {
          final distance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            bus.latitude,
            bus.longitude,
          );

          // Proximity notification (within custom radius)
          if (distance <= trackedBus.radiusMeters &&
              !_notifiedBuses.contains(bus.busNumber)) {
            await NotificationService().showBusProximityNotification(
              bus.busNumber,
              distance.round(),
            );
            _notifiedBuses.add(bus.busNumber);
          } else if (distance > trackedBus.radiusMeters) {
            _notifiedBuses.remove(bus.busNumber);
          }
        } else {
          // Bus is offline, clear notification states
          _notifiedBuses.remove(bus.busNumber);
          _nearNotifiedBuses.remove(bus.busNumber);
        }
      }
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  void _filterBuses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBuses = _activeBuses;
      } else {
        final searchLower = query.toLowerCase();
        _filteredBuses = _activeBuses.where((bus) {
          return bus.busNumber.toLowerCase().contains(searchLower) ||
              bus.route.toLowerCase().contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _toggleBusTracking(String busNumber) async {
    final isTracked = _trackedBuses.any((b) => b.busNumber == busNumber);

    if (isTracked) {
      await _storageService.removeTrackedBus(busNumber);
      setState(() => _trackedBuses.removeWhere((b) => b.busNumber == busNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stopped tracking Bus $busNumber')),
        );
      }
    } else {
      final radius = await _showRadiusSelector();
      if (radius != null) {
        final trackedBus = TrackedBus(
          busNumber: busNumber,
          radiusMeters: radius,
          addedAt: DateTime.now(),
        );
        await _storageService.addTrackedBus(trackedBus);
        setState(() => _trackedBuses.add(trackedBus));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Tracking Bus $busNumber - will notify within ${radius}m')),
          );
        }
      }
    }
  }

  Future<void> _toggleBusPin(String busNumber, String routeName) async {
    final isPinned = _pinnedBuses.any((b) => b.busNumber == busNumber);

    if (isPinned) {
      await _storageService.removePinnedBus(busNumber);
      setState(() => _pinnedBuses.removeWhere((b) => b.busNumber == busNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unpinned Bus $busNumber')),
        );
      }
    } else {
      final pinnedBus = PinnedBus(
        busNumber: busNumber,
        routeName: routeName,
        pinnedAt: DateTime.now(),
      );
      await _storageService.addPinnedBus(pinnedBus);
      setState(() => _pinnedBuses.add(pinnedBus));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pinned Bus $busNumber to favorites')),
        );
      }
    }
  }

  Future<void> _notifyBusNear(String busNumber, String routeName) async {
    // Check if already tracking this bus
    final isAlreadyTracked = _trackedBuses.any((b) => b.busNumber == busNumber);
    
    if (isAlreadyTracked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already tracking Bus $busNumber. You will be notified when it\'s near.')),
        );
      }
      return;
    }

    // Show radius selector
    final radius = await _showRadiusSelector();
    if (radius != null) {
      final trackedBus = TrackedBus(
        busNumber: busNumber,
        radiusMeters: radius,
        addedAt: DateTime.now(),
      );
      await _storageService.addTrackedBus(trackedBus);
      setState(() => _trackedBuses.add(trackedBus));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You will be notified when Bus $busNumber is within ${radius}m'),
          ),
        );
      }
    }
  }

  Future<int?> _showRadiusSelector() async {
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppleColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppleRadius.xlAll),
        title: Text('Select Notification Radius', style: AppleTypography.title3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [100, 300, 500, 700].map((radius) {
            return ListTile(
              title: Text('${radius}m', style: AppleTypography.body),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context, radius),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _studentLocation = LatLng(position.latitude, position.longitude);
        });

        // Center map on student location
        _mapController.move(_studentLocation, 15.0);
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _centerOnBus(String busNumber) {
    final bus = _filteredBuses.firstWhere(
      (b) => b.busNumber == busNumber,
      orElse: () => BusLocation(
        busNumber: '',
        route: '',
        latitude: defaultLatitude,
        longitude: defaultLongitude,
        speed: 0,
        lastUpdate: DateTime.now(),
        status: 'offline',
      ),
    );
    if (bus.busNumber.isNotEmpty) {
      _mapController.move(LatLng(bus.latitude, bus.longitude), 15.0);
      setState(() => _followingBus = busNumber);
    }
  }

  void _centerOnStudent() {
    _mapController.move(_studentLocation, 15.0);
  }

  void _showRoutesMenu() {
    PremiumBottomSheet.show(
      context: context,
      height: MediaQuery.of(context).size.height * 0.7,
      child: _RoutesMenuContent(
        busRoutes: _filteredBuses,
        pinnedBuses: _pinnedBuses,
        onBusTap: (bus) {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            _showBusDetails(bus);
          });
        },
        onTogglePin: (busNumber, routeName) {
          _toggleBusPin(busNumber, routeName);
        },
      ),
    );
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;
    
    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(defaultLatitude, defaultLongitude),
              initialZoom: defaultZoom,
              maxZoom: 18.0,
              minZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : osmTileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.sathyabama_bus_tracker',
                additionalOptions: const {
                  'attribution': '© OpenStreetMap contributors © CARTO',
                },
              ),
              MarkerLayer(
                markers: [
                  // Student location marker
                  Marker(
                    point: _studentLocation,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppleColors.goldAccentGradient,
                        border: Border.all(color: AppleColors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppleColors.accentGold.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: AppleColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Bus markers - only show buses that are actively sharing location
                  ..._filteredBuses.where((bus) => bus.status == 'active').map((bus) {
                    final isTracked =
                        _trackedBuses.any((t) => t.busNumber == bus.busNumber);
                    return Marker(
                      point: LatLng(bus.latitude, bus.longitude),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showBusDetails(bus),
                        child: _BusMarker(
                          busNumber: bus.busNumber,
                          isMoving: bus.status == 'active',
                          isTracked: isTracked,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          // Glass header bar (truly flush with top, rounder bottom)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppleRadius.xl),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        AppleSpacing.base,
                        MediaQuery.of(context).padding.top + AppleSpacing.sm,
                        AppleSpacing.base,
                        AppleSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeManager.darkPrimaryColor.withValues(alpha: 0.98),
                            themeManager.lightPrimaryColor.withValues(alpha: 0.98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppleColors.accentGold.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeManager.darkPrimaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: AppleColors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Track Buses',
                                  style: AppleTypography.headline.copyWith(
                                    color: AppleColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Welcome $_userName',
                                  style: AppleTypography.caption1.copyWith(
                                    color: AppleColors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppleColors.accentGold.withValues(alpha: 0.2),
                              borderRadius: AppleRadius.smAll,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.route_rounded,
                                  color: AppleColors.accentGold),
                              onPressed: _showRoutesMenu,
                            ),
                          ),
                          const SizedBox(width: AppleSpacing.xs),
                          IconButton(
                            icon: const Icon(Icons.settings_rounded,
                                color: AppleColors.white),
                            onPressed: _showSettings,
                          ),
                          const SizedBox(width: AppleSpacing.xs),
                          IconButton(
                            icon: const Icon(Icons.my_location_rounded,
                                color: AppleColors.white),
                            onPressed: _centerOnStudent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search bar
                Padding(
                padding: const EdgeInsets.all(AppleSpacing.base),
                child: ClipRRect(
                  borderRadius: AppleRadius.mdAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : AppleColors.white.withValues(alpha: 0.4),
                        borderRadius: AppleRadius.mdAll,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppleColors.white.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppleTypography.body.copyWith(
                          color: isDark ? AppleColors.white : AppleColors.labelPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by bus or route...',
                          hintStyle: AppleTypography.body.copyWith(
                            color: isDark
                                ? AppleColors.white.withValues(alpha: 0.6)
                                : AppleColors.systemGray,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark
                                ? AppleColors.white.withValues(alpha: 0.7)
                                : AppleColors.systemGray,
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppleColors.systemGray,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _searchController.clear());
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppleSpacing.base,
                            vertical: AppleSpacing.md,
                          ),
                        ),
                        onChanged: _filterBuses,
                      ),
                    ),
                  ),
                ),
              ),

              // Tracked buses switcher
              if (_trackedBuses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppleSpacing.base),
                  child: ClipRRect(
                    borderRadius: AppleRadius.mdAll,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(AppleSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppleColors.white.withValues(alpha: 0.25),
                          borderRadius: AppleRadius.mdAll,
                          border: Border.all(
                            color: AppleColors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: AppleColors.goldAccentGradient,
                                    borderRadius: AppleRadius.smAll,
                                  ),
                                  child: const Icon(Icons.gps_fixed_rounded,
                                      color: AppleColors.white, size: 14),
                                ),
                                const SizedBox(width: AppleSpacing.xs),
                                Text('Tracking',
                                    style: AppleTypography.caption1.copyWith(
                                        color: AppleColors.labelPrimary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: AppleSpacing.xs),
                            SizedBox(
                              height: 36,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _trackedBuses.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppleSpacing.sm),
                                itemBuilder: (context, index) {
                                  final trackedBus = _trackedBuses[index];
                                  return PremiumChip(
                                    label: 'Bus ${trackedBus.busNumber}',
                                    icon: Icons.notifications_active_rounded,
                                    isSelected: _followingBus == trackedBus.busNumber,
                                    onTap: () => _centerOnBus(trackedBus.busNumber),
                                    onClose: () => _toggleBusTracking(trackedBus.busNumber),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Built by signature (bottom left in glass)
          Positioned(
            bottom: AppleSpacing.base,
            left: AppleSpacing.base,
            child: ClipRRect(
              borderRadius: AppleRadius.mdAll,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppleSpacing.md,
                    vertical: AppleSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppleColors.white.withValues(alpha: 0.25),
                    borderRadius: AppleRadius.mdAll,
                    border: Border.all(
                      color: AppleColors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'by ',
                        style: AppleTypography.caption1.copyWith(
                          fontSize: 11,
                          color: AppleColors.systemGray,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppleColors.goldAccentGradient.createShader(bounds),
                        child: const Text(
                          'S Khavin',
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'AmericanSignature',
                            color: AppleColors.white,
                          ),
                        ),
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

  void _showBusDetails(BusLocation bus) {
    PremiumBottomSheet.show(
      context: context,
      child: _BusDetailsContent(
        bus: bus,
        isTracked: _trackedBuses.any((t) => t.busNumber == bus.busNumber),
        onToggleTrack: () {
          _toggleBusTracking(bus.busNumber);
          Navigator.pop(context);
        },
        onNotifyNear: () {
          _notifyBusNear(bus.busNumber, bus.route);
          Navigator.pop(context);
        },
      ),
    );
  }
}


class _BusMarker extends StatelessWidget {
  final String busNumber;
  final bool isMoving;
  final bool isTracked;

  const _BusMarker({
    required this.busNumber,
    required this.isMoving,
    required this.isTracked,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: isMoving
                ? AppleColors.redGradient
                : const LinearGradient(
                    colors: [AppleColors.systemGray3, AppleColors.systemGray],
                  ),
            shape: BoxShape.circle,
            border: Border.all(color: AppleColors.white, width: 3),
            boxShadow: AppleShadows.elevated,
          ),
          child: Center(
            child: Text(
              busNumber,
              style: AppleTypography.caption1.copyWith(
                color: AppleColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (isTracked)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: AppleColors.goldAccentGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppleColors.white, width: 2),
              ),
              child: const Icon(
                Icons.gps_fixed_rounded,
                size: 10,
                color: AppleColors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _BusDetailsContent extends StatelessWidget {
  final BusLocation bus;
  final bool isTracked;
  final VoidCallback onToggleTrack;
  final VoidCallback onNotifyNear;

  const _BusDetailsContent({
    required this.bus,
    required this.isTracked,
    required this.onToggleTrack,
    required this.onNotifyNear,
  });

  @override
  Widget build(BuildContext context) {
    final isMoving = bus.status == 'active';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppleSpacing.screenHorizontal,
        0,
        AppleSpacing.screenHorizontal,
        AppleSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppleColors.redGradient,
                  borderRadius: AppleRadius.mdAll,
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: AppleColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppleSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bus #${bus.busNumber}', style: AppleTypography.title3),
                    const SizedBox(height: AppleSpacing.xs),
                    Text(bus.route, style: AppleTypography.callout),
                  ],
                ),
              ),
              PremiumStatusBadge(
                text: isMoving ? 'Moving' : 'Stopped',
                color: isMoving ? AppleColors.success : AppleColors.warning,
              ),
            ],
          ),

          const SizedBox(height: AppleSpacing.lg),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.speed_rounded,
                  label: 'Speed',
                  value: '${bus.speed.toStringAsFixed(0)} km/h',
                ),
              ),
              const SizedBox(width: AppleSpacing.base),
              Expanded(
                child: _StatItem(
                  icon: Icons.access_time_rounded,
                  label: 'Last Update',
                  value: _formatTime(bus.lastUpdate),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppleSpacing.xl),

          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PremiumButton(
                  text: isTracked ? 'Stop Tracking' : 'Track Bus',
                  icon: isTracked
                      ? Icons.location_off_rounded
                      : Icons.my_location_rounded,
                  gradient: isTracked
                      ? const LinearGradient(
                          colors: [
                            AppleColors.systemGray3,
                            AppleColors.systemGray
                          ],
                        )
                      : AppleColors.goldAccentGradient,
                  onPressed: onToggleTrack,
                ),
              ),
              const SizedBox(width: AppleSpacing.sm),
              // Bell icon for "notify when near" (quick track)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isTracked ? AppleColors.systemGray : AppleColors.accentGold,
                    width: 2,
                  ),
                  borderRadius: AppleRadius.mdAll,
                ),
                child: IconButton(
                  icon: Icon(
                    isTracked
                        ? Icons.notifications_active
                        : Icons.notifications_active_rounded,
                    color: isTracked ? AppleColors.systemGray : AppleColors.accentGold,
                  ),
                  onPressed: isTracked ? null : onNotifyNear,
                  tooltip: isTracked ? 'Already tracking' : 'Set notification',
                ),
              ),
              const SizedBox(width: AppleSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppleColors.systemGray, width: 2),
                  borderRadius: AppleRadius.mdAll,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded,
                      color: AppleColors.systemGray),
                  onPressed: () {},
                  tooltip: 'Share',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppleSpacing.md),
      backgroundColor: AppleColors.systemGray6,
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

class _RoutesMenuContent extends StatefulWidget {
  final List<BusLocation> busRoutes;
  final List<PinnedBus> pinnedBuses;
  final Function(BusLocation) onBusTap;
  final Function(String, String) onTogglePin;

  const _RoutesMenuContent({
    required this.busRoutes,
    required this.pinnedBuses,
    required this.onBusTap,
    required this.onTogglePin,
  });

  @override
  State<_RoutesMenuContent> createState() => _RoutesMenuContentState();
}

class _RoutesMenuContentState extends State<_RoutesMenuContent> {
  final TextEditingController _searchController = TextEditingController();
  List<BusLocation> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = widget.busRoutes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRoutes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoutes = widget.busRoutes;
      } else {
        _filteredRoutes = widget.busRoutes.where((bus) {
          final searchLower = query.toLowerCase();
          return bus.busNumber.toLowerCase().contains(searchLower) ||
              bus.route.toLowerCase().contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppleSpacing.screenHorizontal,
        0,
        AppleSpacing.screenHorizontal,
        AppleSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppleSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppleColors.goldAccentGradient,
                  borderRadius: AppleRadius.smAll,
                ),
                child: const Icon(Icons.route_rounded,
                    color: AppleColors.white, size: 24),
              ),
              const SizedBox(width: AppleSpacing.md),
              Text('All Routes', style: AppleTypography.title2),
            ],
          ),
          const SizedBox(height: AppleSpacing.md),
          Text(
            'View all available bus routes and their details',
            style: AppleTypography.callout,
          ),
          const SizedBox(height: AppleSpacing.lg),
          
          // Search field
          ClipRRect(
            borderRadius: AppleRadius.mdAll,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppleColors.systemGray6.withValues(alpha: 0.8),
                  borderRadius: AppleRadius.mdAll,
                  border: Border.all(
                    color: AppleColors.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppleTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Search routes, buses, drivers...',
                    hintStyle: AppleTypography.body.copyWith(
                      color: AppleColors.systemGray,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppleColors.accentGold,
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppleColors.systemGray,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterRoutes('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppleSpacing.base,
                      vertical: AppleSpacing.md,
                    ),
                  ),
                  onChanged: _filterRoutes,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppleSpacing.lg),
          Expanded(
            child: _filteredRoutes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppleColors.systemGray),
                        const SizedBox(height: AppleSpacing.md),
                        Text('No routes found',
                            style: AppleTypography.headline),
                        Text('Try a different search term',
                            style: AppleTypography.callout),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredRoutes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppleSpacing.md),
                    itemBuilder: (context, index) {
                      final bus = _filteredRoutes[index];
                      final isPinned = widget.pinnedBuses
                          .any((p) => p.busNumber == bus.busNumber);
                      final isSharing = bus.status == 'active';
                      
                      return PremiumCard(
                        padding: const EdgeInsets.all(AppleSpacing.base),
                        onTap: () => widget.onBusTap(bus),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: isSharing 
                                        ? AppleColors.redGradient
                                        : const LinearGradient(
                                            colors: [AppleColors.systemGray3, AppleColors.systemGray],
                                          ),
                                    borderRadius: AppleRadius.smAll,
                                    border: Border.all(
                                      color: isSharing
                                          ? AppleColors.accentGold.withValues(alpha: 0.3)
                                          : AppleColors.systemGray.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      bus.busNumber,
                                      style: AppleTypography.caption1.copyWith(
                                        color: AppleColors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppleSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(bus.route,
                                          style: AppleTypography.headline),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: isSharing 
                                                  ? AppleColors.success 
                                                  : AppleColors.systemGray,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: AppleSpacing.xs),
                                          Text(
                                            isSharing 
                                                ? 'Sharing Location • ${bus.speed.toStringAsFixed(0)} km/h'
                                                : 'Not Sharing Location',
                                            style: AppleTypography.caption1.copyWith(
                                              color: isSharing 
                                                  ? AppleColors.success 
                                                  : AppleColors.systemGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Pin button
                                IconButton(
                                  icon: Icon(
                                    isPinned
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    color: isPinned
                                        ? AppleColors.accentGold
                                        : AppleColors.systemGray,
                                  ),
                                  onPressed: () {
                                    widget.onTogglePin(bus.busNumber, bus.route);
                                  },
                                  tooltip: isPinned ? 'Unpin' : 'Pin to favorites',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
