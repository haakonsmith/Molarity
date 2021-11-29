import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';
import 'package:molarity/widgets/titled_card.dart';

class TrendsCard extends ConsumerWidget {
  const TrendsCard({Key? key, required this.element}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const Text('Atomic Property Trend'),
        child: AtomicTrends(
          element: element,
          displayLabels: true,
          displayGrid: !(MediaQuery.of(context).size.width >= 530),
        ),
      ),
    );
  }
}
