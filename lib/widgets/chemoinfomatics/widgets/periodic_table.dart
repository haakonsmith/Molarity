import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/calculation_box.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import 'periodic_table_tile.dart';

enum _PeriodicTableStates { noElement, calculationBox, element }

class PeriodicTable extends HookConsumerWidget {
  ElementsBloc? elementsBloc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    elementsBloc = ref.watch(elementsBlocProvider);

    return elementsBloc!.loading ? Center(child: CircularProgressIndicator()) : _buildGrid(context);
  }

  // final ValueNotifier<AtomicData?> trackedElement = ValueNotifier(null);
  // final ValueNotifier<CompoundData?> trackedCompound = ValueNotifier(null);
  // final ValueNotifier<_PeriodicTableStates> state = ValueNotifier(_PeriodicTableStates.noElement);

  // @override
  // void dispose() {
  //   trackedElement.dispose();
  //   state.dispose();
  //   trackedCompound.dispose();

  //   super.dispose();
  // }

  Widget _buildGrid(BuildContext context) {
    final state = useValueNotifier(_PeriodicTableStates.noElement);
    final trackedElement = useValueNotifier<AtomicData?>(null);
    final trackedCompound = useValueNotifier(CompoundData.empty());

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
              return AspectRatio(
                  aspectRatio: 401 / 122.2,
                  child: _InteractiveBox(
                    state,
                    trackedElement,
                    trackedCompound,
                  )).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
            }),
        for (final e in elementsBloc!.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              onSecondaryTap: (element) {
                trackedCompound.value += element;

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

  // void _addElementToCompound(AtomicData element) {
  //   if (trackedCompound.value == null)
  //     trackedCompound.value = CompoundData.fromAtomicData(element);
  //   else {
  //     trackedCompound.value!.addElement(element);
  //     // Look I know this sucks, but I'm lazy
  //     trackedCompound.notifyListeners();
  //   }

  // }
}

class _InteractiveBox extends StatelessWidget {
  const _InteractiveBox(this.state, this.trackedElement, this.trackedCompound, {Key? key}) : super(key: key);

  final ValueNotifier<_PeriodicTableStates> state;
  final ValueNotifier<AtomicData?> trackedElement;
  final ValueNotifier<CompoundData?> trackedCompound;

  @override
  Widget build(BuildContext context) {
    switch (state.value) {
      case _PeriodicTableStates.element:
        return ValueListenableBuilder<AtomicData?>(valueListenable: trackedElement, builder: (BuildContext context, AtomicData? element, Widget? child) => InfoBox(element: element));
      case _PeriodicTableStates.noElement:
        return InfoBox(element: null);
      case _PeriodicTableStates.calculationBox:
        return ValueListenableBuilder<CompoundData?>(
            valueListenable: trackedCompound,
            builder: (BuildContext context, CompoundData? compound, Widget? child) => MolarMassBox(
                  compound: compound!,
                  onClear: () {
                    state.value = _PeriodicTableStates.noElement;
                    trackedCompound.value = null;
                  },
                ));
      default:
        return InfoBox(element: null);
    }
  }
}
