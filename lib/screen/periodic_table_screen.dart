import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_display.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/helix_periodic_table.dart';
import 'package:molarity/widgets/list_drawer.dart';
import 'package:molarity/widgets/saved_compound_data_listview.dart';

class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb) return PeriodicDesktopTableScreen();

    // if (Platform.isAndroid || Platform.isIOS)
    //   return MobilePeriodicTableScreen();
    // else
    //   return PeriodicDesktopTableScreen();
    print(MediaQuery.of(context).size.width);

    if (MediaQuery.of(context).size.width <= 500)
      return const MobilePeriodicTableScreen();
    else
      return const PeriodicDesktopTableScreen();
  }
}

class MobilePeriodicTableScreen extends StatefulWidget {
  const MobilePeriodicTableScreen({Key? key}) : super(key: key);

  @override
  _MobilePeriodicTableScreenState createState() => _MobilePeriodicTableScreenState();
}

class _MobilePeriodicTableScreenState extends State<MobilePeriodicTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
        context,
        const Text(
          'Periodic Table',
        ),
      ),
      drawer: const ListDrawer(),
      body: const HelixPeriodicTable(),
    );
  }
}

/// This is the first landing page and screen which shows the basic periodic table
class PeriodicDesktopTableScreen extends ConsumerStatefulWidget {
  const PeriodicDesktopTableScreen({Key? key}) : super(key: key);

  @override
  _PeriodicDesktopTableScreenState createState() => _PeriodicDesktopTableScreenState();
}

class _PeriodicDesktopTableScreenState extends ConsumerState<PeriodicDesktopTableScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final elementsBloc = ref.watch(elementsBlocProvider);
    final windowSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
        context,
        const Text(
          'Periodic Table',
        ),
      ),
      drawer: const ListDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 10.0, windowSize.width / 30, 20),
          child: Column(
            children: [
              SizedBox(
                // While it is loading make a shitty guess as to the height.
                height: elementsBloc.loading ? windowSize.width / 2 : null,
                width: windowSize.width,
                child: GridPeriodicTable(),
              ),
              const SizedBox(height: 50),
              // Spacer(),
              const SavedCompoundDataListview(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
