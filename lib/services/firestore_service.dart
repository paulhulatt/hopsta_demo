import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/models/station.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

class HopstaFirestoreService {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();

  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference _stationsCollectionReference =
      FirebaseFirestore.instance.collection("stations");

  final CollectionReference _journeysCollectionReference =
      FirebaseFirestore.instance.collection("journeys");

  GeoFlutterFire geo = GeoFlutterFire();

  HopstaFirestoreService() {
    debugPrint('Initialise the FirestoreService');
    if (kDebugMode) initMockData();
  }

  initMockData() async {
    List<TrainStation> mockData = [
      TrainStation(
          name: 'Maidstone East', location: LatLng(51.277603, 0.520078)),
      TrainStation(
          name: 'Maidstone West', location: LatLng(51.270738, 0.515704)),
      TrainStation(
          name: 'Maidstone Barracks', location: LatLng(51.277222, 0.514125)),
      TrainStation(name: 'Aylesford', location: LatLng(51.301449, 0.466321)),
    ];
    debugPrint('Add mock data');
    var stationData = await _stationsCollectionReference.get();
    if (stationData.docs.length < mockData.length) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var mockStation in mockData.skipWhile(
          (value) => mockData.indexOf(value) < stationData.docs.length)) {
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

  Future<String> createJourney(LatLng position) async {
    var doc = _journeysCollectionReference.doc();
    await doc.set({
      'user': _firebaseAuth.currentUser?.uid,
      'started': FieldValue.serverTimestamp(),
      'positions': [
        {
          'lat': position.latitude,
          'lon': position.longitude,
          'date': Timestamp
              .now() // Needs to be replaced with a server based time or ensure an offset is available for proper journey calculation
        }
      ]
    });
    return doc.id;
  }

  setJourneyLocationPoint(String journeyId, LatLng position) async {
    _journeysCollectionReference.doc(journeyId).update({
      'positions': FieldValue.arrayUnion([
        {
          'lat': position.latitude,
          'lon': position.longitude,
          'date': Timestamp.now()
        }
      ])
    });
  }

  endJourney(String journeyId, {LatLng? position}) async {
    await _journeysCollectionReference.doc(journeyId).update({
      'ended': FieldValue.serverTimestamp(),
      /* 'positions': FieldValue.arrayUnion([
        {
          'lat': position.latitude,
          'lon': position.longitude,
          'date': Timestamp.now()
        }
      ]) */
    });
  }

  Future<List<DocumentSnapshot>> getJourneyHistory() async {
    var journeys = await _journeysCollectionReference
        .where('user', isEqualTo: _firebaseAuth.currentUser?.uid)
        .orderBy('started', descending: true)
        .get();

    return journeys.docs;
  }
}
