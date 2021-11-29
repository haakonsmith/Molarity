import 'dart:math';

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

class HelixPeriodicTable extends ConsumerStatefulWidget {
  const HelixPeriodicTable({this.intialElement, this.onSecondaryTileTap, Key? key}) : super(key: key);

  final AtomicDataCallback? onSecondaryTileTap;
  final AtomicData? intialElement;

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
        .map((element) => PeriodicTableTile(
              element,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(8),
              tileColor: categoryColorMapping[element.category],
              onSecondaryTap: (element) {
                handle.compound += element;
                handle.state = InteractiveState.calculationBox;
              },
              key: ValueKey('tile: ${element.atomicNumber}'),
            ))
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Helix(
      children: children,
      onCardChanged: (index) {
        ref.read(activeSelectorsProvider).atomicData = elements[index];
      },
      intialCardIndex: (widget.intialElement?.atomicNumber ?? (ref.read(activeSelectorsProvider).atomicData?.atomicNumber ?? 1)) - 1,
    );
  }
}
