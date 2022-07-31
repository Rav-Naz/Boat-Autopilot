import 'dart:async';

import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({
    Key? key,
  }) : super(key: key);

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late String _currentTimeString = "";
  late Timer _timer;

  @override
  void initState() {
    _getTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _getTime();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 50.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Consumer<MapProvider>(
              builder: (context, mapProvider, child) {
                return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        "LAT: ",
                        style: TextStyle(color: primary, fontSize: 14),
                      ),
                      Text(mapProvider.getCurrentPosition != null ? ((mapProvider.getCurrentPosition!.latitude > 0 ? "N" : "S") + " " + mapProvider.getCurrentPosition!.latitude.toString().replaceAll('.', '°')) : "--", style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      const Text(
                        "LONG: ",
                        style: TextStyle(color: primary, fontSize: 14),
                      ),
                      Text(mapProvider.getCurrentPosition != null ? ((mapProvider.getCurrentPosition!.longitude > 0 ? "E" : "W") + " " + mapProvider.getCurrentPosition!.longitude.toString().replaceAll('.', '°')) : "--", style: const TextStyle(color: Colors.white, fontSize: 18)),

                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ],
              );
              },
            ),
            Text(
              "Warning!",
              style: const TextStyle(color: Colors.amber, fontSize: 15),
            ),
            Text(
              _currentTimeString,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            )
          ]),
        ));
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _currentTimeString = formattedDateTime;
      });
    }
  }

  get getCurrentTimeString {
    return _currentTimeString;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm    dd.MM.yyyy').format(dateTime);
  }
}
