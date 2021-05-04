import 'package:flutter/material.dart';
import 'package:molarity/widgets/periodic_table.dart';

class PeriodicTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 0),
        child: PeriodicTable(),
      ),
    );
  }
}
