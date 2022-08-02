import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

typedef AtomicPropertyChangedCallback = void Function(AtomicProperty? oldValue, AtomicProperty? newValue);

/// This is basically all the active selectors in the app. E.g. atomic category and active atomic data.
class ActiveAtomicData extends ChangeNotifier {
  AtomicData? _atomicData;

  AtomicData? get atomicData => _atomicData;

  set atomicData(AtomicData? other) {
    if (_atomicData != other) {
      _atomicData = other;
      notifyListeners();
    }
  }
}

class ActiveAtomicProperty extends ChangeNotifier {
  AtomicProperty _atomicProperty = AtomicProperty.density;

  AtomicProperty get atomicProperty => _atomicProperty;

  set atomicProperty(AtomicProperty other) {
    _atomicProperty = other;
    notifyListeners();
  }
}

final activeAtomicData = ChangeNotifierProvider((_) => ActiveAtomicData());
final activeAtomicProperties = ChangeNotifierProvider((_) => ActiveAtomicProperty());
