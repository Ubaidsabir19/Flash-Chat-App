import 'package:flutter/src/widgets/framework.dart';

class MessageModel {
  String? text;
  String? sender;
  String? receiver;
  String? createdAt;
  String? type;

  MessageModel({
    this.text,
    this.sender,
    this.createdAt,
    this.receiver,
    this.type,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    text = map["text"];
    sender = map["sender"];
    receiver = map["receiver"];
    createdAt = map["createdAt"];
    type = map["type"];
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "sender": sender,
      "receiver": receiver,
      "createdAt": createdAt,
      "type": type,
    };
  }
}
