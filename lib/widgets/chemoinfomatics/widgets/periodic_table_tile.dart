import 'package:flutter/material.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';

typedef ShouldRebuildFunction<T> = bool Function(T oldWidget, T newWidget);

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

  final GlobalKey _key = GlobalKey();

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

    return MouseRegion(
      key: _key,
      onHover: (value) {
        widget.onHover?.call(widget.element);

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
        onSecondaryTap: () => widget.onSecondaryTap!(widget.element),
        child: Card(
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

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else {
      return MaterialPageRoute(
        // builder: (context) => AtomicInfoScreen(widget.element),
        builder: (context) => GridPeriodicTable(),
      );
    }
    // return MaterialPageRoute(
    //   // builder: (context) => AtomicInfoScreen(widget.element),
    //   builder: (context) => PeriodicTable(),
    // );
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
