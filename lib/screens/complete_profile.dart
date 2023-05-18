import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashing_chat/Models/user_model.dart';
import 'package:flashing_chat/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  CompleteProfile({Key? key}) : super(key: key);
  List<String>? chatroomid = [];

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fullNameController = TextEditingController();
  File? _image;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        Fluttertoast.showToast(
          msg: "Image is null",
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }
      ;
      File? img = File(image.path);
      Fluttertoast.showToast(
        msg: "Image is selected",
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _image = img;
        print('setState:');
      });
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text;

    if (fullname == "" || _image == null) {
      Fluttertoast.showToast(
        msg: "Please fill all the fields",
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("profilePictures/" + uid + '.png')
        .putFile(_image!);

    TaskSnapshot snapshot = await uploadTask;

    print("uploadtask:" + snapshot.state.toString());

    String? imageUrl = await snapshot.ref.getDownloadURL();
    print("imageUrl:" + (imageUrl));

    String? fullname = fullNameController.text;
    List<String>? chatroomid = [];

    UserModel newUser = UserModel(
      fullname: fullname,
      profilepic: imageUrl,
      chatroomid: chatroomid,
      uid: uid,
    );
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(newUser.toMap(), SetOptions(merge: true))
        .then(
      (value) {
        Fluttertoast.showToast(
          msg: "Saved Data",
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }),
        );
      },
    ).catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (_image != null) ? FileImage(_image!) : null,
                  child: (_image == null)
                      ? const Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                  const CircularProgressIndicator();
                  Fluttertoast.showToast(
                    msg: "Welcome!",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
