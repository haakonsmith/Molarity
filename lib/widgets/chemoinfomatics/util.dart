import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

/// This is a neat little widget to spit out a unit given a type of data
/// This is denoted by the value parameter
/// See _unitSwitch for a list of supported values
// TODO change this to use an enum
class AtomicUnit extends StatelessWidget {
  const AtomicUnit(this.value, {Key? key, this.fontSize = 24}) : super(key: key);

  final double fontSize;

  final AtomicProperty value;

  @override
  Widget build(BuildContext context) {
    return _unitSwitch();
  }

  Widget _unitSwitch() {
    switch (value) {
      case AtomicProperty.meltingPoint:
        return Math.tex(r'K', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case AtomicProperty.boilingPoint:
        return Math.tex(r'K', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case AtomicProperty.density:
        return Math.tex(r'gL^{-1}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case AtomicProperty.phase:
        return const SizedBox(width: 10, height: 10);

      case AtomicProperty.atomicMass:
        return Math.tex(r'u', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case AtomicProperty.molarHeat:
        return Math.tex(r'Jmol^{-1}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case AtomicProperty.electronNegativity:
        // return Math.tex(r'\text{Pauling scale}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));
        // return Text("Pauling Scale");
        return const SizedBox(width: 10, height: 10);

      case AtomicProperty.electronConfiguration:
        return const SizedBox(width: 10, height: 10);

      default:
        return const SizedBox(width: 10, height: 10);
    }
  }
}
