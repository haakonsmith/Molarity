import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc extends ChangeNotifier with AsyncSafeData {
  SettingsBloc(ElementsBloc elementsBloc) {
    asyncDataUpdate(() async {
      instance = await SharedPreferences.getInstance();

      _loadDefaults(elementsBloc);
    }).then((_) => notifyListeners());
  }

  late final SharedPreferences instance;

  /// This will load the stored values if they exist.
  /// Add defaults here
  void _loadDefaults(ElementsBloc elementsBloc) {
    _shouldPersistAtomicPreviewCategories = instance.getBool('shouldPersistAtomicPreviewCategories') ?? true;
    _enableKeyboardShortcuts = instance.getBool('enableKeyboardShortcuts') ?? false;
    _savedCompounds = (instance.getStringList('savedCompounds') ?? []).map((e) => CompoundData.deserialise(e, elementsBloc)).toList();
    _savedAtomicPropertyCategories = instance.containsKey('savedAtomicPropertyCategories')
        ? instance.getStringList('savedAtomicPropertyCategories')!.map((e) => atomicPropertyFromString(e)).toList()
        : kSavedAtomicPropertyCategories;
  }

  //////////////////////
  ////////////////////// Properties
  //////////////////////

  late bool _enableKeyboardShortcuts;

  set enableKeyboardShortcuts(bool value) {
    instance.setBool('enableKeyboardShortcuts', value);
    _enableKeyboardShortcuts = value;

    notifyListeners();
  }

  bool get enableKeyboardShortcuts => asyncSafeData(() => _enableKeyboardShortcuts) ?? false;

  late bool _shouldPersistAtomicPreviewCategories;

  set shouldPersistAtomicPreviewCategories(bool value) {
    instance.setBool('shouldPersistAtomicPreviewCategories', value);
    _shouldPersistAtomicPreviewCategories = value;

    notifyListeners();
  }

  bool get shouldPersistAtomicPreviewCategories => asyncSafeData(() => _shouldPersistAtomicPreviewCategories) ?? false;

  late List<AtomicProperty> _savedAtomicPropertyCategories;
  static const kSavedAtomicPropertyCategories = [AtomicProperty.boilingPoint, AtomicProperty.atomicMass, AtomicProperty.density];

  List<AtomicProperty> get savedAtomicPropertyCategories => asyncSafeData(() => _savedAtomicPropertyCategories) ?? kSavedAtomicPropertyCategories;
  void setSavedAtomicPropertyCategory(int index, AtomicProperty value) {
    // Imagine using a language that doesn't pass everything by reference, basically we copy the list so we can reuse the setter.
    final copy = List<AtomicProperty>.from(savedAtomicPropertyCategories);

    copy[index] = value;

    savedAtomicPropertyCategories = copy;
  }

  set savedAtomicPropertyCategories(List<AtomicProperty> value) {
    instance.setStringList('savedAtomicPropertyCategories', value.map((e) => e.toString()).toList());
    _savedAtomicPropertyCategories = value;

    notifyListeners();
  }

  late List<CompoundData> _savedCompounds;

  set savedCompounds(List<CompoundData> value) {
    final savedCompounds = value.map((e) => e.serialise()).toList();

    instance.setStringList('savedCompounds', savedCompounds);
    _savedCompounds = value;

    notifyListeners();
  }

  List<CompoundData> get savedCompounds => _savedCompounds;
}

final settingsBlocProvider = ChangeNotifierProvider((ref) => SettingsBloc(ref.read(elementsBlocProvider)));
