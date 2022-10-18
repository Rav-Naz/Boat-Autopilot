import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../shared/colors.dart';

class PlusMinusWidget extends StatelessWidget {
  String settingKey;
  double step;
  double defaultValue;
  String? settingName;

  PlusMinusWidget({
    required this.settingKey,
    this.settingName,
    this.defaultValue = 0.0,
    this.step = 1.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          var value = double.parse(settingsProvider.getSetting(settingKey) ??
              defaultValue.toString());
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                  visible: settingName != null,
                  child: Expanded(
                      child: AutoSizeText(settingName ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)))),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(400),
                        color: primaryDarkest),
                    child: IconButton(
                      onPressed: () {
                        value = value - step;
                        settingsProvider.setSetting(
                            settingKey, value.toString());
                      },
                      icon: const Icon(Icons.remove),
                      color: accent,
                      iconSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                    width: 50,
                    child: AutoSizeText(
                      value.toString(),
                      maxLines: 1,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 25, 8),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(400),
                        color: primaryDarkest),
                    child: IconButton(
                      onPressed: () {
                        value = value + step;
                        settingsProvider.setSetting(
                            settingKey, value.toString());
                      },
                      icon: const Icon(Icons.add),
                      color: accent,
                      iconSize: 15,
                    ),
                  ),
                )
              ]),
            ],
          );
        },
      ),
    );
  }
}
