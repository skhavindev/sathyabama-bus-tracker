import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  Future<bool> requestPermissions() async {
    final android = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return android ?? false;
  }

  Future<void> showBusProximityNotification(
      String busNumber, int distance) async {
    const androidDetails = AndroidNotificationDetails(
      'bus_proximity',
      'Bus Proximity Alerts',
      channelDescription: 'Notifications when your bus is nearby',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      busNumber.hashCode,
      'Bus $busNumber is nearby!',
      'Your bus is ${distance}m away',
      details,
    );

    await playNotificationSound();
  }

  Future<void> showLocationSharingNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'location_sharing',
      'Location Sharing',
      channelDescription: 'Notification when location sharing is active',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Makes it persistent
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      999, // Fixed ID for location sharing notification
      'Location Sharing Active',
      'Your location is being shared with students',
      details,
    );
  }

  Future<void> cancelLocationSharingNotification() async {
    await _notifications.cancel(999);
  }

  Future<void> showBusNearNotification(String busNumber, String routeName) async {
    const androidDetails = AndroidNotificationDetails(
      'bus_near',
      'Bus Near Alerts',
      channelDescription: 'Notifications when tracked bus is near',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      busNumber.hashCode + 1000, // Different ID from proximity
      'Bus $busNumber is near!',
      '$routeName is approaching your location',
      details,
    );

    await playNotificationSound();
  }

  Future<void> playNotificationSound() async {
    try {
      // Play a simple beep sound (you can add a custom sound file to assets)
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }
}
