import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../mqtt/mqtt_service.dart';

class SettingsProvider extends ChangeNotifier {

  late SharedPreferences _preferences;
  final _mqtt = MqttService();
  final _mqttTopicString = "boat/setting/";
  String _language = "en";

  Map<String, dynamic> _otherSettings = {};

  SettingsProvider() {
    SharedPreferences.getInstance().then((value) {
      _preferences = value;
      if (_preferences.containsKey("UiSettings")) {
        String string = _preferences.getString("UiSettings")!;
        _otherSettings = jsonDecode(string) as Map<String, dynamic>;
        _language = getSetting("language") == "Polski" ? "pl" : "en";
        notifyListeners();
      } else {
        _savePreferences();
      }
    });
  }

  void _savePreferences() {
    _preferences.setString("UiSettings", jsonEncode(_otherSettings));
  }

  void setSetting(String key, String value) {
    _otherSettings[key] = value;
    _mqtt.publish(_mqttTopicString+key, value);
    notifyListeners();
    _savePreferences();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  get getLanguage {
    return _language;
  }

  dynamic getSetting(String key) {
    if (_otherSettings.containsKey(key))
    {
      return _otherSettings[key];
    } else {
      return null;
    }
  }
}
