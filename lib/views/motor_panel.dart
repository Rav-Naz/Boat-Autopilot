import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:boat_autopilot/widgets/bipolar_switch.dart';
import 'package:boat_autopilot/widgets/joystick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

import '../mqtt/mqtt_service.dart';
import '../widgets/bargraf.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MotorPanelView extends StatefulWidget {
  @override
  _MotorPanelViewState createState() => _MotorPanelViewState();
}

class _MotorPanelViewState extends State<MotorPanelView> {
  final _mqtt = MqttService();
  double turningSpeed = 0.0;
  bool manualMode = true;
  bool engineStarted = false;

  double acutalSpeedInKmPerHour = 0.0;

  double settedTwoEngineLoad = 0.0;
  double actualLeftEngingeLoad = 0.0;
  double actualRightEngingeLoad = 0.0;
  double settedLeftEngingeLoad = 0.0;
  double settedRightEngingeLoad = 0.0;

  double leftMotorVoltage = 0.0;
  double rightMotorVoltage = 0.0;
  double leftMotorAmperage = 0.0;
  double rightMotorAmperage = 0.0;

  @override
  void initState() {
    if (_mqtt.isConnected) {
      _subscribeAllTopics();
    } else {
      _mqtt.currentConnectionState.listen((state) {
        if (state == MqttConnectionState.connected) {
          _subscribeAllTopics();
        }
      });
    }
    super.initState();
  }

  void _subscribeAllTopics() {
    _mqtt.subscribe("boat/main/turning_speed")!.listen((event) {
      setState(() {
        turningSpeed = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/current_speed")!.listen((event) {
      setState(() {
        acutalSpeedInKmPerHour = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/l_motor_actual_load")!.listen((event) {
      setState(() {
        actualLeftEngingeLoad = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/r_motor_actual_load")!.listen((event) {
      setState(() {
        actualRightEngingeLoad = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/l_motor_setted_load")!.listen((event) {
      setState(() {
        settedLeftEngingeLoad = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/r_motor_setted_load")!.listen((event) {
      setState(() {
        settedRightEngingeLoad = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/r_motor_voltage")!.listen((event) {
      setState(() {
        rightMotorVoltage = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/l_motor_voltage")!.listen((event) {
      setState(() {
        leftMotorVoltage = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/r_motor_amperage")!.listen((event) {
      setState(() {
        rightMotorAmperage = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/main/l_motor_amperage")!.listen((event) {
      setState(() {
        leftMotorAmperage = double.parse(event);
      });
    });
  }

  void offEngine() {
    setState(() {
      engineStarted = false;
      settedLeftEngingeLoad = 0.0;
      settedRightEngingeLoad = 0.0;
      settedTwoEngineLoad = 0.0;
    });
    _mqtt.publish("boat/main/engine", engineStarted.toString());
    _mqtt.publish("boat/main/l_motor_setted_load",
        settedLeftEngingeLoad.toInt().toString());
    _mqtt.publish("boat/main/r_motor_setted_load",
        settedRightEngingeLoad.toInt().toString());
    _mqtt.publish("boat/main/both_motor_setted_load",
        settedTwoEngineLoad.toInt().toString());
  }

  int map(x, in_min, in_max, out_min, out_max) {
    return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)
        .floor();
  }

  @override
  Widget build(BuildContext context) {
    var joystick1 = JoyStick(
        radius: 100,
        stickRadius: 20,
        callback: (x, y) {
          var left = 0;
          var right = 0;
          // Lewa gora
          if (x <= 0 && y >= 0) {
            var throttle = map(y, 0, 100, 0, 75);
            var turn = map(x, -100, 0, -25, 0);
            left = throttle + turn;
            right = throttle - turn;
          }
          // Prawa gora
          else if (x >= 0 && y >= 0) {
            var throttle = map(y, 0, 100, 0, 75);
            var turn = map(x, 0, 100, 0, 25);
            left = throttle + turn;
            right = throttle - turn;
          }
          // Lewy dol
          else if (x <= 0 && y <= 0) {
            var throttle = map(y, -100, 0, -50, 0);
            var turn = map(x, -100, 0, -25, 0);
            left = throttle - turn;
            right = throttle + turn;
          }
          // Prawa dol
          else if (x >= 0 && y <= 0) {
            var throttle = map(y, -100, 0, -50, 0);
            var turn = map(x, 0, 100, 0, 25);
            left = throttle - turn;
            right = throttle + turn;
          }
          print('left: ${left}, right: ${right}');
          _mqtt.publish(
              "boat/main/l_motor_setted_load", left.toDouble().toString());
          _mqtt.publish(
              "boat/main/r_motor_setted_load", right.toDouble().toString());
        });
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.turning_speed,
                    style: const TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(
                  height: 5,
                ),
                BargrafWidget(
                  value: turningSpeed,
                  maxValue: 90.0,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 175,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: engineStarted
                            ? null
                            : () {
                                setState(() {
                                  engineStarted = true;
                                });
                                _mqtt.publish("boat/main/engine",
                                    engineStarted.toString());
                              },
                        style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory),
                        child: Container(
                            child: const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text(
                                "START",
                                style: TextStyle(color: accent, fontSize: 12),
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: accent))),
                      ),
                      TextButton(
                        onPressed: engineStarted
                            ? () {
                                joystick1.reset.call();
                                offEngine();
                              }
                            : null,
                        child: Container(
                            child: const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text(
                                "STOP",
                                style: TextStyle(color: primary, fontSize: 12),
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: primary))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(AppLocalizations.of(context)!.steerage,
                    style: const TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                Consumer<MapProvider>(builder: (context, mapProvider, child) {
                  return BipolarSwitchWidget(
                    settingKey: "sterowanie",
                    name1: "AUTO",
                    name2: "MAN",
                    enabled: true,
                    // mapProvider.getNavigationMarkerPointsList.isNotEmpty ||
                    // !manualMode,
                    initialValue: manualMode,
                    callback: (value, setting) {
                      setState(() {
                        manualMode = value;
                        _mqtt.publish(
                            "boat/main/stering_mode", manualMode.toString());
                      });
                    },
                  );
                }),
                Opacity(
                  // opacity: 1,
                  opacity: engineStarted ? 1 : 0.4,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AbsorbPointer(
                          absorbing: !engineStarted,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: joystick1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(pi),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SvgPicture.asset(
                                            "assets/svg/fan.svg",
                                            color: primary,
                                          )),
                                    ),
                                    AutoSizeText(
                                      AppLocalizations.of(context)!
                                          .engine_load_l,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    AutoSizeText(
                                        (settedLeftEngingeLoad)
                                                .toInt()
                                                .toString() +
                                            "%",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      AppLocalizations.of(context)!
                                          .actual_speed,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    AutoSizeText(
                                        acutalSpeedInKmPerHour
                                                .toInt()
                                                .toString() +
                                            " km/h",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          "assets/svg/fan.svg",
                                          color: primary,
                                        )),
                                    AutoSizeText(
                                      AppLocalizations.of(context)!
                                          .engine_load_r,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    AutoSizeText(
                                        (settedRightEngingeLoad)
                                                .toInt()
                                                .toString() +
                                            "%",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                )
              ],
            ),
            SizedBox(
              width: 230,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MotorPanel(
                      description: "L MOTOR",
                      voltage: leftMotorVoltage,
                      amperage: leftMotorAmperage,
                      engineLoad: actualLeftEngingeLoad),
                  MotorPanel(
                    description: "R MOTOR",
                    voltage: rightMotorVoltage,
                    amperage: rightMotorAmperage,
                    engineLoad: actualRightEngingeLoad,
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class MotorPanel extends StatelessWidget {
  double voltage;
  double amperage;
  String description;
  double engineLoad;

  MotorPanel(
      {required this.description,
      required this.voltage,
      required this.amperage,
      required this.engineLoad});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          description.toUpperCase(),
          style: const TextStyle(
              color: primary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
            "${voltage.toStringAsFixed(1)} V | ${amperage.toStringAsFixed(1)} A",
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        const SizedBox(height: 2),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: const [accent, primaryDark],
                  stops: [getPercentageLoad, getPercentageLoad]),
              borderRadius: BorderRadius.circular(30)),
        ),
        const SizedBox(height: 2),
        Text(
          engineLoad.toInt().toString() + "%",
          style: const TextStyle(color: Colors.white, fontSize: 10),
        )
      ],
    );
  }

  get getPercentageLoad {
    return engineLoad.abs() / 100;
  }
}
