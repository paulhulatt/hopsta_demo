// Provides specific service functionality for the Hopsta app accessible across all views

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/models/station.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:screen_brightness/screen_brightness.dart';

class HopstaService {
  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();

  List<TrainStation> stations = [];

  bool initialised = false;

  HopstaService() {
    debugPrint('Init HopstaService');
    initService();
  }

  Future<GeoFirePoint> get currentLocation async {
    var currentLoc = await BackgroundGeolocation.getCurrentPosition();
    return _firestoreService.geo.point(
        latitude: currentLoc.coords.latitude,
        longitude: currentLoc.coords.longitude);
  }

  initService() async {
    await BackgroundGeolocation.requestPermission();

    var currentLoc = await BackgroundGeolocation.getCurrentPosition();
    var geoPoint = _firestoreService.geo.point(
        latitude: currentLoc.coords.latitude,
        longitude: currentLoc.coords.longitude);

    var stationDocs = await _firestoreService.getStations(geoPoint, 5);
    for (var stationDoc in stationDocs) {
      stations.add(TrainStation.fromFirestore(
          stationDoc.data() as Map<String, dynamic>));
    }

    debugPrint('Loaded Stations: ${stations.length}');

    initialised = true;
  }

  Future<void> maxBrightness() async {
    try {
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }

  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      print(e);
      throw 'Failed to reset brightness';
    }
  }
}
