import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/helix_display.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';
import 'package:molarity/widgets/layout_boundary.dart';

class HelixPeriodicTable extends ConsumerStatefulWidget {
  const HelixPeriodicTable({this.initialElement, this.onSecondaryTileTap, Key? key}) : super(key: key);

  final AtomicDataCallback? onSecondaryTileTap;
  final AtomicData? initialElement;

  @override
  _HelixPeriodicTableState createState() => _HelixPeriodicTableState();
}

class _HelixPeriodicTableState extends ConsumerState<HelixPeriodicTable> {
  late final List<AtomicData> elements;

  late final List<Widget> children;

  @override
  void initState() {
    elements = ref.read(elementsBlocProvider).getElements();
    final handle = ref.read(interactiveBoxHandle);

    children = elements
        .map(
          (element) => PeriodicTableTile(
            element,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(8),
            tileColor: categoryColorMapping[element.category],
            onSecondaryTap: (element) {
              handle.compound += element;
              handle.state = InteractiveState.calculationBox;
            },
            key: ValueKey('tile: ${element.atomicNumber}'),
          ),
        )
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBoundary(
      child: Helix(
        children: children,
        onCardChanged: (index) {
          ref.read(activeAtomicData).atomicData = elements[index];
        },
        initialCardIndex: (widget.initialElement?.atomicNumber ?? (ref.read(activeAtomicData).atomicData?.atomicNumber ?? 1)) - 1,
      ),
    );
  }
}
