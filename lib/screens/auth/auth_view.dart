import 'package:flutter/material.dart';
import 'package:hopsta_demo/shared/helper.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 20),
                            minimumSize: Size(halfScreenWidth(context), 60),
                          ),
                          onPressed: () => model.doLogin(),
                          child: (model.busy('loginButton'))
                              ? ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxHeight: 21.0, maxWidth: 21.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
