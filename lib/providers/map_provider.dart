import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../mqtt/mqtt_service.dart';

class MapProvider extends ChangeNotifier {
  final _mqtt = MqttService();
  LatLng? _currentPosition;
  MapController controller = MapController();
  bool isMapLocked = true;
  bool isCentering = true;
  bool isLoaded = false;
  double _metersToDetermineNearby = 20;
  List<LatLng> _navigationMarkerPointsList = [];
  List<LatLng> _navigationMarkerPointsListPassed = [];

  MapProvider() {
    if (_mqtt.isConnected) {
      _subscribePosition();
    } else {
      _mqtt.currentConnectionState.listen((state) {
        if (state == MqttConnectionState.connected) {
          // 5000.480,N,02159.890,E
          _subscribePosition();
        }
      });
    }
    controller.onReady.then((value) {isLoaded = true;});
  }

  _subscribePosition() {
    _mqtt.subscribe("boat/map/position")!.listen((event) {
      _currentPosition = nmeaToLatLong(event.toString());
      if (isCentering && isMapLocked && isLoaded) {
        controller.move(_currentPosition!, controller.zoom);
      }
      updatePath();
      notifyListeners();
    });
  }

  LatLng nmeaToLatLong(String dataString) {
    var data = dataString.split(',');
    var latitude = double.parse((double.parse(data[0].substring(0, 2)) +
            (double.parse(data[0].substring(2)) / 60) *
                (data[1] == "N" ? 1 : -1))
        .toStringAsFixed(6));
    var longitude = double.parse((double.parse(data[2].substring(0, 3)) +
            (double.parse(data[2].substring(3)) / 60) *
                (data[3] == "E" ? 1 : -1))
        .toStringAsFixed(6));
    return LatLng(latitude, longitude);
  }

  void switchLockMap() {
    isMapLocked = !isMapLocked;
    if (isCentering && isMapLocked && _currentPosition != null) {
      controller.move(_currentPosition!, controller.zoom);
    }
    notifyListeners();
  }

  void switchCenteringMap() {
    isCentering = !isCentering;
    if (isCentering && isMapLocked && _currentPosition != null) {
      controller.move(_currentPosition!, controller.zoom);
    }
    notifyListeners();
  }

  void zoomIn() {
    controller.move(controller.center, controller.zoom < 18 ? controller.zoom + 1 : controller.zoom);
    notifyListeners();
  }

  void zoomOut() {
    controller.move(controller.center, controller.zoom > 0 ? controller.zoom - 1 : controller.zoom);
    notifyListeners();
  }

  void addNavigationPoint(LatLng coordinates) {
    if (_currentPosition != null) {
      _mqtt.publish("boat/map/new_waypoint", jsonEncode(coordinates.toJson()));
      _navigationMarkerPointsList.add(coordinates);
      notifyListeners();
    }
  }

  void removeTopNavigationPoint() {
    if(_navigationMarkerPointsList.isNotEmpty) {
      var removed = _navigationMarkerPointsList.removeLast();
      _mqtt.publish("boat/map/remove_top_waypoint", jsonEncode(removed.toJson()));
      notifyListeners();
    }
  }

  void updatePath() {
    var point = getClosestNavigationPoint;
    if (point != null) {
      var index = _navigationMarkerPointsList.indexOf(point)+1;
      _navigationMarkerPointsListPassed += _navigationMarkerPointsList.sublist(0,index);
      if (_navigationMarkerPointsListPassed.length > 3) {
        _navigationMarkerPointsListPassed.removeRange(0, _navigationMarkerPointsListPassed.length-3);
      }
      _navigationMarkerPointsList.removeRange(0, index);
    }
  }

  double calculateDistanceInMeters(LatLng pos1, LatLng pos2) {
    
    var lat1 = pos1.latitudeInRad;
    var lat2 = pos2.latitudeInRad;

    var dlon = pos2.longitudeInRad - pos1.longitudeInRad;
    var dlat = lat2 - lat1;

    var a = pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) *  pow(sin(dlon / 2), 2);
    var c = 2 * asin(sqrt(a));

    //  Radius of earth in kilometers. Use 3956 for miles
    var r = 6371;

    return c*r*1000;
  }

  LatLng? get getClosestNavigationPoint {
    LatLng? closestPoint;
    if (_currentPosition != null && _navigationMarkerPointsList.isNotEmpty) {
    var smallestDistance = double.infinity;
      for (var navigationPoint in _navigationMarkerPointsList) {
        var distance = calculateDistanceInMeters(_currentPosition!, navigationPoint);
        if (distance < _metersToDetermineNearby && distance < smallestDistance) {
          closestPoint = navigationPoint;
        }
      }
    }
    return closestPoint;
  }

  List<LatLng> get getNavigationMarkerPointsList {
      return _navigationMarkerPointsList;
  }
  List<LatLng> get getNavigationMarkerPointsPassedList {
      return _navigationMarkerPointsListPassed;
  }

  LatLng? get getCurrentPosition {
      return _currentPosition;
  }

}
