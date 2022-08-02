import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/screen/about_screen.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/screen/periodic_trends_table_screen.dart';
import 'package:molarity/screen/settings_screen.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:universal_platform/universal_platform.dart';

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

class ListDrawer extends ConsumerStatefulWidget {
  const ListDrawer({Key? key}) : super(key: key);

  @override
  _ListDrawerState createState() => _ListDrawerState();
}

class _ListDrawerState extends ConsumerState<ListDrawer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..forward();
    _animation = Tween<double>(begin: -200, end: 200).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Route _createRoutePeriodicTable() {
    return MaterialPageRoute(
      builder: (context) => const PeriodicTableScreen(),
    );
  }

  Route _createRoutePeriodicTrendsTable() {
    return MaterialPageRoute(
      builder: (context) => const PeriodicTrendsTableScreen(),
    );
  }

  Route _createRouteSettings() {
    return MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    );
  }

  Route _createRouteAbout() {
    return MaterialPageRoute(
      builder: (context) => const AboutScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const buttonStyle = TextStyle(fontWeight: FontWeight.w200, fontSize: 24);
    const buttonHeight = 54.0;

    final children = [
      ListDrawerTile(
        leading: const Icon(Icons.table_chart),
        onClick: () => Navigator.of(context).pushReplacement(_createRoutePeriodicTable()),
        child: const Text('Periodic Table', style: buttonStyle),
      ),
      ListDrawerTile(
        leading: const Icon(Icons.auto_graph),
        onClick: () => Navigator.of(context).pushReplacement(_createRoutePeriodicTrendsTable()),
        child: const Text('Periodicity', style: buttonStyle),
      ),
      ListDrawerTile(
        leading: const Icon(Icons.settings),
        onClick: () => Navigator.of(context).pushReplacement(_createRouteSettings()),
        child: const Text('Settings', style: buttonStyle),
      ),
      const SizedBox(height: buttonHeight),
      ListDrawerTile(
        leading: const Icon(Icons.info),
        onClick: () => Navigator.of(context).pushReplacement(_createRouteAbout()),
        child: const Text('About', style: buttonStyle),
      )
    ];

    // final headerSize = UniversalPlatform.isDesktop ? 250.0 : 250.0;
    final headerSize = (MediaQuery.of(context).orientation != Orientation.landscape) ? 250.0 : 0.0;

    final atomicModel = SizedBox.square(
      dimension: headerSize,
      child: AtomicBohrModel(ref.read(elementsBlocProvider).getElementByAtomicNumber(1)),
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            margin: EdgeInsets.fromLTRB(10, (UniversalPlatform.isMacOS ? 25 : 0) + 50, 0, 0),
            height: buttonHeight * children.length + headerSize,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [if (MediaQuery.of(context).orientation != Orientation.landscape) atomicModel].cast<Widget>() +
                      children.mapIndexed((e, i) => Transform.translate(offset: Offset(_offset(i, _animation.value), 0), child: e)).toList().cast<Widget>(),
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  double _offset(int i, double off) {
    final result = -(i + 1) * 20 + off;

    if (result < 0)
      return result;
    else
      return 0;
  }
}

class ListDrawerTile extends StatelessWidget {
  const ListDrawerTile({
    Key? key,
    this.leading,
    required this.child,
    this.backgroundColor,
    this.onClick,
  }) : super(key: key);

  final Color? backgroundColor;
  final Widget child;
  final Widget? leading;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Card(
      color: _backgroundColor,
      child: InkWell(
        // mouseCursor: MaterialStateMouseCursor.clickable,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: onClick,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) leading!,
            const SizedBox(width: 5),
            child,
          ]),
        ),
      ),
    );
  }
}
