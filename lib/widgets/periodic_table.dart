import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/widgets/calculation_box.dart';
import 'package:molarity/widgets/info_box.dart';

import '../theme.dart';
import '../util.dart';
import 'chemoinfomatics/data.dart';

enum _PeriodicTableStates { noElement, calculationBox, element }

class PeriodicTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PeriodicTableState();
}

class _PeriodicTableState extends State<PeriodicTable> {
  @override
  Widget build(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return elementsBloc.loading ? Center(child: CircularProgressIndicator()) : _buildGrid(context);
  }

  final ValueNotifier<AtomicData?> trackedElement = ValueNotifier(null);
  final ValueNotifier<CompoundData?> trackedCompound = ValueNotifier(null);
  final ValueNotifier<_PeriodicTableStates> state = ValueNotifier(_PeriodicTableStates.noElement);

  @override
  void dispose() {
    trackedElement.dispose();
    state.dispose();
    trackedCompound.dispose();

    super.dispose();
  }

  Widget _buildGrid(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      columnGap: 1.5,
      rowGap: 1.5,
      children: [
        ValueListenableBuilder<_PeriodicTableStates>(
            valueListenable: state,
            builder: (BuildContext context, _PeriodicTableStates _state, Widget? child) {
              final Widget infoBoxFiller;

              switch (_state) {
                case _PeriodicTableStates.element:
                  infoBoxFiller = ValueListenableBuilder<AtomicData?>(
                      valueListenable: trackedElement,
                      builder: (BuildContext context, AtomicData? element, Widget? child) {
                        return InfoBox(
                          element: element,
                        );
                      });
                  break;
                case _PeriodicTableStates.noElement:
                  infoBoxFiller = InfoBox(
                    element: null,
                  );
                  break;
                case _PeriodicTableStates.calculationBox:
                  infoBoxFiller = ValueListenableBuilder<CompoundData?>(
                      valueListenable: trackedCompound,
                      builder: (BuildContext context, CompoundData? compound, Widget? child) {
                        return MolarMassBox(
                          compound: compound!,
                          onClear: () {
                            state.value = _PeriodicTableStates.noElement;
                            trackedCompound.value = null;
                          },
                        );
                      });
                  break;
                default:
                  infoBoxFiller = InfoBox(element: null);
                  break;
              }

              return AspectRatio(aspectRatio: 401 / 122.2, child: infoBoxFiller).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
            }),
        for (final e in elementsBloc.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              addCalcElement: (element) {
                if (trackedCompound.value == null)
                  trackedCompound.value = CompoundData.fromList([element]);
                else {
                  trackedCompound.value!.addElement(element);
                  // Look I know this sucks, but I'm lazy
                  trackedCompound.notifyListeners();
                }

                state.value = _PeriodicTableStates.calculationBox;
              },
              onHover: (element) {
                trackedElement.value = element;
                if (state.value != _PeriodicTableStates.calculationBox) state.value = _PeriodicTableStates.element;
              },
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }
}

class PeriodicTableTile extends StatefulWidget {
  final AtomicData element;
  final Function(AtomicData)? onHover;
  final Function(AtomicData)? addCalcElement;

  const PeriodicTableTile(
    this.element, {
    this.onHover,
    this.addCalcElement,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeriodicTableTileState();
}

class _PeriodicTableTileState extends State<PeriodicTableTile> {
  Color tileColor = Colors.white;

  @override
  void initState() {
    super.initState();

    tileColor = categoryColorMapping[widget.element.category]!;
  }

  double elevation = 8;

  /// Dim the tile when hovered
  bool isDimmed = false;

  @override
  Widget build(BuildContext context) {
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
        onTap: () => Navigator.of(context).push(_createRoute()),
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

  Route _createRoute() {
    return MaterialPageRoute(
      builder: (context) => AtomicInfoScreen(widget.element),
    );
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
