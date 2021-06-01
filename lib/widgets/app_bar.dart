import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class MolarityAppBar {
  static PreferredSizeWidget buildTitle(BuildContext context, Widget? title, {double? height}) {
    var appBar = AppBar(elevation: 0, title: title);
    var preferredSize = PreferredSize(
      preferredSize: Size.fromHeight(height ?? 90.0),
      child: Container(
        color: Theme.of(context).bottomAppBarColor,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: SafeArea(child: appBar),
      ),
    );

    return Platform.isMacOS ? preferredSize : appBar;
  }
}
