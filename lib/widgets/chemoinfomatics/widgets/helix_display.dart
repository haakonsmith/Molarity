import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

class HelixCard {
  HelixCard(this.idx) : color = Colors.primaries[idx % Colors.primaries.length];

  Color color;
  double x = 0, y = 0, z = 0, angle = 0;
  final int idx;
  double alpha = 0;

  Color get lightColor {
    final val = HSVColor.fromColor(color);
    return val.withSaturation(.5).withValue(.8).toColor();
  }
}

class Helix extends StatefulWidget {
  const Helix({this.children, Key? key}) : super(key: key);

  final List<Widget>? children;

  @override
  _HelixState createState() => _HelixState();
}

class _HelixState extends State<Helix> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  List<HelixCard> cards = [];

  bool isMousePressed = false;
  double angle = pi / 2;

  late final double radioStep;
  final double radio = 200.0;
  late final double totalAngle;

  int selectedCard = 0;

  @override
  void initState() {
    totalAngle = pi * (widget.children!.length / 10 * 2);

    cards = List.generate(widget.children!.length, (index) => HelixCard(index)).toList();
    radioStep = (totalAngle) / widget.children!.length;

    _scaleController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleController.addListener(() => setState(() {}));

    _rotationController = AnimationController(value: 0, upperBound: 2000, lowerBound: -2000, duration: const Duration(milliseconds: 500), vsync: this);
    _rotationController.addListener(() {
      if (!isMousePressed)
        setState(() {
          angle = _rotationController.value;
        });
    });

    super.initState();
  }

  // Radians
  // double convertDragToAngleOffset(double panX) => normalise(pi / 2 + (-panX * .006));
  double convertDragToAngleOffset(double panX) => (-panX * .006);

  double normalise(double angle) => angle - (angle / (totalAngle)).floorToDouble() * totalAngle;
  double selectCardAngle(int index) => -(index - 2) * radioStep + ((totalAngle / 2) / (cards.length / 2)) / 2;

  // Normalizes any number to an arbitrary range
  // by assuming the range wraps around when going below min or above max
  double normaliseRange(double value, double start, double end) {
    final double width = end - start; //
    final double offsetValue = value - start; // value relative to 0

    return (offsetValue - ((offsetValue / width).floorToDouble() * width)) + start;
    // + start to reset back to start of original range
  }

  void processCardData() {
    for (var i = 0; i < cards.length; ++i) {
      final card = cards[i];
      final ang = angle + card.idx * radioStep;

      card.angle = ang + pi / 2;
      card.x = cos(ang) * radio;
      // c.y = sin(ang) * 10;
      card.z = sin(ang) * radio;
    }
  }

  /// This gets and sorts all the widgets to render.
  List<Widget> cardsToRender() {
    final List<Widget> cardsToRender = [];

    for (final card in cards) {
      final y = card.idx * 15.0 + angle * 25 - 100;

      if (y < 80 && y > -350 && -card.z < 60) {
        final mt2 = Matrix4.identity();

        mt2.setEntry(3, 2, 0.0005);
        mt2.translate(card.x, y, -card.z);
        mt2.rotateY(card.angle + pi);
        mt2.scale(0.95, 0.95);

        Widget child = _buildHelixWidget(card);
        child = Transform(
          alignment: Alignment.center,
          origin: Offset(0.0, -100 - _scaleController.value * 200.0),
          transform: mt2,
          child: child,
        );

        cardsToRender.add(child);
      }
    }
    return cardsToRender;
  }

  @override
  Widget build(BuildContext context) {
    // process positions.
    processCardData();

    // sort in Z axis.
    cards.sort((a, b) => a.z.compareTo(b.z));

    final cardsToRender = cardsToRender();

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // do something when scrolled
          // print('Scrolled');
          // print(pointerSignal.scrollDelta);
          if (100 % pointerSignal.scrollDelta.dy > 1) selectedCard += (pointerSignal.scrollDelta.dy).sign.toInt();

          if (selectedCard > cards.length - 1) selectedCard = selectedCard - 1;
          if (selectedCard < 0) selectedCard = 0;
          // angle += convertDragToAngleOffset(pointerSignal.scrollDelta.dy);
          // selectedCard = normaliseRange(-(normalise(angle) / ((totalAngle / 2) / (tileData.length / 2))).floor() + 2, 0, tileData.length.toDouble()).floor();
          // _rotationController.value = angle;
          _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

          setState(() {});
        }
        if (pointerSignal is PointerEnterEvent) {}
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (e) {
          isMousePressed = true;

          _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
        },
        onPanUpdate: (e) {
          _rotationController.stop();

          angle += convertDragToAngleOffset(e.delta.dx);

          if (e.delta.dy * e.delta.dy > 25) {
            final yaddition = ((e.delta.dy.abs()) / 20).round() * radioStep * 1 * e.delta.dy.sign;
            print((yaddition + angle) < totalAngle);

            if ((yaddition + angle) < 0) angle += yaddition;
            if ((yaddition + angle) < totalAngle) angle += yaddition;
          }

          selectedCard = normaliseRange(-(normalise(angle) / ((totalAngle / 2) / (cards.length / 2))).floor() + 2, 0, cards.length.toDouble()).floor();

          setState(() {});
        },
        onPanEnd: (e) {
          _rotationController.value = angle;

          isMousePressed = false;

          print(selectCardAngle(selectedCard));

          _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
          _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
        },
        child: Transform.scale(
          scale: 0.7,
          child: Container(
            height: 200,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: cardsToRender,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelixWidget(HelixCard card) {
    final alpha = ((1 - card.z / radio) / 2) * 1;

    final isSelected = card.idx == selectedCard;

    final double darken = isSelected ? 0 : 0.2;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(alpha),
          ),
          decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     stops: const [0.1, .9],
            //     colors: [vo.lightColor.darken(darken), vo.color.darken(darken)],
            //   ),
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? Border.all(color: Colors.white) : null,
            //   boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2 + alpha * .2), spreadRadius: 1, blurRadius: 12, offset: Offset(0, 2))],
          ),
          child: widget.children?[card.idx],
        ),
      ),
    );
  }
}
