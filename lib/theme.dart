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
  AtomicElementCategory.unknown: Color(0xffcccccc),
};

extension CapExtension on String {
  String get inCaps => this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
