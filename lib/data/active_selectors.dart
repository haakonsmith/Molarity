import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

/// This is basically all the active selectors in the app. E.g. atomic category and active atomic data.
class ActiveSelectors extends ChangeNotifier {
  AtomicData? _atomicData;

  AtomicData? get atomicData => _atomicData;
  set atomicData(AtomicData? other) {
    _atomicData = other;
    notifyListeners();
  }
}

final activeSelectorsProvider = ChangeNotifierProvider((_) => ActiveSelectors());
