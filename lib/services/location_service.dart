import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class HopstaLocationService extends ChangeNotifier {
  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();

  bool isTracking = false;
  bool trackingEnabled = false;
  String? journeyId;

  List<LatLng> positions = [];

  HopstaLocationService() {
    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      if (isTracking && journeyId != null) {
        debugPrint('[location] - $location');
        final text =
            'Location Update: Lat: ${location.coords.latitude} Lon: ${location.coords.longitude} for journey: $journeyId';
        print(text); // ignore: avoid_print
        await _firestoreService.setJourneyLocationPoint(
            journeyId ?? 'not-found',
            LatLng(location.coords.latitude, location.coords.longitude));

        positions
            .add(LatLng(location.coords.latitude, location.coords.longitude));

        notifyListeners();
        //sendNotification(text);
      }
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      debugPrint('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      debugPrint('[providerchange] - $event');
    });

    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 50.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE))
        .then((bg.State state) {
      trackingEnabled = true;
    });
  }

  startTracking(GeoFirePoint position) async {
    var newJourneyId = await _firestoreService
        .createJourney(LatLng(position.latitude, position.longitude));

    bg.BackgroundGeolocation.start().then((state) {
      if (state.enabled) {
        journeyId = newJourneyId;
        isTracking = true;
      }
    });
    /* await BackgroundLocationTrackerManager.startTracking().then((value) {
      journeyId = newJourneyId;
      isTracking = true;
    }); */
  }

  stopTracking() async {
    await _firestoreService.endJourney(journeyId!);
    bg.BackgroundGeolocation.stop().then((state) {
      if (state.enabled) {
        journeyId = null;
        isTracking = false;
      }
    });
    /* await BackgroundLocationTrackerManager.startTracking().then((value) {
      isTracking = false;
      journeyId = null;
    }); */
  }

  Future<bool> getTrackingStatus() async {
    await bg.BackgroundGeolocation.state
        .then((state) => isTracking = state.enabled);
    return isTracking;
  }

  Future<void> requestLocationPermission() async {
    final result = await Permission.locationAlways.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  /* Future<void> requestNotificationPermission() async {
    final result = await Permission.notification.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  } */

  /* void sendNotification(String text) {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    FlutterLocalNotificationsPlugin().initialize(settings,
        onSelectNotification: (data) async {
      print('ON CLICK $data'); // ignore: avoid_print
    });
    FlutterLocalNotificationsPlugin().show(
      Random().nextInt(9999),
      'Title',
      text,
      const NotificationDetails(
        android: AndroidNotificationDetails('test_notification', 'Test'),
        iOS: IOSNotificationDetails(),
      ),
    );
  } */
}
