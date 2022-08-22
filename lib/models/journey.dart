import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/services/hopsta_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_distance_calculator/location_distance_calculator.dart';

class TrainJourney {
  final DateTime? started;
  final DateTime? ended;
  String? startStation;
  String? endStation;
  final List<LatLng>? positions;
  Polyline? polyline;

  TrainJourney(
      {this.started,
      this.ended,
      this.positions,
      this.startStation,
      this.endStation,
      this.polyline});

  final HopstaService _hopstaService = locator<HopstaService>();

  factory TrainJourney.fromFirestore(Map<String, dynamic> map) {
    List<dynamic> _positions = map['positions'] ?? [];
    return TrainJourney(
        started: (map['started'] != null)
            ? DateTime.parse(map['started'].toDate().toString())
            : null,
        ended: (map['ended'] != null)
            ? DateTime.parse(map['ended'].toDate().toString())
            : null,
        positions: _positions.map((e) => LatLng(e['lat'], e['lon'])).toList());
  }

  getClosestStations() async {
    if ((positions ?? []).isNotEmpty) {
      if (positions != null && positions!.length > 2) {
        startStation = await _getClosestStation(positions!.first);
        endStation = await _getClosestStation(positions!.last);
      }
      polyline = Polyline(
        strokeWidth: 5.0,
        points: positions!,
        color: Colors.blue,
      );
    }
  }

  _getClosestStation(LatLng position) async {
    var closestStation = {};

    for (var station in _hopstaService.stations) {
      debugPrint('${station.name}');
      double distance;
      try {
        distance = await LocationDistanceCalculator().distanceBetween(
            position.latitude,
            position.longitude,
            station.location!.latitude,
            station.location!.longitude);
      } on PlatformException {
        distance = -1.0;
      }

      if (closestStation.isEmpty || closestStation['distance'] > distance) {
        closestStation = {'station': station, 'distance': distance};
      }
    }

    return closestStation['station'].name;
  }
}
