import 'package:hopsta_demo/screens/auth/auth_view.dart';
import 'package:hopsta_demo/screens/entry.dart';
import 'package:hopsta_demo/screens/history/history_view.dart';
import 'package:hopsta_demo/screens/home/home_view.dart';
import 'package:hopsta_demo/screens/journey/journey_view.dart';
import 'package:hopsta_demo/screens/profile/profile_view.dart';
import 'package:hopsta_demo/services/firestore_service.dart';
import 'package:hopsta_demo/services/hopsta_service.dart';
import 'package:hopsta_demo/services/location_service.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import '../services/shared_preferences_service.dart';

@StackedApp(routes: [
  MaterialRoute(page: EntryView, initial: true),
  MaterialRoute(page: AuthView),
  MaterialRoute(page: HomeView),
  MaterialRoute(page: JourneyView),
  MaterialRoute(page: HistoryView),
  MaterialRoute(page: ProfileView)
], dependencies: [
  Singleton(classType: NavigationService),
  Singleton(classType: DialogService),
  Singleton(classType: FirebaseAuthenticationService),
  Singleton(classType: HopstaFirestoreService),
  Singleton(classType: HopstaLocationService),
  Singleton(classType: HopstaService),
  Presolve(
    classType: SharedPreferencesService,
    presolveUsing: SharedPreferencesService.getInstance,
  ),
])
class App {
  /** This class has no puporse besides housing the annotation that generates the required functionality **/
}
