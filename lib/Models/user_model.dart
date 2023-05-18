class UserModel {
  String? fullname;
  String? profilepic;
  String? uid;
  List<String>? chatroomid = [];

  UserModel({
    this.fullname,
    this.profilepic,
    this.uid,
    this.chatroomid,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    fullname = map["fullname"];
    uid = map["uid"];
    profilepic = map["profilepic"];
    chatroomid = map["chatroomid"];
  }

  Map<String, dynamic> toMap() {
    return {
      "fullname": fullname,
      "uid": uid,
      "profilepic": profilepic,
      "chatroomid": chatroomid,
    };
  }
}
