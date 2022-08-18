import 'package:flutter/material.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:hopsta_demo/app/app.router.dart';
import 'package:hopsta_demo/screens/auth/auth_view.dart';
import 'package:hopsta_demo/screens/home/home_view.dart';
import 'package:hopsta_demo/services/hopsta_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class EntryViewModel extends BaseViewModel {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();
  final NavigationService _navService = locator<NavigationService>();
  final HopstaService _hopstaService = locator<HopstaService>();

  handleStartup() {
    if (!_hopstaService.initialised) {
      Future.delayed(const Duration(milliseconds: 500))
          .then((value) => handleStartup());
    } else {
      Future.delayed(const Duration(milliseconds: 0)).then((value) {
        if (_firebaseAuth.hasUser) {
          _navService.replaceWith(Routes.homeView);
        } else {
          _navService.replaceWith(Routes.authView);
        }
      });
    }
  }
}

class EntryView extends StatelessWidget {
  const EntryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EntryViewModel>.reactive(
      viewModelBuilder: () => EntryViewModel(),
      onModelReady: (model) => model.handleStartup(),
      builder: (context, model, child) => Scaffold(
          body: Center(child: Image.asset('assets/images/hopsta-logo.png'))),
    );
  }
}
