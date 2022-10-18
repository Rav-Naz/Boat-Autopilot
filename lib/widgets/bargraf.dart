import 'package:auto_size_text/auto_size_text.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';

class BargrafWidget extends StatelessWidget {
  double value;
  double maxValue;

  BargrafWidget({
    required this.value,
    required this.maxValue,
    Key? key,
  }) : super(key: key);

  List<Widget> buildBargraf(context, constraints) {
    var halfSize = constraints.maxWidth * 0.5;
    var percentage = (value / maxValue).abs().clamp(0, 1).toDouble() * halfSize;
    var children = [
      Visibility(
        visible: value != 0.0,
        child: SizedBox(
          width: halfSize,
          child: Row(
            mainAxisAlignment: value.isNegative
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              SizedBox(
                width: percentage,
                child: Container(
                    decoration: BoxDecoration(
                        color: value.isNegative ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.only(
                          topLeft: value.isNegative
                              ? const Radius.circular(50)
                              : const Radius.circular(0),
                          bottomLeft: value.isNegative
                              ? const Radius.circular(50)
                              : const Radius.circular(0),
                          topRight: value.isNegative
                              ? const Radius.circular(0)
                              : const Radius.circular(50),
                          bottomRight: value.isNegative
                              ? const Radius.circular(0)
                              : const Radius.circular(50),
                        ))),
              )
            ],
          ),
        ),
      ),
      SizedBox(
        width: halfSize,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AutoSizeText(
            (value).toString() + "°/min",
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, height: 1.25),
          ),
        ),
      )
    ];
    return value.isNegative ? children : children.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      height: 25,
      width: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildBargraf(context, constraints),
          );
        }),
      ),
    );
  }
}
