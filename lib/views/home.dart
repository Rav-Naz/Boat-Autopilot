import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../mqtt/mqtt_service.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  double _currentBoatAngle = 0.0;
  double _settedBoatAngle = 0.0;
  double _oldSettedBoatAngle = 0.0;
  double _upsetAngle = 0.0;
  Offset _centerOfGestureDetector = const Offset(300.0, 300.0);
  final GlobalKey _rotateKey = GlobalKey();
  bool isAnimationEnabled = true;
  var mqtt = MqttService();
  Stream? subTopic;

  @override
  void initState() {
    mqtt.currentConnectionState.listen((state) {
      if (state == MqttConnectionState.connected) {
        subTopic = mqtt.subscribe("home/garden/fountain");
        subTopic!.listen((event) {
          setState(() {
            _currentBoatAngle = (double.parse(event) * pi) / 180 * -1;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(40.0),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 250.0,
                      maxHeight: 600.0,
                      minWidth: 250.0,
                      maxWidth: 600.0
                    ),
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
                        Container(
                          width: 2.0,
                          height: double.infinity,
                          color: Color.fromARGB(83, 158, 158, 158),
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
                )),
            Expanded(
                flex: 2,
                child: Container(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          AnimatedFlipCounter(
                              value: (_settedBoatAngle / (2 * pi) * 360),
                              duration: const Duration(milliseconds: 250),
                              fractionDigits: 1,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 100)),
                          const Text("Kurs zadany",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 30))
                        ],
                      ),
                      Column(
                        children: [
                          AnimatedFlipCounter(
                              value: (_currentBoatAngle / (2 * pi) * 360).abs(),
                              duration: const Duration(milliseconds: 250),
                              fractionDigits: 1,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 100)),
                          const Text("Kurs aktualny",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 30))
                        ],
                      )
                    ],
                  ),
                ))
          ],
        ));
  }
}
