import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashing_chat/screens/chat_screen.dart';
import 'package:flashing_chat/screens/phone_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Flashing Chat"),
        actions: [
          IconButton(
            onPressed: () async {
              //message();
              FirebaseAuth.instance.signOut();
              const CircularProgressIndicator();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PhoneAuth();
                  },
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('uid', isNotEqualTo: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>? listDocs =
                      snapshot.data?.docs;
                  return ListView.builder(
                    itemCount: listDocs?.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          const CircularProgressIndicator();
                          String otherid = listDocs?[index].data()['uid'];
                          String myuid = uid!;
                          String chattemp = myuid + '_' + otherid;
                          //smaller id comes first
                          if (myuid.compareTo(otherid) > 0) {
                            chattemp = otherid + '_' + myuid;
                          } else {
                            chattemp = myuid + '_' + otherid;
                          }

                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .update({
                            "chatroomids": FieldValue.arrayUnion([chattemp])
                          });

                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(otherid)
                              .update({
                            "chatroomids": FieldValue.arrayUnion([chattemp])
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ChatScreen(
                                  userID: listDocs?[index].data()['uid'],
                                  chatroomid: chattemp,
                                  userProfile:
                                      listDocs?[index].data()['profilepic'],
                                  fullname:
                                      listDocs?[index].data()['fullname']),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            listDocs?[index].data()['profilepic'].toString() ??
                                '',
                          ),
                        ),
                        title: Text(
                          listDocs?[index].data()['fullname'].toString() ?? '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
