import 'package:auto_size_text/auto_size_text.dart';
import 'package:boat_autopilot/main.dart';
import 'package:boat_autopilot/providers/settings_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  List<Widget> buildSettings(context) {
    return [
    BipolarSwitchWidget(
      settingName: AppLocalizations.of(context)!.setting1,
      settingKey: 'setting1',
    ),
    PlusMinusWidget(
      settingName: AppLocalizations.of(context)!.setting2,
      settingKey: "setting2",
    ),
    ChooserWidget(
      options: const ["Polski", "English"],
      settingKey: "language",
      settingName: AppLocalizations.of(context)!.interface_language,
      callback: (context, value) {
        if (value == "Polski") {
          Provider.of<SettingsProvider>(context, listen: false).setLanguage("pl");
        }
        else if (value == "English") {
          Provider.of<SettingsProvider>(context, listen: false).setLanguage("en");
        }
      },
    ),
  ];
  }

  @override
  Widget build(BuildContext context) {
    var isOneColumn = MediaQuery.of(context).size.width < 1100;
    var settingsChilds = buildSettings(context);
    return Container(
        color: primaryDark,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isOneColumn ? 1 : 2,
              mainAxisExtent: 60,
              crossAxisSpacing: 35,
            ),
            shrinkWrap: true,
            itemCount: settingsChilds.length,
            itemBuilder: (context, index) => index % 2 == 0 && !isOneColumn
                ? Container(
                    child: settingsChilds[index],
                    decoration: const BoxDecoration(
                        border: Border(
                            right:
                                BorderSide(width: 2, color: primaryDarkest))),
                  )
                : settingsChilds[index]));
  }
}

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
                              color: Colors.white, fontSize: 15)))),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
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
                      iconSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                    width: 50,
                    child: AutoSizeText(
                      value.toString(),
                      maxLines: 1,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 25, 8),
                  child: Container(
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
                      iconSize: 20,
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

class ChooserWidget extends StatelessWidget {
  final List<String> options;
  String settingKey;
  String? settingName;
  Function? callback;

  ChooserWidget(
      {required this.settingKey, required this.options, this.settingName, this.callback});

  void chooseDialog(context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                actions: [
                  TextButton(
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent)
                        // foregroundColor: Colors.transparent
                        ),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: const TextStyle(color: accent, fontSize: 15),
                    ),
                    onPressed: () => {Navigator.of(context).pop()},
                  )
                ],
                backgroundColor: primaryDark,
                content: Column(
                  children: options
                      .map((e) => TextButton(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ),
                          onPressed: () {
                            Provider.of<SettingsProvider>(context,
                                    listen: false)
                                .setSetting(settingKey, e);
                            if (callback != null) {
                              callback!(context, e);
                            }
                            Navigator.of(context).pop();
                          }))
                      .toList(),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          var value = settingsProvider.getSetting(settingKey) ?? options[0];
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
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: GestureDetector(
                  onTap: () {
                    chooseDialog(context);
                  },
                  child: Container(
                      height: 40,
                      width: 130,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Center(
                            child: Text(value,
                          style: const TextStyle(
                              color: accent, fontSize: 14),
                        )),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primary, width: 1.2))),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
