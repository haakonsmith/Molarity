import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table_tile.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_table.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';

class ElementsBloc extends ChangeNotifier {
  static Future<String> getStringFromPath(String path) async {
    return await rootBundle.loadString(path);
  }

  /// This must reflect the asset path in pubspec.yaml
  static const String periodicTablePath = "assets/periodic_table.json";
  static const String atomicSpectraRootPath = "assets/atomic_images";

  bool _loading = true;
  bool get loading => _loading;

  late List<AtomicData> _elements;
  late Map<String, Image> _spectraImages;

  static Future<List<AtomicData>> _loadElements() async {
    String jsonString = await getStringFromPath(periodicTablePath);
    final json = jsonDecode(jsonString);

    assert(json is List);

    return json.map((d) => AtomicData.fromJson(d)).toList().cast<AtomicData>();
  }

  Future<Map<String, Image>> _loadSpectraImages() async {
    final result = Map<String, Image>();

    _elements.forEach((element) {
      if (element.hasSpectralImage) {
        result[element.name] = Image.asset(
          atomicSpectraRootPath + "/" + element.name + ".jpg",
          fit: BoxFit.fill,
        );
      }

      return null;
    });

    return result;
  }

  ElementsBloc() {
    _asyncDataUpdate(() async {
      _elements = await _loadElements();
      _spectraImages = await _loadSpectraImages();
    });

    // This is done as a seperate step to reduce ui hang while it's loading, as spectral images are likely not used immediately.
    // _asyncDataUpdate(() async {
    // });
  }

  Widget? getSpectralImage(String elementName) => !_loading ? _spectraImages[elementName] : CircularProgressIndicator();

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

  Future<void> _asyncDataUpdate(Future<void> Function() update) async {
    _loading = true;

    await update();

    _loading = false;

    notifyListeners();
  }
}
