import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/models/station.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

/// Provides all database functionality
class HopstaFirestoreService {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();

  // Setup document references
  final CollectionReference _stationsCollectionReference = FirebaseFirestore
      .instance
      .collection((kDebugMode) ? "stations_test" : "stations");
  final CollectionReference _journeysCollectionReference = FirebaseFirestore
      .instance
      .collection((kDebugMode) ? "journeys_test" : "journeys");

  GeoFlutterFire geo = GeoFlutterFire();

  HopstaFirestoreService() {
    debugPrint('Initialise the FirestoreService');
    if (kDebugMode) initMockData();
  }

  /// As we're in Debug mode, check to see if the number of stations in the mock data below is larger than the database and upload any that are missing
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

  /// Get a list of stations within a [radius]km radius of [location]
  Future<List<DocumentSnapshot>> getStations(
      GeoFirePoint location, double radius) async {
    try {
      var geoRef = geo.collection(collectionRef: _stationsCollectionReference);
      var stations = geoRef.within(
          center: location,
          radius: radius,
          field: 'location',
          strictMode: false);

      return await stations.first.onError((error, stackTrace) => []);
    } on Exception catch (e) {
      return [];
    }
  }

  /// Create a new Journey in the database and add the starting [position]
  Future<String?> createJourney(LatLng position) async {
    try {
      // Creates a new document reference with an auto-generated ID
      var doc = _journeysCollectionReference.doc();
      await doc.set({
        'user': _firebaseAuth.currentUser?.uid,
        'started': FieldValue.serverTimestamp(),
        'positions': [
          {
            'lat': position.latitude,
            'lon': position.longitude,
            'date': Timestamp
                .now() // Ideally should be replaced with a server based time or ensure an offset is available for proper journey calculation
          }
        ]
      });
      return doc.id;
    } on Exception catch (e) {
      return null;
    }
  }

  /// Save the supplied [position] to the current Journey
  setJourneyLocationPoint(String journeyId, LatLng position) async {
    try {
      _journeysCollectionReference.doc(journeyId).update({
        'positions': FieldValue.arrayUnion([
          {
            'lat': position.latitude,
            'lon': position.longitude,
            'date': Timestamp.now()
          }
        ])
      });
    } on Exception catch (e) {
      return;
    }
  }

  /// Update the current Journey with an [ended] date using FieldValue.serverTimestamp()
  endJourney(String journeyId, {LatLng? position}) async {
    try {
      await _journeysCollectionReference.doc(journeyId).update({
        'ended': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      return;
    }
  }

  /// Get the current users Journey History
  Future<List<DocumentSnapshot>> getJourneyHistory() async {
    try {
      var journeys = await _journeysCollectionReference
          .where('user', isEqualTo: _firebaseAuth.currentUser?.uid)
          .orderBy('started', descending: true)
          .get();

      return journeys.docs;
    } on Exception catch (e) {
      return [];
    }
  }
}
