import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

typedef AtomicPropertyChangedCallback = void Function(AtomicProperty? oldValue, AtomicProperty? newValue);

/// This is basically all the active selectors in the app. E.g. atomic category and active atomic data.
class ActiveSelectors extends ChangeNotifier {
  AtomicData? _atomicData;
  AtomicProperty _atomicProperty = AtomicProperty.density;

  AtomicData? get atomicData => _atomicData;

  set atomicData(AtomicData? other) {
    _atomicData = other;
    notifyListeners();
  }

  AtomicProperty get atomicProperty => _atomicProperty;

  set atomicProperty(AtomicProperty other) {
    _atomicProperty = other;
    notifyListeners();
  }
}

final activeSelectorsProvider = ChangeNotifierProvider((_) => ActiveSelectors());
