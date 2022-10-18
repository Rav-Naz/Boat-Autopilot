import 'dart:async';

import 'package:boat_autopilot/providers/map_provider.dart';
import 'package:boat_autopilot/providers/messages_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Widget messageBuilder(context) {
    return Consumer<MessagesProvider>(
      builder: (context, messageProvider, child) {
        var message = messageProvider.getLastMessage;
        Color color = Colors.white;
        String text = "";
        if (message != null) {
          switch (message.type) {
            case "ERR":
              color = Colors.red;
              break;
            case "WAR":
              color = Colors.amber;
              break;
            case "INF":
              color = Colors.white;
              break;
            default:
              color = Colors.white;
          }
          switch (message.code) {
            case "1":
              text = AppLocalizations.of(context)!.message1;
              break;
            case "2":
              text = AppLocalizations.of(context)!.message2;
              break;
            default:
              text = "";
          }
        }
        return Text(
          text,
          style: TextStyle(color: color, fontSize: 15),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 30.0,
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
                        Text(
                          AppLocalizations.of(context)!.lat,
                          style: const TextStyle(color: primary, fontSize: 12),
                        ),
                        Text(
                            mapProvider.getCurrentPosition != null
                                ? ((mapProvider.getCurrentPosition!.latitude > 0
                                        ? "N"
                                        : "S") +
                                    " " +
                                    mapProvider.getCurrentPosition!.latitude
                                        .toStringAsFixed(4)
                                        .replaceAll('.', '°'))
                                : "--",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.long,
                          style: const TextStyle(color: primary, fontSize: 12),
                        ),
                        Text(
                            mapProvider.getCurrentPosition != null
                                ? ((mapProvider.getCurrentPosition!.longitude >
                                            0
                                        ? "E"
                                        : "W") +
                                    " " +
                                    mapProvider.getCurrentPosition!.longitude
                                        .toStringAsFixed(4)
                                        .replaceAll('.', '°'))
                                : "--",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ],
                );
              },
            ),
            messageBuilder(context),
            Text(
              _currentTimeString,
              style: const TextStyle(color: Colors.white, fontSize: 12),
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
