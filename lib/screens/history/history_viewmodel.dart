import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/models/journey.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:hopsta_demo/services/hopsta_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked/stacked.dart';

class HistoryViewModel extends BaseViewModel {
  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();
  final HopstaService _hopstaService = locator<HopstaService>();

  List<TrainJourney> journeys = [];

  handleStartup() async {
    await getJourneys();

    debugPrint('Journeys Retrieved: ${journeys.length}');

    setInitialised(true);
    notifyListeners();
  }

  Future getJourneys() async {
    var journeysData = await _firestoreService.getJourneyHistory();

    for (var journeyDoc in journeysData) {
      var journey =
          TrainJourney.fromFirestore(journeyDoc.data() as Map<String, dynamic>);
      await journey.getClosestStations();

      journeys.add(journey);
    }
  }

  Polyline getPolyline(List<LatLng> points) {
    return Polyline(
      strokeWidth: 5.0,
      points: points,
      color: Colors.blue,
    );
  }

  LatLng computeCentre(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    /* int n = points.length;

    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    } */
    latitude = points.first.latitude + points.last.latitude;
    longitude = points.first.longitude + points.last.longitude;

    return LatLng(latitude / 2, longitude / 2);
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    LatLngBounds bounds = LatLngBounds.fromPoints(points);
    bounds.pad(0.2);

    return bounds;
  }
}
