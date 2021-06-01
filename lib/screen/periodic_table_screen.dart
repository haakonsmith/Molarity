import 'package:flutter/material.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/periodic_table.dart';

class PeriodicTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MolarityAppBar.buildTitle(context, Text("test"), height: 70),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
          child: PeriodicTable(),
        ),
      ),
    );
  }
}
