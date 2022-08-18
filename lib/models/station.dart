import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:latlong2/latlong.dart';

class TrainStation {
  String? id;
  String? name;
  LatLng? location;

  TrainStation({this.id, this.name, this.location});

  final HopstaFirestoreService _firestoreService =
      locator<HopstaFirestoreService>();

  Map<String, dynamic> toFirestore() {
    GeoFirePoint _stationLocation = _firestoreService.geo
        .point(latitude: location!.latitude, longitude: location!.longitude);

    return {'name': name, 'location': _stationLocation.data};
  }

  factory TrainStation.fromFirestore(Map<String, dynamic> map) {
    var geoPoint = map['location']['geopoint'] as GeoPoint;
    return TrainStation(
        name: map['name'],
        location: LatLng(geoPoint.latitude, geoPoint.longitude));
  }
}
