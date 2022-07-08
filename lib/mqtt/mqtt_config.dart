class MqttConfig {
  int keepAlivePeriod = 20;
  String host = "127.0.0.1";
  String clientIdentifier = "";
  String willMessage = "My Will message";
}

var config = MqttConfig();