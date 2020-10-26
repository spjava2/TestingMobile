import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final TextEditingController cpasswordTextEditingController =
      TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String userImageUrl = "";
  File imageFile;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: selectAndPickImage,
              child: CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundColor: Colors.white,
                backgroundImage:
                    imageFile == null ? null : FileImage(imageFile),
                child: imageFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: screenWidth * 0.15,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Form(
              key: formkey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: nameTextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: cpasswordTextEditingController,
                    data: Icons.person,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                uploadAndSaveImage();
              },
              color: Colors.pink,
              child: Text(
                "Sign Up",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<Void> selectAndPickImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<Void> uploadAndSaveImage() async {
    if (imageFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog("Please select a image");
          });
    } else {
      passwordTextEditingController.text == cpasswordTextEditingController.text
          ? emailTextEditingController.text.isNotEmpty &&
                  passwordTextEditingController.text.isNotEmpty &&
                  cpasswordTextEditingController.text.isNotEmpty &&
                  nameTextEditingController.text.isNotEmpty
              ? uploadToStorage()
              : displayDialog("Please fill up the registration complete form")
          : displayDialog("Password do not match");
    }
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(msg);
        });
  }

  uploadToStorage() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: "Authunticating please wait....",
          );
        });
    String imageFilenme = DateTime.now().microsecondsSinceEpoch.toString();

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(imageFilenme);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((urlimage) {
      userImageUrl = urlimage;
      registerUser();
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> registerUser() async {
    FirebaseUser firebaseUser;

    await auth
        .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(error.toString());
          });
    });

    if (firebaseUser != null) {
      saveUserInformationToFirebase(firebaseUser).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserInformationToFirebase(FirebaseUser firebaseUser) async {
    Firestore.instance.collection("users").document(firebaseUser.uid).setData({
      "uid": firebaseUser.uid,
      "email": firebaseUser.email,
      "name": nameTextEditingController.text.trim(),
      "url": userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"],
    });
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userUID, firebaseUser.uid);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userEmail, firebaseUser.email);
    await EcommerceApp.sharedPreferences.setString(
        EcommerceApp.userName, nameTextEditingController.text.trim());
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}
