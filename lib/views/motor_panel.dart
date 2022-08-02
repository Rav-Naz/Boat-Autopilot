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

  double twoEngineLoad = 0.0;
  double actualLeftEngingeLoad = 0.0;
  double actualRightEngingeLoad = 0.0;
  double settedLeftEngingeLoad = 0.0;
  double settedRightEngingeLoad = 0.0;

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
    _mqtt.subscribe("boat/angle")!.listen((event) {
      setState(() {
        turningSpeed = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/actual_speed")!.listen((event) {
      setState(() {
        acutalSpeedInKmPerHour = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/l_motor_actual_load")!.listen((event) {
      setState(() {
        actualLeftEngingeLoad = double.parse(event);
      });
    });
    _mqtt.subscribe("boat/r_motor_actual_load")!.listen((event) {
      setState(() {
        actualRightEngingeLoad = double.parse(event);
      });
    });
  }

  void offEngine() {
    setState(() {
      engineStarted = false;
      settedLeftEngingeLoad = 0.0;
      settedRightEngingeLoad = 0.0;
      twoEngineLoad = 0.0;
    });
    _mqtt.publish("boat/engine", engineStarted.toString());
    _mqtt.publish(
        "boat/l_motor_setted_load", settedLeftEngingeLoad.toInt().toString());
    _mqtt.publish(
        "boat/r_motor_setted_load", settedRightEngingeLoad.toInt().toString());
    _mqtt.publish(
        "boat/both_motor_setted_load", twoEngineLoad.toInt().toString());
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(
                  height: 10,
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
                                _mqtt.publish(
                                    "boat/engine", engineStarted.toString());
                              },
                        style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory),
                        child: Container(
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "START",
                                style: TextStyle(color: accent),
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: accent))),
                      ),
                      TextButton(
                        onPressed: engineStarted
                            ? offEngine
                            : null,
                        child: Container(
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "STOP",
                                style: TextStyle(color: primary),
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
                  height: 10,
                ),
                Text(AppLocalizations.of(context)!.steerage,
                    style: const TextStyle(
                        color: primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Consumer<MapProvider>(
                  builder: (context, mapProvider, child) {
                    return BipolarSwitchWidget(
                    settingKey: "sterowanie",
                    name1: "AUTO",
                    name2: "MAN",
                    enabled: mapProvider.getNavigationMarkerPointsList.isNotEmpty || !manualMode,
                    initialValue: manualMode,
                    callback: (value, setting) {
                      setState(() {
                        manualMode = value;
                        _mqtt.publish("boat/stering_mode", manualMode.toString());
                      });
                    },
                  );
                  }
                  ),
                Opacity(
                  opacity: engineStarted ? 1 : 0.4,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
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
                                    padding: const EdgeInsets.all(7.0),
                                    child: Row(
                                      children: [
                                        Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(pi),
                                            child: SizedBox(
                                                width: 30,
                                                height: 30,
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
                                              0.40,
                                      child: Slider(
                                        min: -50.0,
                                        max: 100.0,
                                        value: settedLeftEngingeLoad,
                                        onChanged: engineStarted
                                            ? (value) {
                                                setState(() {
                                                  settedLeftEngingeLoad = value;
                                                  _mqtt.publish(
                                                      "boat/l_motor_setted_load",
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
                                                fontSize: 13,
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
                                                  fontSize: 15)),
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
                                                fontSize: 13,
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
                                                  fontSize: 15)),
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
                                                fontSize: 13,
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
                                                  fontSize: 15)),
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
                                    padding: const EdgeInsets.all(7.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 30,
                                            height: 30,
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
                                              0.40,
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
                                                      "boat/r_motor_setted_load",
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    AutoSizeText(
                                        (twoEngineLoad).toInt().toString() +
                                            "%",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15)),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: Row(
                                      children: [
                                        Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(pi),
                                            child: SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: SvgPicture.asset(
                                                  "assets/svg/fan.svg",
                                                  color: primary,
                                                ))),
                                        SizedBox(
                                            width: 30,
                                            height: 30,
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
                                              0.45,
                                      child: Slider(
                                        min: -50.0,
                                        max: 100.0,
                                        value: twoEngineLoad,
                                        onChanged: engineStarted
                                            ? (value) {
                                                setState(() {
                                                  twoEngineLoad = value;
                                                  _mqtt.publish(
                                                      "boat/both_motor_setted_load",
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    AutoSizeText(
                                        acutalSpeedInKmPerHour
                                                .toInt()
                                                .toString() +
                                            " km/h",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15)),
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
                      voltage: 14.2,
                      amperage: 16.0,
                      engineLoad: actualLeftEngingeLoad),
                  MotorPanel(
                    description: "R MOTOR",
                    voltage: 14.6,
                    amperage: 16.7,
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
              color: primary, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
            "${voltage.toStringAsFixed(1)} V | ${amperage.toStringAsFixed(1)} A",
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 3),
        Container(
          height: 7,
          width: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: const [accent, primaryDark],
                  stops: [getPercentageLoad, getPercentageLoad]),
              borderRadius: BorderRadius.circular(30)),
        ),
        const SizedBox(height: 3),
        Text(
          engineLoad.toInt().toString() + "%",
          style: const TextStyle(color: Colors.white, fontSize: 13),
        )
      ],
    );
  }

  get getPercentageLoad {
    return engineLoad / 100;
  }
}
