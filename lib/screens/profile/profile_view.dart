import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:hopsta_demo/shared/helper.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
import 'package:hopsta_demo/widgets/custom_button.dart';
import 'package:stacked/stacked.dart';

import 'profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onModelReady: ((model) => model.handleStartup()),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: (model.isBusy || !model.initialised)
            ? Center(
                child: Container(
                  width: thirdScreenWidth(context),
                  height: thirdScreenWidth(context),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Form(
                  key: model.formKey,
                  autovalidateMode: model.validate,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(children: [
                              SizedBox(
                                height: 200,
                                child: GestureDetector(
                                  onTap: () => model.getNewPhoto(),
                                  child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: (model.photoURL != null)
                                          ? Image.network(
                                              model.photoURL!,
                                              fit: BoxFit.cover,
                                            )
                                          : ((model.initialPhotoURL != null)
                                              ? Image.network(
                                                  model.initialPhotoURL!,
                                                  fit: BoxFit.cover,
                                                  width: 200,
                                                  height: 200,
                                                )
                                              : Icon(
                                                  Icons.add_a_photo,
                                                  size: 50,
                                                ))),
                                ),
                              ),
                              verticalSpaceMedium,
                              TextFormField(
                                  initialValue: model.initialDisplayName,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (String? val) {
                                    model.displayName = val;
                                    model.dirty = true;
                                  },
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.grey[700]),
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Theme.of(context).primaryColor,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.only(
                                          left: 16, right: 16),
                                      fillColor: Colors.white,
                                      hintText: 'Name',
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2.0)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ))),
                              verticalSpaceMedium,
                              TextFormField(
                                  initialValue: model.initialEmail,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.next,
                                  validator: validateEmail,
                                  onChanged: (String? val) {
                                    model.email = val;
                                    model.dirty = true;
                                  },
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.grey[700]),
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Theme.of(context).primaryColor,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.only(
                                          left: 16, right: 16),
                                      fillColor: Colors.white,
                                      hintText: 'Email',
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2.0)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ))),
                              verticalSpaceMedium,
                              Divider(),
                              verticalSpaceMedium,
                              Text('Saved Card'),
                              CreditCardWidget(
                                bankName: 'Test Bank',
                                cardType: CardType.visa,
                                cardNumber: '4546 0000 0000 5643',
                                expiryDate: '09/24',
                                cardHolderName: 'MR A TEST',
                                cvvCode: '123',
                                showBackView:
                                    false, //true when you want to show cvv(back) view
                                onCreditCardWidgetChange: (_) => null,
                                isHolderNameVisible: true,
                              ),
                            ]),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomButton(
                          'Save Changes',
                          context,
                          onPressed: () => model.saveUser(),
                          isBusy: model.busy('saveButton'),
                          minHeight: 20,
                          minWidth: double.infinity,
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
