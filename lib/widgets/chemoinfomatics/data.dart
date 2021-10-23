import 'package:flutter/foundation.dart';

/// This is a way of accessing and discussing atomic properties without the amount of strings as before.
enum AtomicProperty {
  meltingPoint,
  boilingPoint,
  density,
  atomicMass,
  molarHeat,
  electronNegativity,
  phase,

  // This is the simplifed electron configuration
  simplifedElectronConfiguration
}

typedef AtomicDataCallback = void Function(AtomicData atomicData);
typedef CompoundDataCallback = void Function(CompoundData compoundData);

class AtomicData {
  AtomicData(
      {required this.name,
      required this.categoryValue,
      required this.hasSpectralImage,
      required this.meltingPoint,
      required this.boilingPoint,
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

  AtomicData.fromJson(Map<String, dynamic> json)
      : atomicNumber = json['number'] as int,
        symbol = json['symbol'] as String,
        electronConfiguration = json['electron_configuration'] as String,
        shells = (json['shells'] as List).cast<int>(),
        category = atomicElementCategoryFromString(json['category'] as String),
        categoryValue = json['category'] as String,
        meltingPoint = parseJsonDouble(json['melt']),
        boilingPoint = parseJsonDouble(json['boil']),
        phase = json['phase'] as String,
        electronNegativity = parseJsonDouble(json['electronegativity_pauling']),
        semanticElectronConfiguration = json['electron_configuration_semantic'] as String,
        ionisationEnergies = (json['ionization_energies'] as List).cast<String>(),
        summary = json['summary'] as String,
        electronAffinity = (json['electron_affinity']).toString(),
        discoveredBy = (json['discovered_by'] ?? 'Unknown') as String,
        molarHeat = json['molar_heat'].toString(),
        hasSpectralImage = json['spectral_img'] != null,
        color = (json['color'] ?? 'Unknown') as String,
        density = parseJsonDouble(json['density']),
        atomicMass = parseJsonDouble(json['atomic_mass']),
        name = json['name'] as String,
        x = (json['xpos'] as int) - 1,
        y = (json['ypos'] as int) - 1;

  int atomicNumber;
  String symbol;
  List<int> shells;
  AtomicElementCategory category;
  String categoryValue;
  String electronConfiguration;
  String name;
  int x, y;
  double? meltingPoint;
  double? boilingPoint;
  String phase;
  String summary;
  double? density;
  double? atomicMass;
  String color;
  String molarHeat;
  String discoveredBy;
  String electronAffinity;
  bool hasSpectralImage;
  double? electronNegativity;
  String semanticElectronConfiguration;
  List<String> ionisationEnergies;

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
  }

  @override
  String toString() => 'Z: $atomicNumber';

  static double? parseJsonDouble(json) {
    if (json == 'null' || json == null)
      return null;
    else
      return (json as num).toDouble();
  }

  List<String> get associatedProperties => <String>[
        'Melting Point',
        'Boiling Point',
        'Density',
        'Atomic Mass',
        'Molar Heat',
        'Electron Negativity',
        'Electron Configuration',
      ];

  String getPropertyStringName(AtomicProperty property) {
    String name;

    switch (property) {
      case AtomicProperty.meltingPoint:
        name = 'Melting Point';
        break;
      case AtomicProperty.boilingPoint:
        name = 'Boiling Point';
        break;
      case AtomicProperty.phase:
        name = 'Phase';
        break;
      case AtomicProperty.density:
        name = 'Density';
        break;
      case AtomicProperty.atomicMass:
        name = 'Atomic Mass';
        break;
      case AtomicProperty.molarHeat:
        name = 'Molar Heat';
        break;
      case AtomicProperty.electronNegativity:
        name = 'Electron Negativity';
        break;
      case AtomicProperty.simplifedElectronConfiguration:
        name = 'Electron Configuration';
        break;
      default:
        name = 'Invalid Property';
    }

    return name;
  }

  String getAssociatedStringValue(String property) {
    String returnValue;

    switch (property) {
      case 'Melting Point':
        returnValue = meltingPoint.toString();
        break;
      case 'Boiling Point':
        returnValue = boilingPoint.toString();
        break;
      case 'Phase':
        returnValue = phase;
        break;
      case 'Density':
        returnValue = density.toString();
        break;
      case 'Atomic Mass':
        returnValue = atomicMass?.toStringAsFixed(3) ?? 'Unknown';
        break;
      case 'Molar Heat':
        returnValue = molarHeat;
        break;
      case 'Electron Negativity':
        returnValue = electronNegativity.toString();
        break;
      case 'Electron Configuration':
        String electronConfig = '';
        final List<String> electrons = semanticElectronConfiguration.split(' ');

        for (int i = 0; i < electrons.length; i++) {
          final String electron = electrons[i];

          if (i == 3)
            electronConfig += '\n$electron';
          else
            electronConfig += ' $electron';
        }

        returnValue = electronConfig.trim();

        break;
      default:
        returnValue = 'Invalid Info Getter Value';
    }

    return returnValue;
  }
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

class CompoundData extends ChangeNotifier {
  CompoundData(this.rawCompound);

  factory CompoundData.fromList(List<AtomicData> elements) {
    final Map<AtomicData, int> compoundMap = {};

    for (final AtomicData element in elements) compoundMap.update(element, (int value) => value + 1, ifAbsent: () => 1);

    return CompoundData(compoundMap);
  }

  factory CompoundData.fromAtomicData(AtomicData element) => CompoundData.fromList([element]);

  CompoundData.empty() : rawCompound = {};

  void clear() {
    rawCompound.clear();
  }

  final Map<AtomicData, int> rawCompound;

  double get molarMass {
    double molarMass = 0;

    rawCompound.forEach((AtomicData key, int value) {
      molarMass += double.parse(key.getAssociatedStringValue('Atomic Mass')) * value;
    });

    return molarMass;
  }

  CompoundData copy() {
    return CompoundData(Map<AtomicData, int>.from(rawCompound));
  }

  CompoundData addElement(AtomicData element) {
    rawCompound.update(element, (int value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
    print("here2");

    return this;
  }

  String toMolecularFormula() {
    String formula = '';

    rawCompound.forEach((AtomicData key, int value) {
      formula += key.symbol + (value == 1 ? '' : value.toString());
    });

    return formula;
  }

  String toTex() {
    String tex = '';

    rawCompound.forEach((AtomicData key, int value) {
      if (value == 1)
        tex += key.symbol;
      else
        tex += '${key.symbol}_{$value}';
    });

    return tex;
  }

  CompoundData operator +(AtomicData other) => addElement(other);
}
