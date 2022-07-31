import 'dart:math';

import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';


class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _lastLatLong;
  double? _rotationAngle;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        var latlong = mapProvider.getCurrentPosition;
        if (_lastLatLong != null && _lastLatLong != latlong && latlong != null) {
          var w = latlong.latitude - _lastLatLong!.latitude;
          var h = latlong.longitude - _lastLatLong!.longitude;
          var atans = atan((h / w)) / pi * 180;
          if (w < 0 || h < 0) {
            atans += 180;
          }
          if (w > 0 && h < 0) {
            atans -= 180;
          }
          if (atans < 0) {
            atans += 360;
          }
          _rotationAngle = atans % 360;
        }
        _lastLatLong = latlong;
        return FlutterMap(
          mapController: mapProvider.controller,
          nonRotatedChildren: [
            Positioned(
                left: 30,
                bottom: 30,
                child: Column(
                  children: [
                    Visibility(
                        visible: mapProvider.getNavigationMarkerPointsList.isNotEmpty,
                        child: MapButton(
                            mapProvider: mapProvider,
                            onPressFunction: mapProvider.removeTopNavigationPoint,
                            iconOn: Icons.undo)),
                    Visibility(
                        visible: mapProvider.isMapLocked,
                        child: MapButton(
                            mapProvider: mapProvider,
                            onPressFunction: mapProvider.switchCenteringMap,
                            iconOn: Icons.center_focus_weak,
                            iconOff: Icons.crop_free,
                            indicator: mapProvider.isCentering)),
                    MapButton(
                        mapProvider: mapProvider,
                        onPressFunction: mapProvider.switchLockMap,
                        iconOn: Icons.lock,
                        iconOff: Icons.lock_open,
                        indicator: mapProvider.isMapLocked),
                    MapButton(
                        mapProvider: mapProvider,
                        onPressFunction: mapProvider.zoomOut,
                        iconOn: Icons.remove),
                    MapButton(
                        mapProvider: mapProvider,
                        onPressFunction: mapProvider.zoomIn,
                        iconOn: Icons.add),
                  ],
                )),
            Positioned(
              bottom: 10,
              left: 30,
              right: 30,
              child: Visibility(
                visible: mapProvider.getNavigationMarkerPointsList.isEmpty && _lastLatLong != null,
                child: Center(
                        child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: primaryDark),
                      child: const Text(
                        "Aby dodać punkt nawigacyjny, przytrzymaj w wybranym miejscu na mapie",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    )),
              ),
            )
          ],
          options: MapOptions(
              center: _lastLatLong,
              maxZoom: 18,
              keepAlive: true,
              interactiveFlags: mapProvider.isMapLocked
                  ? (InteractiveFlag.none | InteractiveFlag.pinchZoom)
                  : InteractiveFlag.all,
              onLongPress: (tap, latlong) {
                mapProvider.addNavigationPoint(latlong);
              }),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            PolylineLayerOptions(
            polylineCulling: false,
            polylines: [
                Polyline(
                  strokeWidth: 5,
                  points: mapProvider.getNavigationMarkerPointsPassedList,
                  color: primary,
                ),
                Polyline(
                  strokeWidth: 5,
                  points: mapProvider.getNavigationMarkerPointsPassedList.isNotEmpty ? [mapProvider.getNavigationMarkerPointsPassedList.last]+mapProvider.getNavigationMarkerPointsList : mapProvider.getNavigationMarkerPointsList,
                  color: accent,
                ),
            ],
        ),
            MarkerLayerOptions(
                markers: _lastLatLong != null
                    ? mapProvider.getNavigationMarkerPointsPassedList.map((e) {
                          var index = mapProvider.getNavigationMarkerPointsList.indexOf(e) + 1;
                          return Marker(
                            width: 10,
                            height: 10,
                              builder: (context) {
                                return Container(decoration: BoxDecoration(color: primary,borderRadius: BorderRadius.circular(50)));
                              },
                              point: e);
                        }).toList()
                    : []),

            MarkerLayerOptions(
                markers: _lastLatLong != null
                    ? (
                        mapProvider.getNavigationMarkerPointsList.map((e) {
                          var index = mapProvider.getNavigationMarkerPointsList.indexOf(e) + 1;
                          return Marker(
                              builder: (context) {
                                return Container(decoration: BoxDecoration(color: accent,borderRadius: BorderRadius.circular(50)), width: 20, height: 20, child: Center(child: Text(index.toString(), style: const TextStyle(color: primaryDarkest, fontWeight: FontWeight.bold),)),);
                              },
                              point: e);
                        }).toList() + [
                          Marker(
                              width: 50,
                              height: 100,
                              builder: (context) =>
                                  BoatMarker(angle: _rotationAngle),
                              point: _lastLatLong!)
                        ])
                    : [])
          ],
        );
      },
    );
  }
}

class MapButton extends StatelessWidget {
  final MapProvider mapProvider;
  final IconData iconOn;
  final IconData? iconOff;
  final bool? indicator;
  final void Function()? onPressFunction;
  const MapButton({
    Key? key,
    required this.mapProvider,
    required this.iconOn,
    this.iconOff,
    this.indicator,
    required this.onPressFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(400), color: primaryDarkest),
        child: IconButton(
          onPressed: onPressFunction,
          icon: Icon(
              indicator != null ? (indicator! ? iconOn : iconOff) : iconOn),
          color: accent,
          iconSize: 35,
        ),
      ),
    );
  }
}

class BoatMarker extends StatelessWidget {
  final double? angle;
  BoatMarker({required this.angle});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: angle != null ? (angle! / 360) : 0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/png/jacht.png",
                ),
                fit: BoxFit.cover)),
      ),
    );

  }
}
