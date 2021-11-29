import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

class PreferencedCompoundsProvider extends ChangeNotifier {
  final List<CompoundData> savedCompounds = [];

  void removeSavedCompountAt(int index) {
    savedCompounds.removeAt(index);

    notifyListeners();
  }

  void addSavedCompound(CompoundData compound) {
    savedCompounds.add(compound);

    notifyListeners();
  }
}

final preferencedCompoundsProvider = ChangeNotifierProvider((ref) => PreferencedCompoundsProvider());
