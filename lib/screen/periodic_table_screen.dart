import 'package:flutter/material.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/periodic_table.dart';

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
          context,
          Text(
            "Periodic Table",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200),
          ),
          height: MediaQuery.of(context).size.width / 12),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
          child: PeriodicTable(),
        ),
      ),
    );
  }
}
