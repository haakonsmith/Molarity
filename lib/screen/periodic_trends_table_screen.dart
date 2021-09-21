import 'package:flutter/material.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_trends_table.dart';
import 'package:molarity/widgets/list_drawer.dart';

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicTrendsTableScreen extends StatelessWidget {
  PeriodicTrendsTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MolarityAppBar.buildTitle(context, const Text("Periodic Trends")),
      drawer: ListDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
          child: PeriodicTrendsTable(),
        ),
      ),
    );
  }
}
