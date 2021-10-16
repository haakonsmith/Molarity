import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

import '../../../util.dart';

// Normalizes any number to an arbitrary range
// by assuming the range wraps around when going below min or above max
double normalize(double value, double start, double end) {
  final double width = end - start; //
  final double offsetValue = value - start; // value relative to 0

  return (offsetValue - ((offsetValue / width).floorToDouble() * width)) + start;
  // + start to reset back to start of original range
}

class TileData {
  TileData(this.idx) : color = Colors.primaries[idx % Colors.primaries.length];

  Color color;
  double x = 0, y = 0, z = 0, angle = 0;
  final int idx;
  double alpha = 0;

  Color get lightColor {
    final val = HSVColor.fromColor(color);
    return val.withSaturation(.5).withValue(.8).toColor();
  }
}

class HelixPeriodicTable extends StatefulWidget {
  const HelixPeriodicTable({Key? key}) : super(key: key);

  @override
  _HelixPeriodicTableState createState() => _HelixPeriodicTableState();
}

class _HelixPeriodicTableState extends State<HelixPeriodicTable> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  List<TileData> tileData = [];
  double radio = 200.0;
  double radioStep = 0;
  bool isMousePressed = false;

  double angle = 0;
  int selectedCard = 0;
  static int numItems = 118;

  final totalAngle = pi * (numItems / 10 * 2);

  @override
  void initState() {
    tileData = List.generate(numItems, (index) => TileData(index)).toList();
    radioStep = (totalAngle) / numItems;

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
  double selectCardAngle(int index) => -(index - 2) * radioStep + ((totalAngle / 2) / (tileData.length / 2)) / 2;
  // double normalise(double angle) => normaliseRange(angle, -pi, pi);

  // Normalizes any number to an arbitrary range
  // by assuming the range wraps around when going below min or above max
  double normaliseRange(double value, double start, double end) {
    final double width = end - start; //
    final double offsetValue = value - start; // value relative to 0

    return (offsetValue - ((offsetValue / width).floorToDouble() * width)) + start;
    // + start to reset back to start of original range
  }

  @override
  Widget build(BuildContext context) {
    // process positions.
    for (var i = 0; i < tileData.length; ++i) {
      final c = tileData[i];
      final ang = angle + c.idx * radioStep;
      c.angle = ang + pi / 2;
      c.x = cos(ang) * radio;
//      c.y = sin(ang) * 10;
      c.z = sin(ang) * radio;
    }

    // sort in Z axis.
    tileData.sort((a, b) => a.z.compareTo(b.z));

    final List<Widget> cardsToRender = [];

    // var list = tileData.mapIndexed((vo, index) {
    //   Widget child = addCard(vo);
    //   final mt2 = Matrix4.identity();

    //   mt2.setEntry(3, 2, 0.001);
    //   mt2.translate(vo.x, vo.idx * 15.0 + angle * 25 - 100, -vo.z);
    //   mt2.rotateY(vo.angle + pi);

    //   child = Transform(
    //     alignment: Alignment.center,
    //     origin: Offset(0.0, -100 - _scaleController.value * 200.0),
    //     transform: mt2,
    //     child: child,
    //   );

    //   return child;
    // }).toList();

    for (final vo in tileData) {
      Widget child = addCard(vo);
      final mt2 = Matrix4.identity();

      final y = vo.idx * 15.0 + angle * 25 - 100;
      // print(y);

      mt2.setEntry(3, 2, 0.001);
      mt2.translate(vo.x, y, -vo.z);
      mt2.rotateY(vo.angle + pi);

      child = Transform(
        alignment: Alignment.center,
        origin: Offset(0.0, -100 - _scaleController.value * 200.0),
        transform: mt2,
        child: child,
      );

      if (y < 80 && y > -350 && -vo.z < 60) cardsToRender.add(child);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (e) {
        isMousePressed = true;

        _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      },
      onPanUpdate: (e) {
        _rotationController.stop();

        angle += convertDragToAngleOffset(e.delta.dx);

        selectedCard = normaliseRange(-(normalise(angle) / ((totalAngle / 2) / (tileData.length / 2))).floor() + 2, 0, tileData.length.toDouble()).floor();

        setState(() {});
      },
      onPanEnd: (e) {
        _rotationController.value = angle;

        isMousePressed = false;

        print(selectCardAngle(selectedCard));

        _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
        _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      },
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: cardsToRender,
        ),
      ),
    );
  }

  Widget addCard(TileData vo) {
    var alpha = ((1 - vo.z / radio) / 2) * 1;

    final isSelected = vo.idx == selectedCard;

    final double darken = isSelected ? 0 : 0.2;

    return Container(
      // margin: const EdgeInsets.all(12),
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
      child: Consumer(
        builder: (context, ref, child) {
          return PeriodicTableTile(ref.watch(elementsBlocProvider).elements[vo.idx]);
        },
      ),
    );
  }
}
