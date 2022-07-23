import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

class ElementsBloc extends ChangeNotifier with AsyncSafeData {
  ElementsBloc() {
    final elementsFuture = asyncDataUpdate(() async {
      _elements = await _loadElements();
      notifyListeners();
    });

    // This is done as a seperate step to reduce ui hang while it's loading, as spectral images are likely not used immediately.
    asyncDataUpdate(() async {
      await elementsFuture;
      _spectraImages = await _loadSpectraImages();
      notifyListeners();
    });
  }

  /// This must reflect the asset path in pubspec.yaml
  static const String periodicTablePath = 'assets/periodic_table.json';
  static const String atomicSpectraRootPath = 'assets/atomic_images';

  late List<AtomicData> _elements;
  late Map<String, Image> _spectraImages;

  static Future<List<AtomicData>> _loadElements() async {
    final String jsonString = await rootBundle.loadString(periodicTablePath);
    // ignore: always_specify_types
    final json = jsonDecode(jsonString);

    assert(json is List);

    // ignore: avoid_dynamic_calls
    return json.map((d) => AtomicData.fromJson(d)).toList().cast<AtomicData>();
  }

  Future<Map<String, Image>> _loadSpectraImages() async {
    final Map<String, Image> result = {};

    for (final AtomicData element in _elements) {
      if (element.hasSpectralImage) {
        result[element.name] = Image.asset(
          '$atomicSpectraRootPath/emission_spectrum/${element.name}.jpg',
          fit: BoxFit.fill,
        );
      }
    }

    return result;
  }

  Widget? getSpectralImage(String elementName) => asyncSafeData(() => _spectraImages[elementName] as Widget) ?? const CircularProgressIndicator();

  List<AtomicData> get elements => asyncSafeData(() => _elements) ?? [];

  List<AtomicData> getElements({bool Function(AtomicData)? ignoreThisValue}) {
    if (loading) return [];

    final List<AtomicData> newElements = [];

    for (var i = 0; i < elements.length; i++) {
      final bool toBeAdded = !(ignoreThisValue ?? (_) => false)(elements[i]);

      if (toBeAdded) {
        newElements.add(elements[i]);
      }
    }

    return newElements;
  }

  List<FlSpot> getSpotData(double? Function(AtomicData) getter, {bool removeNullValues = false}) {
    final List<FlSpot> spotData = [];

    for (int i = 0; i < elements.length; i++) {
      final double? gotten = getter(elements[i]);

      if (removeNullValues && gotten == null) continue;

      spotData.add(FlSpot(i.toDouble() + 1, gotten ?? 0));
    }

    return spotData;
  }

  AtomicData getElementBySymbol(String symbol) => _elements.firstWhere((element) => element.symbol.toLowerCase() == symbol.toLowerCase());
  AtomicData getElementByAtomicNumber(int atomicNumber) => _elements.firstWhere((element) => element.atomicNumber == atomicNumber);
}

final elementsBlocProvider = ChangeNotifierProvider((_) => ElementsBloc());
