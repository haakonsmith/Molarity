import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';

class PeriodicTableDataTween extends Tween<List<double>> {
  PeriodicTableDataTween({List<double>? begin, List<double>? end}) : super(begin: begin, end: end);

  @override
  List<double> lerp(double t) {
    print("lerp");
    return begin!.mapIndexed((e, i) => e + (end![i] - e) * t).toList();
  }
}

// extension IndexedIterable<E> on Iterable<E> {
//   Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
//     var i = 0;
//     return map((e) => f(e, i++));
//   }
// }

enum _PeriodicTableStates { noElement, calculationBox, element }

class PeriodicTrendsTable extends ConsumerStatefulWidget {
  PeriodicTrendsTable({Key? key}) : super(key: key);

  @override
  _PeriodicTrendsTableState createState() => _PeriodicTrendsTableState();
}

class _PeriodicTrendsTableState extends ConsumerState<PeriodicTrendsTable> {
  ElementsBloc? elementsBloc;

  final ValueNotifier<AtomicData?> trackedElement = ValueNotifier(null);
  final ValueNotifier<String> trackedAttribute = ValueNotifier("Density");
  final ValueNotifier<_PeriodicTableStates> state = ValueNotifier(_PeriodicTableStates.noElement);

  late List<double> elementsData = [];
  PeriodicTableDataTween? tween;
  bool _dataRequiresUpdate = true;

  @override
  void initState() {
    trackedAttribute.addListener(() => setState(() {
          // print(trackedAttribute.value);
          _dataRequiresUpdate = true;
        }));

    super.initState();
  }

  @override
  void dispose() {
    trackedElement.dispose();
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    elementsBloc = ref.watch(elementsBlocProvider);

    _getData();

    return elementsBloc!.loading ? Center(child: CircularProgressIndicator()) : _buildGrid(context);
  }

  Widget _buildGrid(BuildContext context) {
    final List<double> _elementsData = elementsData;

    final _yMax = _elementsData.reduce((e1, e2) => max(e1, e2));

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
                        return AtomicTrends(
                          element: element,
                          onAtomicPropertyChanged: (value) {
                            trackedAttribute.value = value;
                          },
                          intervalCount: 4,
                          displayLabels: false,
                        );
                      });
                  break;
                case _PeriodicTableStates.noElement:
                  infoBoxFiller = AtomicTrends(
                    intervalCount: 4,
                    onAtomicPropertyChanged: (value) {
                      trackedAttribute.value = value;
                    },
                    displayLabels: false,
                  );
                  break;
                default:
                  infoBoxFiller = AtomicTrends(
                    displayLabels: false,
                    intervalCount: 4,
                    onAtomicPropertyChanged: (value) {
                      trackedAttribute.value = value;
                    },
                  );
                  break;
              }

              return AspectRatio(aspectRatio: 401 / 122.2, child: infoBoxFiller).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
            }),
        for (final e in elementsBloc!.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              subText: e.getAssociatedStringValue(trackedAttribute.value),
              onHover: (element) {
                trackedElement.value = element;
                if (state.value != _PeriodicTableStates.calculationBox) state.value = _PeriodicTableStates.element;
              },
              tileColorGetter: (element) => AtomicPropertyGraph.colorMap[trackedAttribute.value]!.withOpacity(_elementsData[element.atomicNumber - 1] / (_yMax + 0.5)).desaturate(.05),
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }

  void _getData() {
    if (!_dataRequiresUpdate == true) return;

    elementsData = elementsBloc!.getElements().map<double>((e) => double.tryParse(e.getAssociatedStringValue(trackedAttribute.value)) ?? 0).toList();

    _dataRequiresUpdate = false;
  }
}
