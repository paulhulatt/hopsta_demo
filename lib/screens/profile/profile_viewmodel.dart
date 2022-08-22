import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hopsta_demo/app/app.locator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  final FirebaseAuthenticationService _firebaseAuth =
      locator<FirebaseAuthenticationService>();
  final NavigationService _navService = locator<NavigationService>();

  bool dirty = false;
  String? displayName;
  String? password;
  String? email;
  String? photoURL;

  GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode validate = AutovalidateMode.disabled;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? photo;
  final ImagePicker _picker = ImagePicker();

  handleStartup() async {
    setInitialised(true);

    notifyListeners();
  }

  String? get initialDisplayName => _firebaseAuth.currentUser?.displayName;
  String? get initialEmail => _firebaseAuth.currentUser?.email;
  String? get initialPhotoURL => _firebaseAuth.currentUser?.photoURL;

  saveUser() async {
    setBusyForObject('saveButton', true);

    if (displayName != null) {
      await _firebaseAuth.currentUser!.updateDisplayName(displayName);
    }
    if (password != null) {
      await _firebaseAuth.currentUser!.updatePassword(password!);
    }
    if (email != null) {
      await _firebaseAuth.currentUser!.updateEmail(email!);
    }
    if (photoURL != null) {
      await _firebaseAuth.currentUser!.updatePhotoURL(photoURL!);
    }

    _navService.back();
  }

  getNewPhoto() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    if (pickedFile != null) {
      photo = File(pickedFile.path);
      if (photo == null) return;
      final destination = 'profilePhotos/${_firebaseAuth.currentUser!.uid}';

      try {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref(destination)
            .child('profilePhotos/');
        await ref.putFile(photo!);

        photoURL = await ref.getDownloadURL();

        dirty = true;
        notifyListeners();
      } catch (e) {
        debugPrint('error occured');
      }
    } else {
      debugPrint('No image selected.');
    }
  }
}
