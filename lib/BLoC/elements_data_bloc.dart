import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:molarity/widgets/periodic_table.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';

class ElementsBloc extends ChangeNotifier {
  static Future<String> getElementsJsonString() async {
    return await rootBundle.loadString(path);
  }

  /// This must reflect the asset path in pubspec.yaml
  static const String path = "assets/periodic_table.json";

  bool _loading = true;
  bool get loading => _loading;

  late List<ElementData> _elements;

  static Future<List<ElementData>> _loadElements() async {
    String jsonString = await getElementsJsonString();
    var json = jsonDecode(jsonString);

    assert(json is List);

    List<ElementData> elements = [];

    elements.addAll(json.map((d) => ElementData.fromJson(d)).toList().cast<ElementData>());

    return elements;
  }

  Future<void> _init() async {
    _loading = true;

    // set defaults
    _elements = await _loadElements();

    _loading = false;

    notifyListeners();
  }

  ElementsBloc() {
    _init();

    print(_loading);
  }

  List<ElementData> get elements {
    return !_loading ? _elements : [];
  }

  List<ElementData> getElements({bool Function(ElementData)? ignoreThisValue}) {
    if (_loading) return [];

    List<ElementData> newElements = [];

    for (var i = 0; i < elements.length; i++) {
      bool toBeAdded = !(ignoreThisValue ?? (_) => false)(elements[i]);

      if (toBeAdded) {
        newElements.add(elements[i]);
      }
    }

    return newElements;
  }

  List<FlSpot> getSpotData(double? Function(ElementData) getter, {bool removeNullValues: false}) {
    List<FlSpot> spotData = [];

    for (var i = 0; i < elements.length; i++) {
      final gotten = getter(elements[i]);

      if (removeNullValues && gotten == null) continue;

      spotData.add(FlSpot(i.toDouble() + 1, gotten ?? 0));
    }

    return spotData;
  }

  ElementData getElementBySymbol(String symbol) => _elements.firstWhere((element) => element.symbol.toLowerCase() == symbol.toLowerCase());
  ElementData getElementByAtomicNumber(int atomicNumber) => _elements.firstWhere((element) => element.atomicNumber == atomicNumber);

  List<Widget> get elementsTable {
    List<Widget> elements = [];

    for (var i = 0; i < _elements.length; i++) {
      elements.add(PeriodicTableTile(_elements[i]));
    }

    return elements;
  }

  static ElementsBloc of(BuildContext context, {listen: false}) {
    return Provider.of<ElementsBloc>(context, listen: listen);
  }
}

class ElementData {
  int atomicNumber;
  String symbol;
  List<int> shells;
  AtomicElementCategory category;
  String categoryValue;
  String electronConfiguration;
  String name;
  int x, y;
  String meltingPointValue;
  String boilingPointValue;
  String phase;
  String summary;
  String density;
  String atomicMass;
  String color;
  String molarHeat;
  String discoveredBy;
  String electronAffinity;
  String electronNegativity;
  String semanticElectronConfiguration;
  List<String> ionisationEnergies;

  double? get meltingPoint => double.tryParse(meltingPointValue);

  ElementData(
      {required this.name,
      required this.categoryValue,
      required this.meltingPointValue,
      required this.boilingPointValue,
      required this.electronConfiguration,
      required this.shells,
      required this.phase,
      required this.summary,
      required this.density,
      required this.atomicMass,
      required this.molarHeat,
      required this.electronNegativity,
      required this.electronAffinity,
      required this.discoveredBy,
      required this.color,
      required this.semanticElectronConfiguration,
      required this.ionisationEnergies,
      required this.x,
      required this.y,
      required this.category,
      required this.atomicNumber,
      required this.symbol});

  static AtomicElementCategory atomicElementCategoryFromString(String string) {
    switch (string) {
      case 'actinide':
        return AtomicElementCategory.actinide;
      case 'alkali metal':
        return AtomicElementCategory.alkaliMetal;
      case 'alkaline earth metal':
        return AtomicElementCategory.alkalineEarthMetal;
      case 'diatomic nonmetal':
        return AtomicElementCategory.otherNonmetal;
      case 'lanthanide':
        return AtomicElementCategory.lanthanide;
      case 'metalloid':
        return AtomicElementCategory.metalloid;
      case 'noble gas':
        return AtomicElementCategory.nobleGas;
      case 'polyatomic nonmetal':
        return AtomicElementCategory.otherNonmetal;
      case 'post-transition metal':
        return AtomicElementCategory.postTransitionMetal;
      case 'transition metal':
        return AtomicElementCategory.transitionMetal;
    }

    assert(string.startsWith('unknown'));
    return AtomicElementCategory.unknown;
    // return AtomicElementCategory.values
    //     .firstWhere((e) => e.toString().replaceAll(' ', '').replaceFirst("AtomicElementCategory.", "") == string.replaceFirst("AtomicElementCategory.", "").toLowerCase());
  }

  ElementData.fromJson(Map json)
      : this.atomicNumber = json["number"] as int,
        this.symbol = json["symbol"] as String,
        this.electronConfiguration = json["electron_configuration"] as String,
        this.shells = (json["shells"] as List).cast<int>(),
        this.category = atomicElementCategoryFromString(json['category'] as String),
        this.categoryValue = json["category"] as String,
        this.meltingPointValue = (json["melt"]).toString(),
        this.boilingPointValue = (json["boil"]).toString(),
        this.phase = json["phase"] as String,
        this.electronNegativity = (json["electronegativity_pauling"]).toString(),
        this.semanticElectronConfiguration = json["electron_configuration_semantic"] as String,
        this.ionisationEnergies = (json["ionization_energies"] as List).cast<String>(),
        this.summary = json["summary"] as String,
        this.electronAffinity = (json["electron_affinity"]).toString(),
        this.discoveredBy = (json["discovered_by"] ?? "Unknown") as String,
        this.molarHeat = json["molar_heat"].toString(),
        this.color = (json["color"] ?? "Uknown") as String,
        this.density = json["density"].toString(),
        this.atomicMass = json["atomic_mass"].toStringAsPrecision(3) as String,
        this.name = json["name"] as String,
        this.x = (json['xpos'] as int) - 1,
        this.y = (json['ypos'] as int) - 1;

  String toString() => "Z: $atomicNumber";
}

enum AtomicElementCategory {
  actinide,
  alkaliMetal,
  alkalineEarthMetal,
  lanthanide,
  metalloid,
  nobleGas,
  otherNonmetal,
  postTransitionMetal,
  transitionMetal,
  unknown,
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}
