import 'package:flutter/material.dart';

class AtomicAttribute extends StatelessWidget {
  const AtomicAttribute(this.name, this.value, {Key? key}) : super(key: key);

  final String value;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          SelectableText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
          ),
          SelectableText(name),
        ],
      ),
    );
  }
}
