import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../shared/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChooserWidget extends StatelessWidget {
  final List<String> options;
  String settingKey;
  String? settingName;
  Function? callback;

  ChooserWidget(
      {required this.settingKey,
      required this.options,
      this.settingName,
      this.callback});

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
                      style: const TextStyle(color: accent, fontSize: 12),
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
                                  color: Colors.white, fontSize: 12),
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
                              color: Colors.white, fontSize: 12)))),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: GestureDetector(
                  onTap: () {
                    chooseDialog(context);
                  },
                  child: Container(
                      height: 35,
                      width: 120,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Center(
                            child: Text(
                          value,
                          style: const TextStyle(color: accent, fontSize: 13),
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
