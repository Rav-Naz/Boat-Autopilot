import 'package:boat_autopilot/providers/settings_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:boat_autopilot/widgets/joystick.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/bipolar_switch.dart';
import '../widgets/chooser.dart';
import '../widgets/plus_minus.dart';

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
            Provider.of<SettingsProvider>(context, listen: false)
                .setLanguage("pl");
          } else if (value == "English") {
            Provider.of<SettingsProvider>(context, listen: false)
                .setLanguage("en");
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
