import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  File file;
  bool get wantKeepAlive => true;
  TextEditingController descriptiontextEditingController =
      TextEditingController();
  TextEditingController pricetextEditingController = TextEditingController();
  TextEditingController titletextEditingController = TextEditingController();
  TextEditingController shorttextEditingController = TextEditingController();
  String productId = DateTime.now().microsecondsSinceEpoch.toString();
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    return file == null
        ? displayAdminHomeScreen()
        : displayAdminUploadFormScreen();
  }

  displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.border_color,
              color: Colors.white,
            ),
            onPressed: () {
              Route route =
                  MaterialPageRoute(builder: (c) => AdminShiftOrders());
              Navigator.pushReplacement(context, route);
            }),
        actions: [
          FlatButton(
            child: Text(
              "logout",
              style: TextStyle(
                color: Colors.pink,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (c) => SplashScreen());
              Navigator.pushReplacement(context, route);
            },
          ),
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [Colors.pink, Colors.lightGreenAccent],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shop_two,
              color: Colors.white,
              size: 200.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0)),
                child: Text(
                  "Add New Items",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () => takeImage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  takeImage(mcontext) {
    return showDialog(
        context: mcontext,
        builder: (con) {
          return SimpleDialog(
            title: Text(
              "Item Image",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture with camera",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () => capturePhotoWithCamea(),
              ),
              SimpleDialogOption(
                child: Text(
                  "Select from gallery",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () => capturePhotoFromGallery(),
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  capturePhotoWithCamea() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600.0, maxWidth: 970.0);
    setState(() {
      file = imageFile;
    });
  }

  capturePhotoFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = imageFile;
    });
  }

  displayAdminUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => clearFormInfo()),
        title: Text(
          "New Product",
          style: TextStyle(
              color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null : () => uploadImageandSaveIteminfo(),
            child: Text(
              "Add",
              style: TextStyle(
                  color: Colors.pink,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading ? circularProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.pink),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: shorttextEditingController,
                decoration: InputDecoration(
                    hintText: "Short Info",
                    helperStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.pink),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: titletextEditingController,
                decoration: InputDecoration(
                    hintText: "Title",
                    helperStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.pink),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: descriptiontextEditingController,
                decoration: InputDecoration(
                    hintText: "Description",
                    helperStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.pink),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: pricetextEditingController,
                decoration: InputDecoration(
                    hintText: "Price",
                    helperStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          )
        ],
      ),
    );
  }

  clearFormInfo() {
    setState(() {
      file = null;
      descriptiontextEditingController.clear();
      pricetextEditingController.clear();
      titletextEditingController.clear();
      shorttextEditingController.clear();
    });
  }

  uploadImageandSaveIteminfo() async {
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl = await uploadItemImage(file);
    saveItemInfo(imageDownloadUrl);
  }

  Future<String> uploadItemImage(mfile) async {
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child("items");
    StorageUploadTask storageUploadTask =
        storageReference.child("product_$productId.jpg").putFile(mfile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveItemInfo(String downloadUrl) {
    final itemsRef = Firestore.instance.collection("items");
    itemsRef.document(productId).setData({
      "shortInfo": shorttextEditingController.text.trim(),
      "longDescription": descriptiontextEditingController.text.trim(),
      "price": int.parse(pricetextEditingController.text.trim()),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
      "title": titletextEditingController.text.trim(),
    });
    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().microsecondsSinceEpoch.toString();
      descriptiontextEditingController.clear();
      titletextEditingController.clear();
      pricetextEditingController.clear();
      shorttextEditingController.clear();
    });
  }
}
