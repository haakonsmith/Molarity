import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

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

class HelixPeriodicTable extends ConsumerStatefulWidget {
  const HelixPeriodicTable({this.onSecondaryTileTap, Key? key}) : super(key: key);

  final AtomicDataCallback? onSecondaryTileTap;

  @override
  _HelixPeriodicTableState createState() => _HelixPeriodicTableState();
}

class _HelixPeriodicTableState extends ConsumerState<HelixPeriodicTable> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  List<TileData> tileData = [];
  List<Widget> widgets = [];
  final double radio = 200.0;
  late final double radioStep;
  bool isMousePressed = false;

  double angle = pi / 2;
  int selectedCard = 0;
  static int numItems = 118;

  double yShift = 0;

  double _dragX = 0;

  final totalAngle = pi * (numItems / 10 * 2);
  late final List<AtomicData> elements;

  @override
  void initState() {
    tileData = List.generate(numItems, (index) => TileData(index)).toList();
    radioStep = (totalAngle) / numItems;

    elements = ref.read(elementsBlocProvider).getElements();

    selectedCard = (ref.read(activeSelectorsProvider).atomicData?.atomicNumber ?? 1) - 1;

    final handle = ref.read(interactiveBoxHandle);

    widgets = tileData
        .map(
          (e) => PeriodicTableTile(
            elements[e.idx],
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(8),
            tileColor: categoryColorMapping[elements[e.idx].category],
            onSecondaryTap: (element) {
              handle.compound += element;
              handle.state = InteractiveState.calculationBox;
            },
            key: ValueKey('test${e.idx}'),
          ),
        )
        .toList();

    _scaleController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleController.addListener(() => setState(() {}));

    _rotationController = AnimationController(value: 0, upperBound: 2000, lowerBound: -2000, duration: const Duration(milliseconds: 500), vsync: this);
    _rotationController.addListener(() {
      // if (!isMousePressed)
      // selectedCard = normaliseRange(-(normalise(angle) / radioStep).floor() + 2, 0, tileData.length.toDouble()).floor();
      setState(() {
        angle = _rotationController.value;
      });

      // if (_rotationController.isCompleted) {}
    });

    _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
    _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

    super.initState();
  }

  // Radians
  double convertDragToAngleOffset(double panX) => (-panX * .006);

  double normalise(double angle) => angle - radioStep.floorToDouble() * totalAngle;
  double selectCardAngle(int index) => radioStep * (-(index - 2) + 1 / 2);

  // void _runAngleAnimation()

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
      final card = tileData[i];
      final angleOffset = angle + card.idx * radioStep;

      card.angle = angleOffset + pi / 2;
      card.x = cos(angleOffset) * radio;
      // c.y = sin(ang) * 10;
      card.z = sin(angleOffset) * radio;
    }

    // sort in Z axis.
    tileData.sort((a, b) => a.z.compareTo(b.z));

    final List<Widget> cardsToRender = [];

    for (final tile in tileData) {
      // This formula is not magic, it this same one used to select a card from an angle, but without the floor, so it doesn't snap.
      // This makes it a continous function. However, it does use -1 as the minimum just to account for some stuff
      final selectionValue = normaliseRange(-(normalise(angle) / radioStep) + 2, -1, tileData.length.toDouble());
      final double y = tile.idx * 15 - selectionValue * 15 + yShift;

      if (y < 200 && y > -200 && -tile.z < 100) {
        final mt2 = Matrix4.identity();

        mt2.setEntry(3, 2, 0.0005);
        mt2.translate(tile.x, y, -tile.z);
        mt2.rotateY(tile.angle + pi);
        mt2.scale(0.95, 0.95);

        Widget child = addCard(tile);
        child = Transform(
          alignment: Alignment.center,
          origin: Offset(0.0, -100 - _scaleController.value * 200.0),
          transform: mt2,
          child: child,
        );

        cardsToRender.add(child);
      }
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          if (100 % pointerSignal.scrollDelta.dy > 1) selectedCard += (pointerSignal.scrollDelta.dy).sign.toInt();

          if (selectedCard > tileData.length - 1) selectedCard = selectedCard - 1;
          if (selectedCard < 0) selectedCard = 0;

          ref.read(activeSelectorsProvider).atomicData = elements[selectedCard];

          _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

          setState(() {});
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (e) {
          isMousePressed = true;

          // _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
        },
        onPanUpdate: (e) {
          _rotationController.stop();

          _dragX = e.delta.dx;

          angle += convertDragToAngleOffset(e.delta.dx);

          yShift += e.delta.dy;

          selectedCard = normaliseRange(-(normalise(angle) / radioStep).floor() + 2, 0, tileData.length.toDouble()).floor();

          setState(() {});
        },
        onPanEnd: (e) {
          _rotationController.value = angle;

          isMousePressed = false;

          final simuluation = FrictionSimulation(0.01, _dragX, e.velocity.pixelsPerSecond.dx);

          angle += convertDragToAngleOffset(simuluation.finalX);
          selectedCard = normaliseRange(-(normalise(angle) / radioStep).floor() + 2, 0, tileData.length.toDouble()).floor();

          _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
          // _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

          ref.read(activeSelectorsProvider).atomicData = elements[selectedCard];

          _dragX = 0;
        },
        child: Transform.scale(
          scale: 0.8,
          child: Container(
            height: 400,
            width: 400,
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

  Widget addCard(TileData tile) {
    final isSelected = tile.idx == selectedCard;

    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: isSelected ? Border.all(color: Colors.white) : null,
      ),
      child: Opacity(
        opacity: (tile.z / 100).clamp(0, 1),
        child: widgets[tile.idx],
      ),
    );
  }
}
