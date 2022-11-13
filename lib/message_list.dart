import 'package:flutter/foundation.dart';

import './message.dart';

class MessageList with ChangeNotifier {
  List<Map<String, int>> order = [];

  Future<void> addOrder(Map<String, int> item) async {
    order.add(item);
    notifyListeners();
  }

  final List<Message> _messages = [
    Message(message: '''Hi buddy!
Which item do you prefer?
    ''', sender: "bot"),
  ];

  List<Message> get posts {
    return [..._messages];
  }

  Future<void> addMessage(Message message) async {
    _messages.add(message);
    notifyListeners();
  }
}
