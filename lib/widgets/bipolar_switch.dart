import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../shared/colors.dart';

class BipolarSwitchWidget extends StatefulWidget {
  String name1;
  String name2;
  String settingKey;
  String? settingName;
  Function? callback;
  bool? initialValue;
  bool enabled;

  BipolarSwitchWidget({
    this.name1 = "OFF",
    this.name2 = "ON",
    required this.settingKey,
    this.settingName,
    this.callback,
    this.initialValue,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  State<BipolarSwitchWidget> createState() => _BipolarSwitchWidgetState();
}

class _BipolarSwitchWidgetState extends State<BipolarSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          var value = widget.initialValue ??
              settingsProvider.getSetting(widget.settingKey) == 'true';
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                  visible: widget.settingName != null,
                  child: Expanded(
                      child: AutoSizeText(widget.settingName ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)))),
              GestureDetector(
                onTap: widget.enabled
                    ? () {
                        if (widget.callback != null) {
                          setState(() {
                            widget.initialValue = !widget.initialValue!;
                          });
                          widget.callback!(
                              widget.initialValue, widget.settingKey);
                        } else {
                          settingsProvider.setSetting(
                              widget.settingKey, (!value).toString());
                        }
                      }
                    : null,
                child: Row(
                  children: [
                    SizedBox(
                        width: 60,
                        child: AutoSizeText(
                          widget.name1,
                          maxLines: 1,
                          style: TextStyle(
                              color: (value) ? primary : accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        )),
                    Transform.scale(
                      scale: 0.8,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                            width: 60,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Stack(children: [
                                AnimatedPositioned(
                                  top: 5,
                                  bottom: 5,
                                  left: (value) ? 35 : 5,
                                  right: (value) ? 5 : 35,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  duration: const Duration(milliseconds: 100),
                                )
                              ]),
                            )),
                      ),
                    ),
                    SizedBox(
                        width: 60,
                        child: AutoSizeText(
                          widget.name2,
                          maxLines: 1,
                          style: TextStyle(
                              color: !(value) ? primary : accent,
                              fontSize: 12,
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
