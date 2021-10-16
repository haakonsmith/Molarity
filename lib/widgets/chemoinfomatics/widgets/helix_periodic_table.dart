import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../util.dart';

int numItems = 40;
var onSelectCard = ValueNotifier<int>(0);

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
  double _dragX = 0;
  double angle = 0;
  int selectedCard = 0;

  final totalAngle = pi * 8;

  @override
  void initState() {
    tileData = List.generate(numItems, (index) => TileData(index)).toList();
    radioStep = (totalAngle) / numItems;

    _scaleController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleController.addListener(() => setState(() {}));

    onSelectCard.addListener(() {
      final idx = onSelectCard.value;
      _dragX = 0;
      angle = -idx * radioStep;
      setState(() {});
    });

    _rotationController = AnimationController(value: 0, upperBound: 2000, lowerBound: -2000, duration: const Duration(milliseconds: 500), vsync: this);
    _rotationController.addListener(() {
      if (!isMousePressed)
        setState(() {
          // print(_panController.value);
          angle = _rotationController.value;
        });
    });

    super.initState();
  }

  // Radians
  // double convertDragToAngleOffset(double panX) => normalise(pi / 2 + (-panX * .006));
  double convertDragToAngleOffset(double panX) => (-panX * .006);

  double normalise(double angle) => angle - (angle / (totalAngle)).floorToDouble() * totalAngle;
  // double normalise(double angle) => normaliseRange(angle, -pi, pi);

  // Normalizes any number to an arbitrary range
  // by assuming the range wraps around when going below min or above max
  double normaliseRange(double value, double start, double end) {
    final double width = end - start; //
    final double offsetValue = value - start; // value relative to 0

    return (offsetValue - ((offsetValue / width).floorToDouble() * width)) + start;
    // + start to reset back to start of original range
  }

  // double normalise(double angle) {
  //   final itemIndex = (convertDragToAngleOffset(angle) / (2 * pi / tileData.length)).floorToDouble();
  //   print(itemIndex);
  //   // print(convertDragToAngleOffset(angle));

  //   // final _dragX = 0;
  //   final selectedAngle = -itemIndex * radioStep;

  //   return selectedAngle;

  //   // return initAngleOffset + itemIndex * radioStep;
  // }

  @override
  Widget build(BuildContext context) {
    // var initAngleOffset = convertDragToAngleOffset(_dragX);
    // initAngleOffset += selectedAngle;

    // process positions.
    for (var i = 0; i < tileData.length; ++i) {
      final c = tileData[i];
      final ang = angle + c.idx * radioStep;
      c.angle = ang + pi / 2;
      c.x = cos(ang) * radio;
//      c.y = sin(ang) * 10;
      c.z = sin(ang) * radio;
    }

    // final indices = List.generate(tileData.length, (i) => i);

    // sort in Z axis.
    tileData.sort((a, b) => a.z.compareTo(b.z));
    // final sortedTiles = List.from(tileData);
    // sortedTiles.sort((a, b) => a.z.compareTo(b.z));

    var list = tileData.mapIndexed((vo, index) {
      var c = addCard(vo);
      var mt2 = Matrix4.identity();

      mt2.setEntry(3, 2, 0.001);
      mt2.translate(vo.x, vo.idx * 10.0 + angle * 20 - 100, -vo.z);
      mt2.rotateY(vo.angle + pi);
      c = Transform(
        alignment: Alignment.center,
        origin: Offset(0.0, -100 - _scaleController.value * 200.0),
        transform: mt2,
        child: c,
      );

      // depth of field... doesnt work on web.
//      var blur = .4 + ((1 - vo.z / radio) / 2) * 2;
//      c = BackdropFilter(
//        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
//        child: c,
//      );

      return c;
    }).toList();

    // return Container(
    //   alignment: Alignment.center,
    //   child: Stack(
    //     alignment: Alignment.center,
    //     children: list,
    //   ),
    // );

    double selectCardAngle(int index) => -(index - 2) * radioStep + ((totalAngle / 2) / (tileData.length / 2)) / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (e) {
        isMousePressed = true;

        _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      },
      onPanUpdate: (e) {
        _rotationController.stop();

        // _dragX += e.delta.dx;

        angle += convertDragToAngleOffset(e.delta.dx);

        print(angle);
        // print(_dragX);
        selectedCard = normaliseRange(-(normalise(angle) / ((totalAngle / 2) / (tileData.length / 2))).floor() + 2, 0, tileData.length.toDouble()).floor();
        setState(() {});
      },
      onPanEnd: (e) {
        _rotationController.value = angle;
        // angle = normalise(angle);
        print("\n Drag end \n" + tileData.length.toString());
        // angle = convertDragToAngleOffset(_dragX);
        print("Selected angle: " + angle.toString());
        print("Selected card: " + selectedCard.toString());
        // print(_dragX);

        // _dragX = normalise(_dragX);
        isMousePressed = false;
        print(selectCardAngle(selectedCard));
        _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
        _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      },
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: list,
        ),
      ),
    );
  }

  Widget addCard(TileData vo) {
    var alpha = ((1 - vo.z / radio) / 2) * .6;

    final isSelected = vo.idx == selectedCard;

    return Container(
      margin: const EdgeInsets.all(12),
      width: 120,
      height: 80,
      alignment: Alignment.center,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(alpha),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, .9],
          colors: [vo.lightColor, vo.color],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.white) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2 + alpha * .2), spreadRadius: 1, blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: Text('ITEM ${vo.idx}'),
    );
  }
}
