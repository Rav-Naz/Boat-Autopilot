import 'dart:math';

import 'package:boat_autopilot/views/home.dart';
import 'package:boat_autopilot/views/motor_panel.dart';
import 'package:boat_autopilot/views/page_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Autopilot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        child: Center(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(children: [
                Expanded(child: HomeView()),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 70.0,
                  ),
                  child: PageNavigationView(),
                )
              ]),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200.0,
              ),
              child: MotorPanelView(),
            ),
          ],
        )),
        decoration: const BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Color.fromARGB(255, 48, 48, 48),
            Color.fromARGB(255, 29, 29, 29)
          ],
        ),
      )
      ),
      backgroundColor: Colors.black,
    )
    );
  }
}
