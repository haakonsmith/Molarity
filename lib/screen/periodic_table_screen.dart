import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/animations/slide_page_route.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';

import 'package:molarity/widgets/chemoinfomatics/widgets/helix_periodic_table.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/list_drawer.dart';
import 'package:molarity/widgets/saved_compound_data_listview.dart';

class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(
    //   builder: (context, constraints) {},
    // );
    if (MediaQuery.of(context).size.width <= 500)
      return const MobilePeriodicTableScreen();
    else
      return const PeriodicDesktopTableScreen();
  }
}

class MobilePeriodicTableScreen extends ConsumerStatefulWidget {
  const MobilePeriodicTableScreen({Key? key}) : super(key: key);

  @override
  _MobilePeriodicTableScreenState createState() => _MobilePeriodicTableScreenState();
}

class _MobilePeriodicTableScreenState extends ConsumerState<MobilePeriodicTableScreen> {
  bool shouldAllowScroll = true;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    if (ref.watch(elementsBlocProvider).loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
        context,
        const Text(
          'Periodic Table',
        ),
      ),
      drawer: const ListDrawer(),
      body: SingleChildScrollView(
        physics: shouldAllowScroll ? null : const NeverScrollableScrollPhysics(),
        primary: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 10.0, windowSize.width / 30, 20),
          child: Column(
            children: [
              // This means that the scrolling doesn't doesn't interfere with the helix periodic table.
              MouseRegion(
                child: const HelixPeriodicTable(),
                onEnter: (_) {
                  setState(() {
                    shouldAllowScroll = false;
                  });
                },
                onExit: (_) {
                  setState(() {
                    shouldAllowScroll = true;
                  });
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(
                child: InteractiveBox(numberOfInfoboxes: 1),
                height: 200,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SavedCompoundDataListview(),
              ),
            ],
          ),
        ),
      ),
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
  bool _showSearch = false;

  late final Map<Type, Action<Intent>> _actionMap;
  final Map<ShortcutActivator, Intent> _shortcutMap = const {
    SingleActivator(LogicalKeyboardKey.keyP, meta: true): ActivateIntent(),
  };

  final searchController = TextEditingController();

  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (Intent intent) => setState(() {
          _showSearch = !_showSearch;
          if (_showSearch) keyBoardFocusNode.requestFocus();
        }),
      ),
    };

    print('initstate');

    keyBoardFocusNode.onKeyEvent = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() {
          _showSearch = !_showSearch;
          shortcutFocusNode.requestFocus();
        });
      }

      return KeyEventResult.ignored;
    };
  }

  final keyBoardFocusNode = FocusNode();
  final shortcutFocusNode = FocusNode();

  bool shouldRequestFocusOnBuild = true;

  List<AtomicData> highlightedElements = [];

  @override
  Widget build(BuildContext context) {
    if (shouldRequestFocusOnBuild) shortcutFocusNode.requestFocus();
    shouldRequestFocusOnBuild = false;

    final elementsBloc = ref.watch(elementsBlocProvider);
    final windowSize = MediaQuery.of(context).size;

    final content = Column(
      children: [
        SizedBox(
          // While it is loading make a shitty guess as to the height.
          height: elementsBloc.loading ? windowSize.width / 2 : null,
          width: windowSize.width,
          child: GridPeriodicTable(
            child: const InteractiveBox(),
            tileColor: (atomicData) {
              if (highlightedElements.isEmpty) return categoryColorMapping[atomicData.category]!;
              return highlightedElements.contains(atomicData) ? categoryColorMapping[atomicData.category]! : categoryColorMapping[atomicData.category]!.darken(0.2).desaturate();
            },
          ),
        ),
        const SizedBox(height: 50),
        const SavedCompoundDataListview(),
      ],
    );

    final searchBox = SizedBox(
      width: windowSize.width / 2,
      child: TextField(
        style: const TextStyle(fontSize: 40),
        focusNode: keyBoardFocusNode,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            highlightedElements = elementsBloc.elements.where((element) => element.symbol.toLowerCase().contains(value)).toList();
          });
        },
        onSubmitted: (value) {
          searchController.clear();
          shouldRequestFocusOnBuild = true;

          Navigator.push(context, slidePageRoute(_key, AtomicInfoScreen(highlightedElements.first))).then((_) {
            setState(() {
              _showSearch = false;
            });
            highlightedElements.clear();
          });
        },
      ),
    );

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(
        context,
        !_showSearch ? const Text('Periodic Table') : searchBox,
      ),
      drawer: const ListDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 10.0, windowSize.width / 30, 20),
          child: FocusableActionDetector(
            autofocus: true,
            focusNode: shortcutFocusNode,
            actions: _actionMap,
            shortcuts: _shortcutMap,
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
