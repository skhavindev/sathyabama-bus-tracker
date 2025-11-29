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

  Future<void> playNotificationSound() async {
    try {
      // Play a simple beep sound (you can add a custom sound file to assets)
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }
}
