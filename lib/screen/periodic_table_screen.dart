import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/data/highlighted_search_bar_controller.dart';

import 'package:molarity/highlight_elements_mixin.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/animations/slide_page_route.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';

import 'package:molarity/widgets/chemoinfomatics/widgets/helix_periodic_table.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/interactive_box.dart';
import 'package:molarity/widgets/highlight_elements_shortcut.dart';
import 'package:molarity/widgets/list_drawer.dart';
import 'package:molarity/widgets/saved_compound_data_listview.dart';

class PeriodicTableScreen extends ConsumerWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.of(context).size.width <= 500)
      return const MobilePeriodicTableScreen();
    else
      return const DesktopPeriodicTableScreen();
  }
}

class MobilePeriodicTableScreen extends ConsumerStatefulWidget {
  const MobilePeriodicTableScreen({Key? key}) : super(key: key);

  @override
  _MobilePeriodicTableScreenState createState() => _MobilePeriodicTableScreenState();
}

class _MobilePeriodicTableScreenState extends ConsumerState<MobilePeriodicTableScreen> with HighlightElementsMixin {
  bool shouldAllowScroll = true;

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (ref.watch(elementsBlocProvider).loading) return const Center(child: CircularProgressIndicator());

    final windowSize = MediaQuery.of(context).size;

    final searchBox = SizedBox(
      width: windowSize.width / 2,
      child: TextField(
        style: const TextStyle(fontSize: 40),
        focusNode: keyBoardFocusNode,
        controller: searchController,
        onChanged: (string) {
          highlightElements(string);

          if (highlightedElements.isNotEmpty) ref.read(activeSelectorsProvider).atomicData = highlightedElements.first;
        },
        onSubmitted: (_) => Navigator.push(context, slidePageRoute(_key, AtomicInfoScreen(highlightedElements.first))).then(closeSearch),
      ),
    );

    final title = GestureDetector(
      onTap: () {
        setState(toggleSearch);
      },
      child: Row(
        children: [
          if (this.showSearch)
            const Icon(
              Icons.close,
              size: 40,
            ),
          if (!this.showSearch)
            const Text(
              'Periodic Table',
            )
          else
            searchBox,
        ],
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MolarityAppBar(title: title, hasSearchBar: true),
      drawer: const ListDrawer(),
      body: SingleChildScrollView(
        physics: shouldAllowScroll ? null : const NeverScrollableScrollPhysics(),
        primary: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 10.0, windowSize.width / 30, 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // This means that the scrolling doesn't doesn't interfere with the helix periodic table.
              Listener(
                onPointerDown: (_) => setState(() => shouldAllowScroll = false),
                onPointerUp: (_) => setState(() => shouldAllowScroll = true),
                child: MouseRegion(
                  child: HelixPeriodicTable(
                    initialElement: highlightedElements.isNotEmpty ? highlightedElements.first : null,
                  ),
                  onEnter: (_) => setState(() => shouldAllowScroll = false),
                  onExit: (_) => setState(() => shouldAllowScroll = true),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(child: InteractiveBox(numberOfInfoboxes: 1), height: 200),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: SavedCompoundDataListview()),
            ],
          ),
        ),
      ),
    );
  }
}

/// This is the first landing page and screen which shows the basic periodic table
class DesktopPeriodicTableScreen extends ConsumerStatefulWidget {
  const DesktopPeriodicTableScreen({Key? key}) : super(key: key);

  @override
  _PeriodicDesktopTableScreenState createState() => _PeriodicDesktopTableScreenState();
}

class _PeriodicDesktopTableScreenState extends ConsumerState<DesktopPeriodicTableScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final elementsBloc = ref.watch(elementsBlocProvider);
    final windowSize = MediaQuery.of(context).size;

    final highlightedElements = ref.watch(highlightedSearchBarController).highlightedElements;

    final content = Column(
      children: [
        SizedBox(
          // While it is loading make a shitty guess as to the height.
          height: elementsBloc.loading ? windowSize.width / 2 : null,
          width: windowSize.width,
          child: GridPeriodicTable(
            child: const InteractiveBox(),
            tileColor: (AtomicData atomicData) {
              if (highlightedElements.isEmpty) return categoryColorMapping[atomicData.category]!;
              return highlightedElements.contains(atomicData) ? categoryColorMapping[atomicData.category]! : categoryColorMapping[atomicData.category]!.darken(0.2).desaturate();
            },
          ),
        ),
        const SizedBox(height: 50),
        const SavedCompoundDataListview(),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MolarityAppBar(title: Text('Periodic Table'), hasSearchBar: true),
      drawer: const ListDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(windowSize.width / 30, 90.0, windowSize.width / 30, 20),
          child: content,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
