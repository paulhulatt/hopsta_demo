import 'package:flutter/material.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
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
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => model.doProfile(),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: (model.userProfileImage != null)
                    ? Image.network(
                        model.userProfileImage!,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.person),
              ),
            ),
          ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomButton('New Journey', context,
                    onPressed: () => model.startJourney(),
                    isBusy: model.busy('startButton')),
                verticalSpaceMedium,
                CustomButton('Journey History', context,
                    onPressed: () => model.doHistory(),
                    isBusy: model.busy('historyButton')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
