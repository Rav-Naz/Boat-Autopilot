import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../mqtt/mqtt_service.dart';

class MessagesProvider extends ChangeNotifier {

  final _mqtt = MqttService();
  Message? _lastMessage;

  MessagesProvider() {
    if (_mqtt.isConnected) {
      _subscribeMessages();
    } else {
      _mqtt.currentConnectionState.listen((state) {
        if (state == MqttConnectionState.connected) {
          _subscribeMessages();
        }
      });
    }
  }
  
  _subscribeMessages() {
    _mqtt.subscribe("boat/messages")!.listen((event) {
      String message = event.toString();
      if(message.length>=5) {
        _lastMessage = Message(code: message.substring(4), type: message.substring(0,3));
        notifyListeners();
      }
    });
  }

  Message? get getLastMessage {
    return _lastMessage;
  }

}

class Message {
  
  String code;
  String type;

  Message({required this.code, required this.type});

}