import 'package:boat_autopilot/shared/colors.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as Math;

class JoyStick extends StatefulWidget {
  final double radius;
  final double stickRadius;
  final Function callback;
  void Function() reset = () {};

  JoyStick(
      {Key? key,
      required this.radius,
      required this.stickRadius,
      required this.callback})
      : super(key: key);

  @override
  _JoyStickState createState() => _JoyStickState();
}

class _JoyStickState extends State<JoyStick> {
  final GlobalKey _joyStickContainer = GlobalKey();
  double yOff = 0, xOff = 0;
  double _x = 0, _y = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RenderBox renderBoxWidget =
          _joyStickContainer.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBoxWidget.localToGlobal(Offset.zero);

      xOff = offset.dx;
      yOff = offset.dy;
    });

    _centerStick();
  }

  void _centerStick() {
    setState(() {
      _x = widget.radius;
      _y = widget.radius;
    });

    _sendCoordinates(_x, _y);
  }

  int map(x, in_min, in_max, out_min, out_max) {
    return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)
        .floor();
  }

  void _onPointerMove(PointerEvent details) {
    var x = details.position.dx - widget.radius - xOff;
    var y = details.position.dy - widget.radius - yOff;
    final isPointInCircle = x * x + y * y < widget.radius * widget.radius;
    if (!isPointInCircle) {
      final mult = Math.sqrt(widget.radius * widget.radius / (y * y + x * x));
      x *= mult;
      y *= mult;
    }

    final xOffset = x + widget.radius;
    final yOffset = y + widget.radius;

    setState(() {
      _x = xOffset;
      _y = yOffset;
    });
    _sendCoordinates(xOffset, yOffset);
  }

  void _sendCoordinates(double x, double y) {
    double speed = y - widget.radius;
    double direction = x - widget.radius;

    var vSpeed = -1 * map(speed, 0, (widget.radius).floor(), 0, 100);
    var vDirection = map(direction, 0, (widget.radius).floor(), 0, 100);

    widget.callback(vDirection, vSpeed);
  }

  isStickInside(x, y, circleX, circleY, circleRadius) {
    var absX = Math.pow((x - circleX).abs(), 2.0);
    var absY = Math.pow((y - circleY).abs(), 2.0);
    return Math.sqrt(absX + absY) < circleRadius;
  }

  Widget build(BuildContext context) {
    widget.reset = () {
      _centerStick();
    };
    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerMove: _onPointerMove,
        child: Container(
          key: _joyStickContainer,
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(color: primary, width: 2)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  child: SizedBox(
                    child: const Center(child: DottedLine(dashColor: primary)),
                    height: widget.radius * 2,
                    width: widget.radius * 2,
                  ),
                  left: 0,
                  top: 0),
              Positioned(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: SizedBox(
                      child:
                          const Center(child: DottedLine(dashColor: primary)),
                      height: widget.radius * 2,
                      width: widget.radius * 2,
                    ),
                  ),
                  left: 0,
                  top: 0),
              Positioned(
                left: _x - widget.stickRadius,
                top: _y - widget.stickRadius,
                child: Container(
                  width: widget.stickRadius * 2,
                  height: widget.stickRadius * 2,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(widget.stickRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
