import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

enum _PeriodicTableStates { noElement, calculationBox, element }

class PeriodicTrendsTable extends ConsumerStatefulWidget {
  const PeriodicTrendsTable({Key? key}) : super(key: key);

  @override
  _PeriodicTrendsTableState createState() => _PeriodicTrendsTableState();
}

class _PeriodicTrendsTableState extends ConsumerState<PeriodicTrendsTable> with SingleTickerProviderStateMixin {
  ElementsBloc? elementsBloc;

  final ValueNotifier<AtomicData?> trackedElement = ValueNotifier(null);
  final ValueNotifier<String> trackedAttribute = ValueNotifier('Density');
  final ValueNotifier<_PeriodicTableStates> state = ValueNotifier(_PeriodicTableStates.noElement);

  late List<double> elementsData = [];
  bool _dataRequiresUpdate = true;

  late final AnimationController _controller;

  late final Animation<double> _animation;

  @override
  void initState() {
    trackedAttribute.addListener(() => setState(() => _dataRequiresUpdate = true));

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    _animation = _controller.drive(Tween<double>(begin: -1, end: 10));

    if (!ref.read(elementsBlocProvider).loading)
      _controller.forward();
    else
      ref.read(elementsBlocProvider).addListener(() => _controller.forward());

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

    return elementsBloc!.loading ? const Center(child: CircularProgressIndicator()) : _buildGrid(context);
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
        ValueListenableBuilder<_PeriodicTableStates>(valueListenable: state, builder: _buildGraph),
        for (final e in elementsBloc!.elements) _buildTile(e, _elementsData, _yMax).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }

  Widget _buildGraph(BuildContext context, _PeriodicTableStates _state, Widget? child) {
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
                displayGrid: false,
              );
            });
        break;
      case _PeriodicTableStates.noElement:
        infoBoxFiller = AtomicTrends(
          intervalCount: 4,
          onAtomicPropertyChanged: (value) {
            trackedAttribute.value = value;
          },
          displayGrid: false,
          displayLabels: false,
        );
        break;
      default:
        infoBoxFiller = AtomicTrends(
          displayLabels: false,
          displayGrid: false,
          intervalCount: 4,
          onAtomicPropertyChanged: (value) {
            trackedAttribute.value = value;
          },
        );
        break;
    }

    return AspectRatio(
      aspectRatio: 401 / 122.2,
      child: AnimatedBuilder(
        animation: _animation,
        child: infoBoxFiller,
        builder: (context, child) {
          final double value = _animation.value - sqrt(20) / 10;

          return Opacity(opacity: value.clamp(0, 1), child: child);
        },
      ),
    ).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
  }

  Widget _buildTile(AtomicData e, List<double> _elementsData, double _yMax) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double value = _animation.value - sqrt(e.x * e.x + e.y * e.y) / 10;

        return Opacity(opacity: value.clamp(0, 1), child: child);
      },
      child: AspectRatio(
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
      ),
    );
  }

  void _getData() {
    if (!_dataRequiresUpdate == true) return;

    elementsData = elementsBloc!.getElements().map<double>((e) => double.tryParse(e.getAssociatedStringValue(trackedAttribute.value)) ?? 0).toList();

    _dataRequiresUpdate = false;
  }
}
