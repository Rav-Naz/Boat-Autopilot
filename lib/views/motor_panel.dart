import 'package:flutter/material.dart';

class MotorPanelView extends StatefulWidget {
  @override
  _MotorPanelViewState createState() => _MotorPanelViewState();
}

class _MotorPanelViewState extends State<MotorPanelView> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300.0,
        ),
        child: Container(
          color: Colors.transparent,
        ));
  }
}
