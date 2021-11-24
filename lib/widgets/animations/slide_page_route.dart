import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_table.dart';

Route slidePageRoute(GlobalKey key, Widget page) {
  final _context = key.currentContext;

  if (_context != null) {
    final screenSize = MediaQuery.of(_context).size;
    final screenRect = Rect.fromLTRB(100, screenSize.height, screenSize.width, 100);

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  } else {
    return MaterialPageRoute(
      builder: (_) => page,
    );
  }
}
