// TODO populate with more properties, this means defining them in the relevant functions defined in the [AtomicData] class
// TODO combine [_AtomicProperties] and [_AtomicDetails] into a tabbed view.
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:molarity/widgets/atomic_info_widgets/atomic_attribute.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicProperties extends StatelessWidget {
  const AtomicProperties(this.element, {this.maxLength, Key? key}) : super(key: key);

  final int? maxLength;
  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    final properties = element.associatedProperties.map((value) => AtomicAttribute(value, element.getAssociatedStringValue(value))).toList();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const Text('Properties'),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: properties.take(min(properties.length, maxLength ?? properties.length)).toList(),
        ),
      ),
    );
  }
}
