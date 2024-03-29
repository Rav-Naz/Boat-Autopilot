import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../mqtt/mqtt_service.dart';
import '../shared/colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  double _currentBoatAngle = 0.0;
  double _settedBoatAngle = 0.0;
  double _oldSettedBoatAngle = 0.0;
  double _currentBoatSpeed = 0.0;
  double _settedBoatSpeed = 0.0;
  double _upsetAngle = 0.0;
  Offset _centerOfGestureDetector = const Offset(300.0, 300.0);
  final GlobalKey _rotateKey = GlobalKey();
  bool isAnimationEnabled = true;
  var _mqtt = MqttService();
  var _isManualMode = true;
  Stream? subTopic;

  @override
  void initState() {
    _mqtt.currentConnectionState.listen((state) {
      if (state == MqttConnectionState.connected) {
        _mqtt.subscribe("boat/main/gyro")!.listen((event) {
          if (mounted) {
            setState(() {
              _currentBoatAngle = (double.parse(event) * pi) / 180 * -1;
            });
          }
        });
        _mqtt.subscribe("boat/main/current_speed")!.listen((event) {
          if (mounted) {
            setState(() {
              _currentBoatSpeed = double.parse(event);
            });
          }
        });
        _mqtt.subscribe("boat/main/setted_speed")!.listen((event) {
          if (mounted) {
            setState(() {
              _settedBoatSpeed = double.parse(event);
            });
          }
        });
        _mqtt.subscribe("boat/main/stering_mode")!.listen((event) {
          if (mounted) {
            setState(() {
              _isManualMode = event == 'true';
            });
          }
        });
      }
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var mediaWidth = MediaQuery.of(context).size.width;
    return Container(
        key: const PageStorageKey<String>("home"),
        color: primaryDark,
        child: Stack(children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: constraints.maxHeight * 0.7,
                  child: Container(
                    constraints: const BoxConstraints(
                        minHeight: 250.0,
                        maxHeight: 600.0,
                        minWidth: 250.0,
                        maxWidth: 600.0),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 1500),
                          turns: _currentBoatAngle / (2 * pi),
                          curve: Curves.easeInOutQuad,
                          child: SvgPicture.asset("assets/svg/busola.svg",
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              clipBehavior: Clip.none),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          heightFactor: 0.7,
                          child: Image.asset(
                            "assets/png/jacht.png",
                          ),
                        ),
                        Transform.scale(
                          scale: 1.05,
                          child: GestureDetector(
                            key: _rotateKey,
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (details) {
                              setState(() {
                                isAnimationEnabled = false;
                              });
                              final Size size =
                                  _rotateKey.currentContext!.size!;
                              _centerOfGestureDetector =
                                  Offset(size.width / 2, size.height / 2);
                              final touchPositionFromCenter =
                                  details.localPosition -
                                      _centerOfGestureDetector;
                              _upsetAngle = _oldSettedBoatAngle -
                                  touchPositionFromCenter.direction;
                            },
                            onPanEnd: (details) {
                              setState(
                                () {
                                  isAnimationEnabled = true;
                                  _oldSettedBoatAngle = _settedBoatAngle;
                                },
                              );
                            },
                            onPanUpdate: (details) {
                              final touchPositionFromCenter =
                                  details.localPosition -
                                      _centerOfGestureDetector;
                              setState(
                                () {
                                  _settedBoatAngle =
                                      (touchPositionFromCenter.direction +
                                              _upsetAngle) %
                                          (pi * 2);
                                  _mqtt.publish('boat/main/heading',
                                      (_settedBoatAngle * 180 / pi).toString());
                                },
                              );
                            },
                            child: AnimatedRotation(
                              duration: isAnimationEnabled
                                  ? const Duration(milliseconds: 1500)
                                  : const Duration(milliseconds: 0),
                              turns: _settedBoatAngle / (2 * pi) +
                                  _currentBoatAngle / (2 * pi),
                              curve: Curves.easeInOutQuad,
                              child: SvgPicture.asset(
                                "assets/svg/kursor.svg",
                                color: accent,
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                clipBehavior: Clip.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
              bottom: 15,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (_currentBoatAngle / (2 * pi) * 360)
                          .abs()
                          .toStringAsFixed(1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40 * mediaWidth * 0.001,
                          fontWeight: FontWeight.bold)),
                  Text(
                    AppLocalizations.of(context)!.actual_course,
                    style: TextStyle(
                        color: primary, fontSize: 18 * mediaWidth * 0.001),
                  )
                ],
              )),
          Positioned(
              top: 15,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.setted_course,
                    style: TextStyle(
                        color: primary, fontSize: 18 * mediaWidth * 0.001),
                  ),
                  Text((_settedBoatAngle / (2 * pi) * 360).toStringAsFixed(1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40 * mediaWidth * 0.001,
                          fontWeight: FontWeight.bold)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isManualMode
                        ? Text(0.0.toString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 25))
                        : Row(
                            children: [
                              Container(
                                child: IconButton(
                                  iconSize: 15,
                                  constraints: const BoxConstraints(
                                      maxHeight: 30, maxWidth: 30),
                                  onPressed: () {
                                    setState(() {
                                      _settedBoatAngle =
                                          (((_settedBoatAngle * 180 / pi) - 1) %
                                                  360) *
                                              pi /
                                              180;
                                    });
                                    _mqtt.publish(
                                        'boat/main/heading',
                                        (_settedBoatAngle * 180 / pi)
                                            .toString());
                                  },
                                  icon: const Icon(Icons.remove),
                                  color: accent,
                                ),
                                decoration: BoxDecoration(
                                    color: primaryDarkest,
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: IconButton(
                                  iconSize: 15,
                                  constraints: const BoxConstraints(
                                      maxHeight: 30, maxWidth: 30),
                                  onPressed: () {
                                    setState(() {
                                      _settedBoatAngle =
                                          (((_settedBoatAngle * 180 / pi) + 1) %
                                                  360) *
                                              pi /
                                              180;
                                    });
                                    _mqtt.publish(
                                        'boat/main/heading',
                                        (_settedBoatAngle * 180 / pi)
                                            .toString());
                                  },
                                  icon: const Icon(Icons.add),
                                  color: accent,
                                ),
                                decoration: BoxDecoration(
                                    color: primaryDarkest,
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                            ],
                          ),
                  )
                ],
              )),
          Positioned(
              bottom: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_currentBoatSpeed.toStringAsFixed(1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40 * mediaWidth * 0.001,
                          fontWeight: FontWeight.bold)),
                  Text(
                    AppLocalizations.of(context)!.actual_speed,
                    style: TextStyle(
                        color: primary, fontSize: 18 * mediaWidth * 0.001),
                  )
                ],
              )),
          Positioned(
              top: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.setted_speed,
                    style: TextStyle(
                        color: primary, fontSize: 18 * mediaWidth * 0.001),
                  ),
                  Text(_settedBoatSpeed.toStringAsFixed(1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40 * mediaWidth * 0.001,
                          fontWeight: FontWeight.bold)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isManualMode
                        ? Text(
                            0.0.toString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 25),
                          )
                        : Row(
                            children: [
                              Container(
                                child: IconButton(
                                  iconSize: 15,
                                  constraints: const BoxConstraints(
                                      maxHeight: 30, maxWidth: 30),
                                  onPressed: () {
                                    // setState(() {
                                    //   _settedBoatAngle -= 1*pi/180;
                                    // });
                                    _mqtt.publish('boat/main/setted_speed',
                                        (_settedBoatSpeed - 1).toString());
                                  },
                                  icon: const Icon(Icons.remove),
                                  color: accent,
                                ),
                                decoration: BoxDecoration(
                                    color: primaryDarkest,
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: IconButton(
                                  iconSize: 15,
                                  constraints: const BoxConstraints(
                                      maxHeight: 30, maxWidth: 30),
                                  onPressed: () {
                                    // setState(() {
                                    //   _settedBoatAngle -= 1*pi/180;
                                    // });
                                    _mqtt.publish('boat/main/setted_speed',
                                        (_settedBoatSpeed + 1).toString());
                                  },
                                  icon: const Icon(Icons.add),
                                  color: accent,
                                ),
                                decoration: BoxDecoration(
                                    color: primaryDarkest,
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                            ],
                          ),
                  )
                ],
              )),
        ]));
  }
}
