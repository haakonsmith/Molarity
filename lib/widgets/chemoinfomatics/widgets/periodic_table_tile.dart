import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/animations/slide_page_route.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';

class PeriodicTableTile extends ImplicitlyAnimatedWidget {
  const PeriodicTableTile(
    this.element, {
    this.subText,
    this.superText,
    this.onHover,
    this.onSecondaryTap,
    this.tileColor,
    this.shouldListen = false,
    this.borderRadius,
    this.padding,
    Key? key,
  }) : super(
          key: key,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );

  final AtomicData element;
  final Function(AtomicData)? onHover;
  final Function(AtomicData)? onSecondaryTap;
  final Color? tileColor;
  final String? subText;
  final String? superText;
  final bool shouldListen;

  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  @override
  _PeriodicTableTileState createState() => _PeriodicTableTileState();
}

class _PeriodicTableTileState extends AnimatedWidgetBaseState<PeriodicTableTile> {
  ColorTween? _colorTween;

  Color tileColor = Colors.white;

  double elevation = 8;

  /// Dim the tile when hovered
  bool isDimmed = false;

  bool _isPressured = false;

  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    tileColor = widget.tileColor ?? categoryColorMapping[widget.element.category]!;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PeriodicTableTile oldWidget) {
    if (widget.tileColor != oldWidget.tileColor) {
      tileColor = tileColor = widget.tileColor ?? categoryColorMapping[widget.element.category]!;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void forEachTween(visitor) {
    _colorTween = visitor(
      _colorTween,
      tileColor,
      (value) => ColorTween(begin: value),
    ) as ColorTween;
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
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

    if (widget.shouldListen) return content;

    final card = Card(
      color: (_colorTween?.evaluate(animation) ?? Colors.white).darken(isDimmed ? .1 : 0),
      margin: const EdgeInsets.all(1),
      shape: RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0)),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(2),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.white60.withOpacity(0.8)),
          child: content,
        ),
      ),
    );
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
      child: Consumer(
        builder: (context, ref, child) {
          final rawGestureDetector = RawGestureDetector(
            gestures: {
              ForcePressGestureRecognizer: GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
                () => ForcePressGestureRecognizer(),
                (ForcePressGestureRecognizer instance) {
                  instance.onUpdate = (details) {
                    if (details.pressure > 0.4) {
                      if (!_isPressured) {
                        widget.onSecondaryTap?.call(widget.element);
                        _isPressured = true;
                        HapticFeedback.lightImpact();
                      }
                    }

                    if (details.pressure < 0.4) _isPressured = false;
                  };
                },
              ),
            },
            child: child,
          );

          return GestureDetector(
            onTap: () => Navigator.of(context).push(slidePageRoute(_key, AtomicInfoScreen(widget.element))),
            onSecondaryTap: () => widget.onSecondaryTap?.call(widget.element),
            onDoubleTap: () => widget.onSecondaryTap?.call(widget.element),
            onLongPress: () => widget.onSecondaryTap?.call(widget.element),
            child: rawGestureDetector,
          );
        },
        child: card,
      ),
    );
  }
}

// () {
//               final read = ref.read(interactiveBoxHandle);
//               read.compound += widget.element;
//               read.state = InteractiveState.calculationBox;
//             },

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
