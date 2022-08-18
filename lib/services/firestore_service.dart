import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/models/station.dart';
import 'package:latlong2/latlong.dart';

class HopstaFirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference _stationsCollectionReference =
      FirebaseFirestore.instance.collection("stations");

  GeoFlutterFire geo = GeoFlutterFire();

  HopstaFirestoreService() {
    debugPrint('Initialise the FirestoreService');
    if (kDebugMode) initMockData();
  }

  initMockData() async {
    debugPrint('Add mock data');
    var stationData = await _stationsCollectionReference.limit(1).get();
    if (stationData.docs.isEmpty) {
      List<TrainStation> mockData = [
        TrainStation(
            name: 'Maidstone East', location: LatLng(51.277603, 0.520078)),
        TrainStation(
            name: 'Maidstone West', location: LatLng(51.270738, 0.515704)),
        TrainStation(
            name: 'Maidstone Barracks', location: LatLng(51.277222, 0.514125)),
      ];

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var mockStation in mockData) {
        batch.set(
            _stationsCollectionReference.doc(), mockStation.toFirestore());
      }

      batch.commit();
    }
  }

  Future<List<DocumentSnapshot>> getStations(
      GeoFirePoint location, double radius) async {
    var geoRef = geo.collection(collectionRef: _stationsCollectionReference);
    var stations = geoRef.within(
        center: location, radius: radius, field: 'location', strictMode: false);

    return await stations.first.onError((error, stackTrace) => []);
  }
}
