import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_atomic_data.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

class GridPeriodicTable extends HookConsumerWidget {
  const GridPeriodicTable({this.child, Key? key}) : super(key: key);

  /// Places a child in the empty centre space of the periodic table.
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(elementsBlocProvider).loading ? const Center(child: CircularProgressIndicator()) : _buildGrid(context, ref);
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref) {
    final windowSize = MediaQuery.of(context).size;

    final elementsBloc = ref.watch(elementsBlocProvider);
    final handle = ref.read(interactiveBoxHandle);

    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      columnGap: windowSize.width / 600,
      rowGap: windowSize.width / 600,
      children: [
        AspectRatio(aspectRatio: 401 / 122.2, child: child).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3),
        for (final e in elementsBloc.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              onSecondaryTap: (element) {
                handle.compound += element;
                handle.state = InteractiveState.calculationBox;
              },
              onHover: (element) {
                ref.read(activeAtomicDataNotifier).state = element;
                if (handle.state != InteractiveState.calculationBox) handle.state = InteractiveState.element;
              },
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }
}
