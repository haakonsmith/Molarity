import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicSummary extends StatelessWidget {
  const AtomicSummary(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const SelectableText('General'),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(element.summary),
        ),
      ),
    );
  }
}
