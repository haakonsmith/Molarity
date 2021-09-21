import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/saved_compound_data_listview.dart';
import 'package:molarity/widgets/list_drawer.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table.dart';
import 'package:provider/provider.dart';

import '../util.dart';

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicTableScreen extends ConsumerStatefulWidget {
  PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  _PeriodicTableScreenState createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends ConsumerState<PeriodicTableScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final elementsBloc = ref.watch(elementsBlocProvider);
    final windowSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
        context,
        const Text(
          "Periodic Table",
        ),
      ),
      drawer: ListDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 10.0, windowSize.width / 30, 20),
          child: Column(
            children: [
              SizedBox(
                // While it is loading make a shitty guess as to the height.
                height: elementsBloc.loading ? windowSize.width / 2 : null,
                width: windowSize.width,
                child: PeriodicTable(),
              ),
              const SizedBox(height: 50),
              // Spacer(),
              SavedCompoundDataListview(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
