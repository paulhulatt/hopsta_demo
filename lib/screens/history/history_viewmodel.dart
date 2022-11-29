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

/// Provides data & methods for HistoryView
class HistoryViewModel extends BaseViewModel {
  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();
  final HopstaService _hopstaService = locator<HopstaService>();

  List<TrainJourney> journeys = [];

  /// Startup method to be called by onModelReady
  handleStartup() async {
    await getJourneys();

    debugPrint('Journeys Retrieved: ${journeys.length}');

    setInitialised(true);
    notifyListeners();
  }

  /// Retrieve this users journeys from the database
  Future getJourneys() async {
    var journeysData = await _firestoreService.getJourneyHistory();

    for (var journeyDoc in journeysData) {
      var journey =
          TrainJourney.fromFirestore(journeyDoc.data() as Map<String, dynamic>);
      await journey.getClosestStations();

      journeys.add(journey);
    }
  }

  /// Generate a Polyline for a set of LatLng points
  ///
  /// [points] should be a list of LatLng
  Polyline getPolyline(List<LatLng> points) {
    return Polyline(
      strokeWidth: 5.0,
      points: points,
      color: Colors.blue,
    );
  }

  /// Calculate the centre point between the first & last items in a List of LatLng
  ///
  /// [points] should be a List of LatLng
  LatLng computeCentre(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;

    latitude = points.first.latitude + points.last.latitude;
    longitude = points.first.longitude + points.last.longitude;

    return LatLng(latitude / 2, longitude / 2);
  }

  /// Calculate the bounding box for a list of locations and add padding
  ///
  /// Optional [pad] can be supplied, otherwise defaults to 0.2
  LatLngBounds getLatLngBounds(List<LatLng> points, {double pad = 0.2}) {
    LatLngBounds bounds = LatLngBounds.fromPoints(points);
    bounds.pad(pad);

    return bounds;
  }
}
