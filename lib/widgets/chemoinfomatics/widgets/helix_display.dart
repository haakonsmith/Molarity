import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

class Helix extends StatefulWidget {
  const Helix({this.children, Key? key, this.onCardChanged, this.intialCardIndex = 0}) : super(key: key);

  final List<Widget>? children;
  final void Function(int index)? onCardChanged;
  final int intialCardIndex;

  @override
  _HelixState createState() => _HelixState();
}

class _HelixState extends State<Helix> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rotationController;
  late final AnimationController _yShiftController;
  late final AnimationController _xOffsetController;

  double yShift = 0;
  double _dragX = 0;
  double _offsetX = 0;
  double angle = pi / 2;

  List<TileData> tileData = [];
  List<Widget> widgetsCache = [];

  late ValueNotifier<int> selectedCard;

  bool isMousePressed = false;

  final double radio = 200.0;
  late final double radioStep;
  late final double totalAngle;

  late final Listenable _onAnimateListenable;

  @override
  void initState() {
    selectedCard = ValueNotifier(widget.intialCardIndex);

    totalAngle = pi * (widget.children!.length / 10 * 2);

    tileData = List.generate(widget.children!.length, (index) => TileData(index)).toList();
    radioStep = (totalAngle) / widget.children!.length;

    widgetsCache = tileData.map((tile) => widget.children![tile.idx]).toList();

    selectedCard.addListener(() => widget.onCardChanged?.call(selectedCard.value));

    _scaleController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // _scaleController.addListener(() => setState(() {
    //       // print('scale');
    //     }));

    _xOffsetController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this, lowerBound: -200, upperBound: 200);
    _xOffsetController.value = 0;

    _yShiftController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this, lowerBound: -400, upperBound: 400);
    _yShiftController.addListener(() {
      yShift = _yShiftController.value;
    });

    _rotationController = AnimationController(value: 0, upperBound: 2000, lowerBound: -2000, duration: const Duration(milliseconds: 500), vsync: this);

    _onAnimateListenable = Listenable.merge([_rotationController, _scaleController, _yShiftController, _xOffsetController]);

    _onAnimateListenable.addListener(() {
      setState(() {});
    });

    _xOffsetController.addListener(() {
      _offsetX = _xOffsetController.value;
    });

    _rotationController.addListener(() {
      angle = _rotationController.value;
    });

    // Animate to starting positions
    _rotationController.animateTo(_angleFromCardIndex(selectedCard.value), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
    _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

    super.initState();
  }

  // Normalizes any number to an arbitrary range
  // by assuming the range wraps around when going below min or above max
  double normaliseRange(double value, double start, double end) {
    final double width = end - start; //
    final double offsetValue = value - start; // value relative to 0

    return (offsetValue - ((offsetValue / width).floorToDouble() * width)) + start;
    // + start to reset back to start of original range
  }

  // Radians
  double _convertDragToAngleOffset(double panX) => (-panX * .006);

  double _normaliseYShift(double yShift) => yShift;
  double _normaliseAngle(double angle) => angle - radioStep.floorToDouble() * totalAngle;
  double _angleFromCardIndex(int index) => radioStep * (-(index - 2) + 1 / 2);

  int _snapAngleToNearestTile(double angle) => normaliseRange(-(_normaliseAngle(angle) / radioStep).floor() + 2, 0, tileData.length.toDouble()).floor();
  int _snapYShiftToNearestRow(double yShift) => (_normaliseYShift(yShift) / 150).round();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Helix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intialCardIndex != selectedCard.value) {
      _rotationController.animateTo(_angleFromCardIndex(widget.intialCardIndex), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      Future.microtask(() => selectedCard.value = widget.intialCardIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // process positions.
    _updateTilePositions();

    // sort in Z axis.
    tileData.sort((a, b) => a.z.compareTo(b.z));

    final List<Widget> cardsToRender = _buildCulledChildren();

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: _onScroll,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
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

  void _onPanDown(DragDownDetails e) {
    isMousePressed = true;

    _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

    _rotationController.stop(canceled: false);
    _yShiftController.stop(canceled: false);
    _xOffsetController.stop(canceled: false);
  }

  void _onPanUpdate(DragUpdateDetails e) {
    _dragX = e.delta.dx;

    angle += _convertDragToAngleOffset(_dragX);

    yShift += e.delta.dy;

    selectedCard.value = _snapAngleToNearestTile(angle);

    _rotationController.value = angle;
  }

  void _onPanEnd(DragEndDetails e) {
    isMousePressed = false;

    _yShiftController.value = yShift;

    if (_snapYShiftToNearestRow(yShift) != 0 &&
        (selectedCard.value - _snapYShiftToNearestRow(yShift) * 10) < widget.children!.length &&
        (selectedCard.value - _snapYShiftToNearestRow(yShift) * 10) > -1) {
      final originalAngle = _angleFromCardIndex(selectedCard.value);

      selectedCard.value -= _snapYShiftToNearestRow(yShift) * 10;
      _xOffsetController.value = 0;
      final yFuture = _yShiftController.animateTo(_snapYShiftToNearestRow(yShift) * 150.0, duration: const Duration(milliseconds: 600), curve: Curves.fastLinearToSlowEaseIn);
      final xFuture = _xOffsetController.animateTo(originalAngle - angle, duration: const Duration(milliseconds: 300));

      Future.wait([xFuture, yFuture]).then((_) {
        angle = _angleFromCardIndex(selectedCard.value);
        _offsetX = 0;
        yShift = 0;
      });
    } else {
      _offsetX = 0;
      yShift = 0;

      final simuluation = FrictionSimulation(0.0001, _dragX, e.velocity.pixelsPerSecond.dx);
      angle += _convertDragToAngleOffset(simuluation.finalX);
      selectedCard.value = _snapAngleToNearestTile(angle);

      _yShiftController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      _rotationController.animateTo(_angleFromCardIndex(selectedCard.value), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
    }

    _scaleController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

    _dragX = 0;
  }

  void _onScroll(pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (100 % pointerSignal.scrollDelta.dy > 1) selectedCard.value += (pointerSignal.scrollDelta.dy).sign.toInt();

      if (selectedCard.value > tileData.length - 1) selectedCard.value = selectedCard.value - 1;
      if (selectedCard.value < 0) selectedCard.value = 0;

      _rotationController.animateTo(_angleFromCardIndex(selectedCard.value), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
    }
  }

  List<Widget> _buildCulledChildren() {
    final List<Widget> result = [];

    for (final tile in tileData) {
      // This formula is not magic, it this same one used to select a card from an angle, but without the floor, so it doesn't snap.
      // This makes it a continous function. However, it does use -1 as the minimum just to account for some stuff
      final selectionValue = normaliseRange(-(_normaliseAngle(angle) / radioStep) + 2, -1, tileData.length.toDouble());
      final double y = tile.idx * 15 - selectionValue * 15 + yShift;

      if (y < 200 && y > -200 && -tile.z < 100) {
        final mt2 = Matrix4.identity();

        mt2.setEntry(3, 2, 0.0005);
        mt2.translate(tile.x, y, -tile.z);
        mt2.rotateY(tile.angle + pi);
        mt2.scale(0.95, 0.95);

        Widget child = _buildTileWidget(tile);
        child = Transform(
          alignment: Alignment.center,
          origin: Offset(0.0, -100 - _scaleController.value * 200.0),
          transform: mt2,
          child: child,
        );

        result.add(child);
      }
    }
    return result;
  }

  Widget _buildTileWidget(TileData tile) {
    final isSelected = tile.idx == selectedCard.value;

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
        child: widgetsCache[tile.idx],
      ),
    );
  }

  void _updateTilePositions() {
    // process positions.
    for (var i = 0; i < tileData.length; ++i) {
      final card = tileData[i];
      final angleOffset = angle + card.idx * radioStep + _offsetX;

      // print(angleOffset);

      card.angle = angleOffset + pi / 2;
      card.x = cos(angleOffset) * radio;
      // c.y = sin(ang) * 10;
      card.z = sin(angleOffset) * radio;
    }
  }
}
