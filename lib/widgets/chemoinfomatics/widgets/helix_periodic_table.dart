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
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

import '../../../util.dart';
import '../../should_rebuild.dart';

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

class HelixPeriodicTable extends ConsumerStatefulWidget {
  const HelixPeriodicTable({Key? key}) : super(key: key);

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

  final GlobalKey _key = GlobalKey();

  final totalAngle = pi * (numItems / 10 * 2);

  @override
  void initState() {
    tileData = List.generate(numItems, (index) => TileData(index)).toList();
    radioStep = (totalAngle) / numItems;

    final elements = ref.read(elementsBlocProvider).getElements();

    widgets = tileData.map((e) => KeyedSubtree(child: PeriodicTableTile(elements[e.idx]), key: ValueKey("terst" + e.idx.toString()))).toList();

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

    for (final vo in tileData) {
      final y = vo.idx * 15.0 + angle * 25 - 100;

      if (y < 80 && y > -350 && -vo.z < 60) {
        final mt2 = Matrix4.identity();

        mt2.setEntry(3, 2, 0.0005);
        mt2.translate(vo.x, y, -vo.z);
        mt2.rotateY(vo.angle + pi);
        mt2.scale(0.95, 0.95);

        Widget child = addCard(vo);
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
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // do something when scrolled
          // print('Scrolled');
          // print(pointerSignal.scrollDelta);
          if (100 % pointerSignal.scrollDelta.dy > 1) selectedCard += (pointerSignal.scrollDelta.dy).sign.toInt();

          if (selectedCard > tileData.length - 1) selectedCard = selectedCard - 1;
          if (selectedCard < 0) selectedCard = 0;
          // angle += convertDragToAngleOffset(pointerSignal.scrollDelta.dy);
          // selectedCard = normaliseRange(-(normalise(angle) / ((totalAngle / 2) / (tileData.length / 2))).floor() + 2, 0, tileData.length.toDouble()).floor();
          // _rotationController.value = angle;
          _rotationController.animateTo(selectCardAngle(selectedCard), duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);

          setState(() {});
        }
      },
      child: KeyboardListener(
        onKeyEvent: (value) {
          if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
            selectedCard += 1;
          }
        },
        focusNode: FocusNode(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (e) {
            isMousePressed = true;

            _scaleController.animateTo(1, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
          },
          onPanUpdate: (e) {
            _rotationController.stop();

            angle += convertDragToAngleOffset(e.delta.dx);

            // print(e.delta.dy);
            // print((-e.delta.dy * 5).round());

            if (e.delta.dy * e.delta.dy > 25) {
              final yaddition = ((e.delta.dy.abs()) / 20).round() * radioStep * 1 * e.delta.dy.sign;
              print((yaddition + angle) < totalAngle);

              if ((yaddition + angle) < 0) angle += yaddition;
              // else
              if ((yaddition + angle) < totalAngle) angle += yaddition;
            }

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
          child: Transform.scale(
            scale: 0.7,
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: cardsToRender,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addCard(TileData vo) {
    var alpha = ((1 - vo.z / radio) / 2) * 1;

    final isSelected = vo.idx == selectedCard;

    final double darken = isSelected ? 0 : 0.2;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AtomicInfoScreen(
                  ref.read(elementsBlocProvider).elements[vo.idx],
                ))),
        child: Container(
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
          child: widgets[vo.idx],
        ),
      ),
    );
  }

  Route? _createRoute(GlobalKey key) {
    final _context = key.currentContext;

    if (_context != null) {
      final size = _context.size!;

      // final screenSize = MediaQuery.of(_context).size;
      final screenSize = Size(100, 100);
      final screenRect = Rect.fromLTRB(100, screenSize.height, screenSize.width, 100);

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AtomicInfoScreen(ref.read(elementsBlocProvider).elements[0]),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    // return MaterialPageRoute(
    //   // builder: (context) => AtomicInfoScreen(widget.element),
    //   builder: (context) => PeriodicTable(),
    // );
  }
}

class PeriodicTableTile extends StatefulWidget {
  const PeriodicTableTile(
    this.element, {
    this.subText,
    this.superText,
    this.onHover,
    this.onSecondaryTap,
    this.tileColorGetter,
    this.contentOnly = false,
    Key? key,
  }) : super(key: key);

  final AtomicData element;
  final Function(AtomicData)? onHover;
  final Function(AtomicData)? onSecondaryTap;
  final Color Function(AtomicData)? tileColorGetter;
  final String? subText;
  final String? superText;
  final bool contentOnly;

  @override
  State<StatefulWidget> createState() => _PeriodicTableTileState();
}

class _PeriodicTableTileState extends State<PeriodicTableTile> {
  Color tileColor = Colors.white;

  double elevation = 8;

  /// Dim the tile when hovered
  bool isDimmed = false;

  @override
  Widget build(BuildContext context) {
    // print("Build Tile");

    if (widget.tileColorGetter == null)
      tileColor = categoryColorMapping[widget.element.category]!;
    else
      tileColor = widget.tileColorGetter!(widget.element);
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: _TileSub(widget.superText ?? widget.element.atomicNumber.toString()),
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: _TileSymbol(widget.element.symbol),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: _TileSub(widget.subText ?? widget.element.symbol),
          ),
        ),
        // Expanded(child: Center(child: elementTitle)),
      ],
    );

    if (widget.contentOnly) return content;

    return Card(
      // elevation: elevation,
      color: tileColor.darken(isDimmed ? .1 : 0),
      margin: const EdgeInsets.all(1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.white60.withOpacity(0.8)),
          child: content,
        ),
      ),
    );
  }
}

class _TileSymbol extends StatelessWidget {
  const _TileSymbol(
    this.symbol, {
    Key? key,
  }) : super(key: key);

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Text(
      symbol,
      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
      textScaleFactor: 1.5,
    );
  }
}

class _TileSub extends StatelessWidget {
  const _TileSub(
    this.value, {
    Key? key,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
      textScaleFactor: 0.7,
    );
  }
}
