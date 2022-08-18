import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:hopsta_demo/services/hopsta_service.dart';
import 'package:location_distance_calculator/location_distance_calculator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class JourneyViewModel extends BaseViewModel {
  final HopstaService _hopstaService = locator<HopstaService>();
  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();
  final NavigationService _navService = locator<NavigationService>();

  int journeyStage = 0;
  GeoFirePoint? currentLocation;

  MapController mapController = MapController();
  bool mapReady = false;

  var closestStation = {};

  handleStartup() async {
    journeyStage = 1;

    await BackgroundGeolocation.requestPermission();
    currentLocation = await _hopstaService.currentLocation;

    mapController.onReady.then((value) {
      mapReady = true;
      notifyListeners();
    });

    if (currentLocation != null) await getClosestStation();

    setInitialised(true);

    notifyListeners();
  }

  getClosestStation() async {
    for (var station in _hopstaService.stations) {
      debugPrint('${station.name}');
      double distance;
      try {
        distance = await LocationDistanceCalculator().distanceBetween(
            currentLocation!.latitude,
            currentLocation!.longitude,
            station.location!.latitude,
            station.location!.longitude);
      } on PlatformException {
        distance = -1.0;
      }

      if (closestStation.isEmpty || closestStation['distance'] > distance) {
        closestStation = {'station': station, 'distance': distance};
      }
    }
  }

  beginJourney() async {
    journeyStage = 2;
    notifyListeners();

    await _hopstaService.maxBrightness();
  }

  passScanned() async {
    await _hopstaService.resetBrightness();

    journeyStage = 3;
    notifyListeners();
  }

  completeJourney() async {
    journeyStage = 4;
    notifyListeners();

    await _hopstaService.maxBrightness();
  }

  completePassScanned() async {
    await _hopstaService.resetBrightness();

    journeyStage = 5;
    notifyListeners();

    _navService.back();
  }
}
