import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AtomicAttributeSelector extends HookWidget {
  const AtomicAttributeSelector({
    this.onChanged,
    this.intialValue = "Density",
    Key? key,
    this.selectables = kSelectables,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final ValueChanged<String?>? onChanged;

  final String intialValue;
  final List<String> selectables;

  static const kSelectables = const <String>[
    'Melting Point',
    'Boiling Point',
    'Phase',
    'Density',
    'Atomic Mass',
    'Molar Heat',
    'Electron Negativity',
    // 'First Ionisation Energy',
    'Electron Configuration',
  ];

  final backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (!selectables.contains(intialValue)) throw ArgumentError.value(intialValue, "AtomicAttributeSelector");

    final dropdownValue = useState(intialValue);

    return Container(
      color: backgroundColor,
      child: DropdownButton<String>(
        // underline: Container(),
        value: dropdownValue.value,
        items: selectables
            .map(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (onChanged != null) onChanged!(val);

          dropdownValue.value = val!;
        },
      ),
    );
  }
}
