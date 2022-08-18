import 'package:flutter/material.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

class AuthViewModel extends BaseViewModel {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();
  final NavigationService _navService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode validate = AutovalidateMode.disabled;

  String? email;
  String? password;

  Future handleStartup() async {}

  doLogin() async {
    if (!busy('loginButton')) {
      if (formKey.currentState!.validate()) {
        setBusyForObject('loginButton', true);
        formKey.currentState!.save();
        var _result = await _firebaseAuth.loginWithEmail(
            email: email!, password: password!);
        if (_result.user != null) {
          _navService.replaceWith(Routes.homeView);
        } else {
          _dialogService.showDialog(description: 'Unknown user or password');
          setBusyForObject('loginButton', false);
        }
      } else {
        validate = AutovalidateMode.onUserInteraction;
        notifyListeners();
      }
    }
  }
}
