import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

class NavigationStateProvider {
  bool isPeriodicTable = false;
}

final navigationState = StateProvider((ref) => NavigationStateProvider());
