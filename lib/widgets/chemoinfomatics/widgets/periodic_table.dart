import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/calculation_box.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import 'periodic_table_tile.dart';

enum _PeriodicTableStates { noElement, calculationBox, element }

class PeriodicTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PeriodicTableState();
}

class _PeriodicTableState extends State<PeriodicTable> {
  ElementsBloc? elementsBloc;

  @override
  Widget build(BuildContext context) {
    elementsBloc = ElementsBloc.of(context, listen: true);

    return elementsBloc!.loading ? Center(child: CircularProgressIndicator()) : _buildGrid(context);
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
        for (final e in elementsBloc!.elements)
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
