import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:boat_autopilot/widgets/bipolar_switch.dart';
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

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                        onPressed: engineStarted ? offEngine : null,
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
                    enabled:
                        mapProvider.getNavigationMarkerPointsList.isNotEmpty ||
                            !manualMode,
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
                  opacity: 1,
                  // opacity: engineStarted ? 1 : 0.4,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: manualMode
                          ? [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
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
                                                ))),
                                      ],
                                    ),
                                  ),
                                  RotatedBox(
                                    quarterTurns: -1,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: Slider(
                                        min: -50.0,
                                        max: 100.0,
                                        value: settedLeftEngingeLoad,
                                        onChanged: engineStarted
                                            ? (value) {
                                                setState(() {
                                                  settedLeftEngingeLoad = value;
                                                  _mqtt.publish(
                                                      "boat/main/l_motor_setted_load",
                                                      settedLeftEngingeLoad
                                                          .toInt()
                                                          .toString());
                                                });
                                              }
                                            : null,
                                        activeColor: accent,
                                        inactiveColor: primaryDark,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 9),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
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
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
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
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: SvgPicture.asset(
                                              "assets/svg/fan.svg",
                                              color: primary,
                                            )),
                                      ],
                                    ),
                                  ),
                                  RotatedBox(
                                    quarterTurns: -1,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: Slider(
                                        min: -50.0,
                                        max: 100.0,
                                        value: settedRightEngingeLoad,
                                        onChanged: engineStarted
                                            ? (value) {
                                                setState(() {
                                                  settedRightEngingeLoad =
                                                      value;
                                                  _mqtt.publish(
                                                      "boat/main/r_motor_setted_load",
                                                      settedRightEngingeLoad
                                                          .toInt()
                                                          .toString());
                                                });
                                              }
                                            : null,
                                        activeColor: accent,
                                        inactiveColor: primaryDark,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ]
                          : [
                              SizedBox(
                                width: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      AppLocalizations.of(context)!.engine_load,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    AutoSizeText(
                                        (settedTwoEngineLoad)
                                                .toInt()
                                                .toString() +
                                            "%",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
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
                                                ))),
                                        SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: SvgPicture.asset(
                                              "assets/svg/fan.svg",
                                              color: primary,
                                            )),
                                      ],
                                    ),
                                  ),
                                  RotatedBox(
                                    quarterTurns: -1,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.33,
                                      child: Slider(
                                        min: -50.0,
                                        max: 100.0,
                                        value: settedTwoEngineLoad,
                                        onChanged: engineStarted
                                            ? (value) {
                                                setState(() {
                                                  settedTwoEngineLoad = value;
                                                  _mqtt.publish(
                                                      "boat/main/both_motor_setted_load",
                                                      settedTwoEngineLoad
                                                          .toInt()
                                                          .toString());
                                                });
                                              }
                                            : null,
                                        activeColor: accent,
                                        inactiveColor: primaryDark,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 70,
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
                                    const SizedBox(height: 2),
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
                            ],
                    ),
                  ),
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
