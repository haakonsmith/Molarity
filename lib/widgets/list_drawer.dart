import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';

import 'dart:core';

import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/screen/periodic_trends_table_screen.dart';

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

class ListDrawer extends StatefulWidget {
  ListDrawer({Key? key}) : super(key: key);

  @override
  _ListDrawerState createState() => _ListDrawerState();
}

class _ListDrawerState extends State<ListDrawer> with TickerProviderStateMixin {
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
      builder: (context) => PeriodicTableScreen(),
    );
  }

  Route _createRoutePeriodicTrendsTable() {
    return MaterialPageRoute(
      builder: (context) => PeriodicTableScreen(),
    );
    // return MaterialPageRoute(
    //   builder: (context) => PeriodicTrendsTableScreen(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      ListDrawerTile(
        leading: Icon(Icons.table_chart),
        onClick: () => Navigator.of(context).pushReplacement(_createRoutePeriodicTable()),
        child: Text(
          "Periodic Table",
          textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.w200),
        ),
      ),
      ListDrawerTile(
        leading: Icon(Icons.auto_graph),
        onClick: () => Navigator.of(context).pushReplacement(_createRoutePeriodicTrendsTable()),
        child: Text(
          "Periodicity",
          textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.w200),
        ),
      ),
      ListDrawerTile(
        leading: Icon(Icons.settings),
        onClick: () => Navigator.of(context).pushReplacement(_createRoutePeriodicTable()),
        child: Text(
          "Settings",
          textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.w200),
        ),
      )
    ];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          margin: EdgeInsets.fromLTRB(10, (Platform.isMacOS ? 25 : 0) + 50, 0, 0),
          height: 48 * 3,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children.mapIndexed((e, i) => Transform.translate(offset: Offset(_offset(i, _animation.value), 0), child: e)).toList(),
              );
            },
          ),
        ),
        Spacer()
      ],
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
        borderRadius: BorderRadius.all(Radius.circular(20)),
        onTap: onClick,
        child: Container(
          margin: EdgeInsets.all(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) leading!,
            SizedBox(width: 5),
            child,
          ]),
        ),
      ),
    );
  }
}
