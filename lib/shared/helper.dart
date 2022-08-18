import 'package:flutter/material.dart';

String? validatePassword(String? value) {
  if (value == null) return 'Password must be supplied';
  if (value.length < 6)
    return 'Password must be more than 5 characters';
  else
    return null;
}

String? validateEmail(String? value) {
  if (value == null) return 'Email must be supplied';
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password == null) return 'Password must be supplied';
  if (confirmPassword == null) return 'Password must be supplied';
  print("$password $confirmPassword");
  if (password != confirmPassword) {
    return 'Password doesn\'t match';
  } else if (confirmPassword.length == 0) {
    return 'Confirm password is required';
  } else {
    return null;
  }
}
