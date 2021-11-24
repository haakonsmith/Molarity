import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';

class GridPeriodicTable extends ConsumerStatefulWidget {
  const GridPeriodicTable({this.tileColor, this.child, Key? key}) : super(key: key);

  /// Places a child in the empty centre space of the periodic table.
  final Widget? child;
  final Color Function(AtomicData atomicData)? tileColor;

  @override
  _GridPeriodicTableState createState() => _GridPeriodicTableState();
}

class _GridPeriodicTableState extends ConsumerState<GridPeriodicTable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    _animation = _controller.drive(Tween<double>(begin: -1, end: 10));

    if (!ref.read(elementsBlocProvider).loading)
      _controller.forward();
    else
      ref.read(elementsBlocProvider).addListener(() => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(elementsBlocProvider).loading ? const Center(child: CircularProgressIndicator()) : _buildGrid(context, ref);
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref) {
    final windowSize = MediaQuery.of(context).size;

    final elementsBloc = ref.watch(elementsBlocProvider);
    final handle = ref.read(interactiveBoxHandle);

    final child = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double value = _animation.value - sqrt(10) / 10;

        return Opacity(opacity: value.clamp(0, 1), child: child);
      },
      child: widget.child,
    );

    final table = LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      columnGap: windowSize.width / 600,
      rowGap: windowSize.width / 600,
      children: [
        AspectRatio(aspectRatio: 401 / 122.2, child: child).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3),
        for (final e in elementsBloc.elements) _buildTile(e, handle, ref).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );

    return table;
  }

  AspectRatio _buildTile(AtomicData e, InteractiveBoxHandle handle, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 40.1 / 42.4,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double value = _animation.value - sqrt(e.x * e.x + e.y * e.y) / 10;

          return Opacity(opacity: value.clamp(0, 1), child: child);
        },
        child: PeriodicTableTile(
          e,
          onSecondaryTap: (element) {
            handle.compound += element;
            handle.state = InteractiveState.calculationBox;
          },
          onHover: (element) {
            ref.read(activeSelectorsProvider).atomicData = element;
            if (handle.state != InteractiveState.calculationBox) handle.state = InteractiveState.element;
          },
          tileColorGetter: widget.tileColor,
          key: ValueKey(e.symbol),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
