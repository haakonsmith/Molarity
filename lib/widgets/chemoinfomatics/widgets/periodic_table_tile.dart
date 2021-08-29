import 'package:flutter/material.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/util.dart';

import '../../../theme.dart';
import '../data.dart';

class PeriodicTableTile extends StatefulWidget {
  final AtomicData element;
  final Function(AtomicData)? onHover;
  final Function(AtomicData)? addCalcElement;
  final Color Function(AtomicData)? tileColorGetter;

  const PeriodicTableTile(
    this.element, {
    this.onHover,
    this.addCalcElement,
    this.tileColorGetter,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeriodicTableTileState();
}

class _PeriodicTableTileState extends State<PeriodicTableTile> {
  Color tileColor = Colors.white;

  double elevation = 8;

  /// Dim the tile when hovered
  bool isDimmed = false;

  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.tileColorGetter == null)
      tileColor = categoryColorMapping[widget.element.category]!;
    else
      tileColor = widget.tileColorGetter!(widget.element);
    var content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: _TileSub(widget.element.atomicNumber.toString()),
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
            child: _TileSub(widget.element.symbol),
          ),
        ),
        // Expanded(child: Center(child: elementTitle)),
      ],
    );

    return MouseRegion(
      key: _key,
      onHover: (value) {
        widget.onHover!(widget.element);

        setState(() {
          elevation = 16;
          isDimmed = true;
        });
      },
      onExit: (value) => setState(() {
        elevation = 8;
        isDimmed = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(_createRoute(_key)),
        onSecondaryTap: () => widget.addCalcElement!(widget.element),
        child: Card(
          elevation: elevation,
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
        ),
      ),
    );
  }

  Route _createRoute(GlobalKey key) {
    final _context = key.currentContext;

    if (_context != null) {
      final size = _context.size!;

      final screenSize = MediaQuery.of(_context).size;
      final screenRect = Rect.fromLTRB(100, screenSize.height, screenSize.width, 100);

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AtomicInfoScreen(widget.element),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // final begin = RelativeRect.fromSize(screenRect, size);
          // final end = RelativeRect.fromSize(screenRect, screenSize);
          // const curve = Curves.ease;

          // var tween = RectTween(begin: begin, end: end).chain(CurveTween(curve: curve));

          // return Rect(
          //   rect: animation.drive(tween),
          //   child: child,
          // );
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => AtomicInfoScreen(widget.element),
      );
    }
  }
}

class _TileSymbol extends StatelessWidget {
  final String symbol;

  const _TileSymbol(
    this.symbol, {
    Key? key,
  }) : super(key: key);

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
  final String value;

  const _TileSub(
    this.value, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
      textScaleFactor: 0.7,
    );
  }
}
