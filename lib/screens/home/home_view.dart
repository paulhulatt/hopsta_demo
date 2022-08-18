import 'package:flutter/material.dart';
import 'package:hopsta_demo/widgets/custom_button.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Hopsta'),
          actions: [
            IconButton(
              onPressed: () => model.doLogout(),
              icon: Icon(Icons.logout),
              color: Colors.white,
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: CustomButton('New Journey', context,
              onPressed: () => model.startJourney(),
              isBusy: model.busy('startButton')),
        ),
      ),
    );
  }
}
