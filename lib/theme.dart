import 'package:flutter/material.dart';

import 'BLoC/elements_data_bloc.dart';

final Map<AtomicElementCategory, Color> categoryColorMapping = {
  AtomicElementCategory.actinide: HSLColor.fromAHSL(0.8, 279, 32 / 100, 25 / 100).toColor(),
  AtomicElementCategory.alkaliMetal: HSLColor.fromAHSL(0.8, 345, 37 / 100, 45 / 100).toColor(),
  AtomicElementCategory.alkalineEarthMetal: HSLColor.fromAHSL(0.8, 23, 27 / 100, 49 / 100).toColor(),
  AtomicElementCategory.lanthanide: Color.fromRGBO(120, 107, 151, 0.9),
  AtomicElementCategory.metalloid: Color.fromRGBO(74, 114, 146, 0.9),
  AtomicElementCategory.nobleGas: Color.fromRGBO(136, 100, 170, 0.9),
  AtomicElementCategory.otherNonmetal: Color.fromRGBO(91, 93, 153, 0.9),
  AtomicElementCategory.postTransitionMetal: Color.fromRGBO(74, 134, 119, 0.9),
  AtomicElementCategory.transitionMetal: HSLColor.fromAHSL(0.8, 218, 18 / 100, 44 / 100).toColor(),
  AtomicElementCategory.unknown: Color(0xFF6F6F6F),
};

const MaterialColor mcgpalette0 = MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
  50: Color(0xFFE2E7E8),
  100: Color(0xFFB6C2C5),
  200: Color(0xFF869A9E),
  300: Color(0xFF557177),
  400: Color(0xFF30525A),
  500: Color(_mcgpalette0PrimaryValue),
  600: Color(0xFF0A2F37),
  700: Color(0xFF08272F),
  800: Color(0xFF062127),
  900: Color(0xFF03151A),
});
const int _mcgpalette0PrimaryValue = 0xFF0C343D;

const MaterialColor mcgpalette0Accent = MaterialColor(_mcgpalette0AccentValue, <int, Color>{
  100: Color(0xFF58CFFF),
  200: Color(_mcgpalette0AccentValue),
  400: Color(0xFF00ACF1),
  700: Color(0xFF009AD8),
});
const int _mcgpalette0AccentValue = 0xFF25C1FF;

extension CapExtension on String {
  String get inCaps => this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
