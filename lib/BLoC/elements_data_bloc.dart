import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table.dart';
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

  late List<AtomicData> _elements;

  static Future<List<AtomicData>> _loadElements() async {
    String jsonString = await getElementsJsonString();
    var json = jsonDecode(jsonString);

    assert(json is List);

    List<AtomicData> elements = [];

    elements.addAll(json.map((d) => AtomicData.fromJson(d)).toList().cast<AtomicData>());

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

  List<AtomicData> get elements {
    return !_loading ? _elements : [];
  }

  List<AtomicData> getElements({bool Function(AtomicData)? ignoreThisValue}) {
    if (_loading) return [];

    List<AtomicData> newElements = [];

    for (var i = 0; i < elements.length; i++) {
      bool toBeAdded = !(ignoreThisValue ?? (_) => false)(elements[i]);

      if (toBeAdded) {
        newElements.add(elements[i]);
      }
    }

    return newElements;
  }

  List<FlSpot> getSpotData(double? Function(AtomicData) getter, {bool removeNullValues: false}) {
    List<FlSpot> spotData = [];

    for (var i = 0; i < elements.length; i++) {
      final gotten = getter(elements[i]);

      if (removeNullValues && gotten == null) continue;

      spotData.add(FlSpot(i.toDouble() + 1, gotten ?? 0));
    }

    return spotData;
  }

  AtomicData getElementBySymbol(String symbol) => _elements.firstWhere((element) => element.symbol.toLowerCase() == symbol.toLowerCase());
  AtomicData getElementByAtomicNumber(int atomicNumber) => _elements.firstWhere((element) => element.atomicNumber == atomicNumber);

  static ElementsBloc of(BuildContext context, {listen: false}) {
    return Provider.of<ElementsBloc>(context, listen: listen);
  }
}
