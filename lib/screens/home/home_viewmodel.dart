import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();
  final NavigationService _navService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  doLogout() async {
    if ((await _dialogService.showConfirmationDialog(
            description: 'Are you sure you want to logout?'))!
        .confirmed) {
      await _firebaseAuth.logout();
      _navService.replaceWith(Routes.authView);
    }
  }

  doProfile() async {
    await _navService.navigateToProfileView();

    notifyListeners();
  }

  doHistory() async {
    _navService.navigateToHistoryView();
  }

  String? get userProfileImage {
    return _firebaseAuth.currentUser?.photoURL;
  }

  startJourney() async {
    _navService.navigateToJourneyView();
  }
}
