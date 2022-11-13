import 'package:flutter/foundation.dart';

import './message.dart';

enum itemType { Tea, Vada, Maggie, Others }

class Order {
  itemType item;
  int quantity;
  double price;

  Order({required this.item, required this.quantity, required this.price});
}

class MessageList with ChangeNotifier {
  Map<String, Order> order = {
    'Tea': Order(item: itemType.Tea, quantity: 0, price: 10),
    'Vada': Order(item: itemType.Vada, quantity: 0, price: 20),
    'Maggie': Order(item: itemType.Maggie, quantity: 0, price: 30),
    'Others': Order(item: itemType.Others, quantity: 0, price: 40),
  };

  Future<void> addOrder(String itemName, int quantity) async {
    debugPrint('Adding $itemName');
    order[itemName]!.quantity += quantity;
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
