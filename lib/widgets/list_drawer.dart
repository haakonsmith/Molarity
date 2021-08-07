import 'dart:io';

import 'package:flutter/material.dart';

class ListDrawer extends StatelessWidget {
  const ListDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, (Platform.isMacOS ? 25 : 0) + 50, 0, 0),
      child: Column(
        children: [
          ListDrawerTile(
            leading: Icon(Icons.settings),
            child: Text(
              "Settings",
              textScaleFactor: 1.2,
              style: TextStyle(fontWeight: FontWeight.w200),
            ),
          ),
          ListDrawerTile(
            leading: Icon(Icons.settings),
            child: Text(
              "Settings",
              textScaleFactor: 1.2,
              style: TextStyle(fontWeight: FontWeight.w200),
            ),
          )
        ],
      ),
    );
  }
}

class ListDrawerTile extends StatelessWidget {
  const ListDrawerTile({
    Key? key,
    this.leading,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  final Color? backgroundColor;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    // return TextButton(
    //   onPressed: () => {},
    //   style: ButtonStyle(backgroundColor: _backgroundColor),
    //   child: child,
    // );
    return Card(
      color: _backgroundColor,
      child: InkWell(
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
