import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../shared/colors.dart';

class BipolarSwitchWidget extends StatelessWidget {
  String name1;
  String name2;
  String settingKey;
  String? settingName;

  BipolarSwitchWidget({
    this.name1 = "OFF",
    this.name2 = "ON",
    required this.settingKey,
    this.settingName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          var value = settingsProvider.getSetting(settingKey) == 'true';
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                  visible: settingName != null,
                  child: Expanded(
                      child: AutoSizeText(settingName ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15)))),
              GestureDetector(
                onTap: () {
                  settingsProvider.setSetting(settingKey, (!value).toString());
                },
                child: Row(
                  children: [
                    SizedBox(
                        width: 60,
                        child: AutoSizeText(
                          name1,
                          maxLines: 1,
                          style: TextStyle(
                              color: (value) ? primary : accent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                          width: 60,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: primary),
                                borderRadius: BorderRadius.circular(100)),
                            child: Stack(children: [
                              AnimatedPositioned(
                                top: 5,
                                bottom: 5,
                                left: (value) ? 35 : 5,
                                right: (value) ? 5 : 35,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                duration: const Duration(milliseconds: 100),
                              )
                            ]),
                          )),
                    ),
                    SizedBox(
                        width: 60,
                        child: AutoSizeText(
                          name2,
                          maxLines: 1,
                          style: TextStyle(
                              color: !(value) ? primary : accent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}