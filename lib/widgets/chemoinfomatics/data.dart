class AtomicData {
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

  AtomicData(
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
  }

  AtomicData.fromJson(Map json)
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

  List<String> get associatedProperties => [
        'Melting Point',
        'Boiling Point',
        'Density',
        'Atomic Mass',
        'Molar Heat',
        'Electron Negativity',
        'Electron Configuration',
      ];

  String getAssociatedStringValue(String value) {
    String returnValue;

    switch (value) {
      case "Melting Point":
        returnValue = meltingPointValue;
        break;
      case "Boiling Point":
        returnValue = boilingPointValue;
        break;
      case "Phase":
        returnValue = phase;
        break;
      case "Density":
        returnValue = density;
        break;
      case "Atomic Mass":
        returnValue = atomicMass;
        break;
      case "Molar Heat":
        returnValue = molarHeat;
        break;
      case "Electron Negativity":
        returnValue = electronNegativity;
        break;
      case "Electron Configuration":
        String electronConfig = '';
        final electrons = semanticElectronConfiguration.split(' ');
        for (var i = 0; i < electrons.length; i++) {
          final electron = electrons[i];

          if (i == 3)
            electronConfig += '\n' + electron;
          else
            electronConfig += ' ' + electron;
        }

        returnValue = electronConfig.trim();

        break;
      default:
        returnValue = "Invalid Info Getter Value";
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

class CompoundData {
  final Map<AtomicData, int> rawCompound;

  CompoundData(this.rawCompound);

  factory CompoundData.fromList(List<AtomicData> elements) {
    Map<AtomicData, int> compoundMap = {};

    elements.forEach((element) {
      compoundMap.update(element, (value) => value + 1, ifAbsent: () => 1);
    });

    return CompoundData(compoundMap);
  }

  double get molarMass {
    double molarMass = 0;

    rawCompound.forEach((key, value) {
      molarMass += double.parse(key.atomicMass) * value;
    });

    return molarMass;
  }

  CompoundData addElement(AtomicData element) {
    rawCompound.update(element, (value) => value + 1, ifAbsent: () => 1);
    return this;
  }

  String toTex() {
    String tex = "";

    rawCompound.forEach((key, value) {
      if (value == 1)
        tex += "${key.symbol}";
      else
        tex += "${key.symbol}_$value";
    });

    return tex;
  }
}
