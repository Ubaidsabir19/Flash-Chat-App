import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashing_chat/Models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashing_chat/Models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.chatroomid,
    required this.userID,
    required this.userProfile,
    required this.fullname,
  }) : super(key: key);
  String chatroomid;
  String userID;
  String userProfile;
  String fullname;

  @override
  State<ChatScreen> createState() => _ChatScreenState(
        userID: this.userID,
        userProfile: this.userProfile,
        fullname: this.fullname,
        chatroomid: this.chatroomid,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState({
    required this.userID,
    required this.userProfile,
    required this.fullname,
    required this.chatroomid,
  });
  final String chatroomid;
  final String fullname;
  final String userID;
  final String userProfile;
  TextEditingController messageController = TextEditingController();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? mtoken = " ";
  String imageName = '';
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  bool isLoading = false;
  XFile? _imageFile;
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = (pickedFile);
      ;
      if (_imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadImageFile();
      }
    }
  }

  void uploadImageFile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final fval = await _imageFile?.readAsBytes();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("profilePictures/" + uid + '.png')
          .putData(fval!, SettableMetadata());
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      print("imageUrl:" + (imageUrl));
      setState(() async {
        isLoading = false;
        MessageModel user = MessageModel(
          type: imageUrl,
        );
        // await FirebaseFirestore.instance
        //     .collection("chatrooms")
        //     .doc(chatroomid)
        //     .collection("messages")
        //     .add(user.toMap());
        // print('data is stored');
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void sendMessage() async {
    String message = messageController.text;
    messageController.clear();

    if (message != "") {
      MessageModel newMessage = MessageModel(
        receiver: userID,
        sender: uid,
        createdAt: DateTime.now().toString(),
        text: message,
        type: '',
      );
      print('message is send');

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatroomid)
          .collection('messages')
          .add(newMessage.toMap());
      print(chatroomid);
    }
  }

  // Future getImage() async {
  //   final _picker = ImagePicker();
  //   XFile? pickedImage =
  //       await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
  //     if (pickedImage != null) {
  //       uploadImage();
  //     }
  //   });
  // }
  //
  // Future uploadImage() async {
  //   String fileName = Uuid().v1();
  //   int status = 1;
  //
  //   await FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .doc(chatroomid)
  //       .collection('messages')
  //       .doc(fileName)
  //       .set({
  //     "sender": userID,
  //     "message": messageController.text.toString(),
  //     "type": "img",
  //     "createdAt": FieldValue.serverTimestamp(),
  //   });
  //
  //   var ref =
  //       FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
  //
  //   var uploadTask = await ref.putFile().catchError((error) async {
  //     await FirebaseFirestore.instance
  //         .collection('chatrooms')
  //         .doc(chatroomid)
  //         .collection('messages')
  //         .doc(fileName)
  //         .delete();
  //
  //     status = 0;
  //   });
  //
  //   if (status == 1) {
  //     String imageUrl = await uploadTask.ref.getDownloadURL();
  //
  //     await FirebaseFirestore.instance
  //         .collection('chatrooms')
  //         .doc(chatroomid)
  //         .collection('messages')
  //         .doc(fileName)
  //         .update({"messages": imageUrl});
  //
  //     print(imageUrl);
  //   }
  // }
  //
  // void onSendMessage() async {
  //   if (messageController.text.isNotEmpty) {
  //     Map<String, dynamic> messages = {
  //       "sendby": fullname,
  //       "message": messageController.text,
  //       "type": "text",
  //       "time": FieldValue.serverTimestamp(),
  //     };
  //
  //     messageController.clear();
  //     await FirebaseFirestore.instance
  //         .collection('chatrooms')
  //         .doc(chatroomid)
  //         .collection('messages')
  //         .add(messages);
  //   } else {
  //     print("Enter Some Text");
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   requestPermission();
  //   loadFCM();
  //   listenFCM();
  //   getToken();
  //   FirebaseMessaging.instance.subscribeToTopic("UserToken");
  // }
  //
  // void getTokenFromFirestore() async {}
  //
  // void saveToken(String token) async {
  //   await FirebaseFirestore.instance.collection("UserTokens").doc("uid").set({
  //     'token': token,
  //   });
  // }
  //
  // void sendPushMessage(String token, String body, String title) async {
  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization':
  //             'key=AAAAsRmczhY:APA91bFZP2Wyc0OrbODyJM8gZM1F5ROlYgZG2VjBXgS3B4nlpYQmOObbuUiLNs-_rOnmENJpfuDbiorXktjKLRbyAeRXm4wr_pFPacWTXbLtPsej6Dho-VX6WJnM0kVi2_8shEXByYwJ',
  //       },
  //       body: jsonEncode(
  //         <String, dynamic>{
  //           'notification': <String, dynamic>{'body': body, 'title': title},
  //           'priority': 'high',
  //           'data': <String, dynamic>{
  //             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //             'id': '1',
  //             'status': 'done'
  //           },
  //           "to": token,
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     print("error push notification");
  //   }
  // }
  //
  // void getToken() async {
  //   await FirebaseMessaging.instance.getToken().then((token) {
  //     setState(() {
  //       mtoken = token;
  //     });
  //
  //     saveToken(token!);
  //   });
  // }
  //
  // void requestPermission() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     print('User granted provisional permission');
  //   } else {
  //     print('User declined or has not accepted permission');
  //   }
  // }
  //
  // void listenFCM() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     if (notification != null && android != null && !kIsWeb) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel.id,
  //             channel.name,
  //             // TODO add a proper drawable resource to android, for now using
  //             icon: 'launch_background',
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }
  //
  // void loadFCM() async {
  //   if (!kIsWeb) {
  //     channel = const AndroidNotificationChannel(
  //       'high_importance_channel', // id
  //       'High Importance Notifications', // title
  //       importance: Importance.high,
  //       enableVibration: true,
  //     );
  //
  //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //     await flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>()
  //         ?.createNotificationChannel(channel);
  //     await FirebaseMessaging.instance
  //         .setForegroundNotificationPresentationOptions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(userProfile),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(fullname),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(chatroomid)
                        .collection('messages')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print('data is found');
                        print(chatroomid);
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>?
                            listDocs = snapshot.data?.docs;
                        print(listDocs?.length);
                        return ListView.builder(
                          itemCount: listDocs?.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                listDocs?[index].data()
                                    as Map<String, dynamic>);
                            print(listDocs?[index].data());

                            return Row(
                              mainAxisAlignment: (currentMessage.sender == uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender == uid)
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    currentMessage.text.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        print('data is not found');
                        print(chatroomid);
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message"),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        getImage();
                      },
                      icon: Icon(
                        Icons.photo,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        sendMessage();
                        print('error');
                        // String message = messageController.text.toString();
                        // String titleText = messageController.text.toString();
                        // String bodyText = messageController.text.toString();
                        // if (message != null ||
                        //     titleText != null ||
                        //     bodyText != null) {
                        //   DocumentSnapshot snap = await FirebaseFirestore
                        //       .instance
                        //       .collection("UserTokens")
                        //       .doc(uid)
                        //       .get();
                        //   DocumentSnapshot<Object?> token =
                        //       snap['token'] as DocumentSnapshot;
                        //   print(token);
                        //   sendPushMessage(token[snap], titleText, bodyText);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
