import 'package:flutter/foundation.dart';

import './message.dart';

class MessageList with ChangeNotifier {
  final List<Message> _messages = [
    Message(message: '''Hi buddy! 
Which item do you prefer?
    ''', sender: "bot"),
  ];

  List<Message> get posts {
    return [..._messages];
  }

  Future<void> addNewPost(Message message) async {
    _messages.add(message);
    notifyListeners();
  }
}
