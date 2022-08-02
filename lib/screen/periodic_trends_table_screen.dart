import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/data/highlighted_search_bar_controller.dart';
import 'package:molarity/highlight_elements_mixin.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/animations/slide_page_route.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';
import 'package:molarity/widgets/highlight_elements_shortcut.dart';
import 'package:molarity/widgets/list_drawer.dart';

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicTrendsTableScreen extends ConsumerStatefulWidget {
  const PeriodicTrendsTableScreen({Key? key}) : super(key: key);

  @override
  _PeriodicTrendsTableScreenState createState() => _PeriodicTrendsTableScreenState();
}

class _PeriodicTrendsTableScreenState extends ConsumerState<PeriodicTrendsTableScreen> with SingleTickerProviderStateMixin {
  late List<double> elementsData = [];
  late String atomicProperty;

  bool _dataRequiresUpdate = true;

  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    ref.read(activeAtomicData).addListener(() {
      _dataRequiresUpdate = true;
    });

    super.initState();
  }

  void _getData() {
    if (_dataRequiresUpdate != true) return;

    elementsData = ref.read(elementsBlocProvider).getElements().map<double>((e) => double.tryParse(e.getAssociatedStringValue(atomicProperty)) ?? 0).toList();

    _dataRequiresUpdate = false;
  }

  @override
  Widget build(BuildContext context) {
    atomicProperty = AtomicData.getPropertyStringName(ref.watch(activeAtomicProperties).atomicProperty);

    _getData();

    final _yMax = elementsData.reduce((e1, e2) => max(e1, e2));

    final Widget content;

    final highlightedElements = ref.watch(highlightedSearchBarController).highlightedElements;

    if (MediaQuery.of(context).size.width <= 500)
      content = const Center(
        child: Text('Sorry, not working on mobile :('),
      );
    else
      content = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 90.0, 30.0, 30),
          child: GridPeriodicTable(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AtomicTrends(
                    displayGrid: false,
                    displayLabels: false,
                    initialProperty: ref.read(activeAtomicProperties).atomicProperty,
                  ),
                ),
              ),
            ),
            tileColor: (atomicData) {
              final color = AtomicPropertyGraph.colorMap[atomicProperty]!.withOpacity(elementsData[atomicData.atomicNumber - 1] / (_yMax + 0.5)).desaturate(.05);

              if (highlightedElements.isEmpty) return color;
              return highlightedElements.contains(atomicData) ? color : color.darken(0.2).desaturate();
            },
          ),
        ),
      );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MolarityAppBar(title: Text('Periodic Table'), hasSearchBar: true),
      drawer: const ListDrawer(),
      body: content,
    );
  }

  Color _highlight(Color color) {
    if (color.red >= color.blue && color.red >= color.green) return color.withBlue(4);
    if (color.green >= color.blue && color.green >= color.blue) return color.withRed(4);
    if (color.blue >= color.red && color.blue >= color.green) return color.withGreen(4);

    return color;
  }
}
