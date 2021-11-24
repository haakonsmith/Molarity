import 'package:flutter/material.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_trends_table.dart';
import 'package:molarity/widgets/list_drawer.dart';

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicTrendsTableScreen extends StatelessWidget {
  const PeriodicTrendsTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (MediaQuery.of(context).size.width <= 500)
      content = const Center(
        child: Text('Sorry, not working on mobile :)'),
      );
    else
      content = const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
          child: PeriodicTrendsTable(),
        ),
      );

    return Scaffold(appBar: MolarityAppBar.buildTitle(context, const Text('Periodic Trends')), drawer: const ListDrawer(), body: content);
  }
}
