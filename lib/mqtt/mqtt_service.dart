import 'dart:io';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'mqtt_config.dart';

class MqttService {
  factory MqttService() {
    return _instance;
  }
  static final MqttService _instance = MqttService._internal();

  final _client = MqttServerClient(config.host, config.clientIdentifier);
  var _stateStream = new StreamController<MqttConnectionState>.broadcast();
  Stream<MqttConnectionState> get currentConnectionState => _stateStream.stream;

  final Map<String, StreamController> _topicStreams = {};

  MqttService._internal() {
    _stateStream.add(_client.connectionStatus!.state);
    _initializeMQTTClient();
  }

  Future<void> _initializeMQTTClient() async {
    _client.logging(on: false);
    _client.setProtocolV311();
    _client.keepAlivePeriod = config.keepAlivePeriod;
    final connMess = MqttConnectMessage()
        .withWillTopic('willtopic')
        .withWillMessage(config.willMessage)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      print('MQTT::_client exception - $e');
      _client.disconnect();
    } on SocketException catch (e) {
      print('MQTT::socket exception - $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      print(
          'MQTT::ERROR Mosquitto _client connection failed - disconnecting, status is ${_client.connectionStatus}');
      _client.disconnect();
      exit(-1);
    }
    _stateStream.add(_client.connectionStatus!.state);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      var topic = c[0].topic;
      var payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
       if (_topicStreams.containsKey(topic)) {
        _topicStreams[topic]!.add(payload);
      }
    });
  }

  Stream<dynamic>? subscribe(String topic) {
    if (!isPolaczenie) return null;

    if (isTopicSubscribed(topic)) {
      return _topicStreams[topic]!.stream;
    }

    _client.subscribe(topic, MqttQos.exactlyOnce);

    var _thisTopicStream = new StreamController.broadcast();
    _topicStreams[topic] = _thisTopicStream;

    return _thisTopicStream.stream;
  }

  void disconnect() {
    if (!isPolaczenie) return;
    print('Disconnected');
    _stateStream.add(_client.connectionStatus!.state);
    _client.disconnect();
  }

  void publish(String topic, String message) {
    if (!isPolaczenie) return;
    if(!isTopicSubscribed(topic)) return;
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  get isPolaczenie {
    return _client.connectionStatus!.state == MqttConnectionState.connected;
  }

  isTopicSubscribed(String topic) {
    return _topicStreams.containsKey(topic);
  }
}
