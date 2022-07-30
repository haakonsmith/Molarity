import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Route slidePageRoute(GlobalKey key, Widget page) {
  final _context = key.currentContext;

  return MaterialPageRoute(
    builder: (_) => page,
  );
}
