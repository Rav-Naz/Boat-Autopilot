import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/providers/navigation_provider.dart';
import 'package:boat_autopilot/providers/settings_provider.dart';
import 'package:boat_autopilot/views/home.dart';
import 'package:boat_autopilot/views/map.dart';
import 'package:boat_autopilot/views/motor_panel.dart';
import 'package:boat_autopilot/views/page_navigation.dart';
import 'package:boat_autopilot/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/status_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(create: (BuildContext context) => NavigationProvider()),
        ChangeNotifierProvider<MapProvider>(create: (BuildContext context) => MapProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (BuildContext context) => SettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Autopilot',
        theme: ThemeData(
          fontFamily: 'Inter',
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
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
          child: Column(
            children: [
              const StatusBar(),
              SizedBox(
                height: MediaQuery.of(context).size.height-50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Consumer<NavigationProvider>(
                        builder: (context, navigationProvider, child) {
                          return PageView(
                          controller: navigationProvider.getPageController,
                          // scrollDirection: Axis.vertical,
                          onPageChanged: navigationProvider.onViewChanged,
                          children: [
                            HomeView(),
                            MapView(),
                            SettingsView()
                          ],
                        );
                        },
                      ),
                    ),
                    PageNavigationView(),
                    MotorPanelView(),
                  ],
                ),
              ),
            ],
          ),
          decoration: const BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Add one stop for each color. Stops should increase from 0 to 1
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Color.fromARGB(255, 28, 21, 45),
                Color.fromARGB(255, 17, 17, 36)
              ],
            ),
          )),
      backgroundColor: Colors.black,
    ));
  }
}
