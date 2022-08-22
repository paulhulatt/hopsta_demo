import 'package:flutter/material.dart';
import 'package:hopsta_demo/shared/helper.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
import 'package:hopsta_demo/widgets/custom_button.dart';
import 'package:stacked/stacked.dart';

import 'auth_viewmodel.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      onModelReady: (model) => model.handleStartup(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: model.formKey,
          autovalidateMode: model.validate,
          child: Center(
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/hopsta-logo-full.png'),
                  verticalSpaceMedium,
                  TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      onSaved: (String? val) {
                        model.email = val;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          contentPadding:
                              new EdgeInsets.only(left: 16, right: 16),
                          fillColor: Colors.white,
                          hintText: 'Email',
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ))),
                  verticalSpaceSmall,
                  TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: validatePassword,
                      onSaved: (String? val) {
                        model.password = val;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Theme.of(context).primaryColor,
                      obscureText: true,
                      decoration: InputDecoration(
                          contentPadding:
                              new EdgeInsets.only(left: 16, right: 16),
                          fillColor: Colors.white,
                          hintText: 'Password',
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ))),
                  verticalSpaceMedium,
                  if (!model.isSignup)
                    CustomButton('Login', context,
                        onPressed: () => model.doLogin()),
                  if (model.isSignup)
                    CustomButton('Signup', context,
                        onPressed: () => model.doSignup()),
                  verticalSpaceSmall,
                  TextButton(
                      child: Text((!model.isSignup)
                          ? 'New User? Tap to register'
                          : 'Already registered?  Tap here'),
                      onPressed: () => model.toggleLoginSignup())
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
