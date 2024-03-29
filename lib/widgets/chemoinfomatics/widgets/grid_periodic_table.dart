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
import 'package:molarity/widgets/layout_boundary.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GridPeriodicTable extends ConsumerStatefulWidget {
  const GridPeriodicTable({this.tileColor, this.child, Key? key}) : super(key: key);

  /// Places a child in the empty centre space of the periodic table.
  final Widget? child;
  final Color Function(AtomicData atomicData)? tileColor;

  @override
  _GridPeriodicTableState createState() => _GridPeriodicTableState();
}

class _GridPeriodicTableState extends ConsumerState<GridPeriodicTable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  late final Animation<double> _animation;

  final _key = GlobalKey();

  // @override
  // void didPush() {
  //   print('HomePage: Called didPush');
  //   super.didPush();
  // }

  // @override
  // void didPop() {
  //   print('HomePage: Called didPop');
  //   super.didPop();
  // }

  // void didPushNext() {
  //   print('HomePage: Called didPushNext');
  //   super.didPushNext();
  // }

  @override
  void initState() {
    super.initState();

    _animation = _controller.drive(Tween<double>(begin: -1, end: 10));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBoundary(
      child: FutureBuilder<void>(
        future: ref.read(elementsBlocProvider).elementsFuture,
        builder: (context, snapshot) {
          print("build");
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.forward();
            return _buildGrid(context);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    // final windowSize = Size(1000, 600);

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
      columnSizes: repeat(18, [fixed(windowSize.width / 20)]),
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
    final tileColor = widget.tileColor?.call(e);

    return AspectRatio(
      aspectRatio: 40.1 / 42.4,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double value = _animation.value - (e.x * e.x + e.y * e.y) / 100;

          return Opacity(opacity: value.clamp(0, 1), child: child);
        },
        child: PeriodicTableTile(
          e,
          onSecondaryTap: (element) {
            handle.compound += element;
            handle.state = InteractiveState.calculationBox;
          },
          onHover: (element) {
            ref.read(activeAtomicData).atomicData = element;
            if (handle.state != InteractiveState.calculationBox) handle.state = InteractiveState.element;
          },
          tileColor: tileColor,
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
