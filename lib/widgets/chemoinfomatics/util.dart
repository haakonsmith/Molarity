import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// This is a neat little widget to spit out a unit given a type of data
/// This is denoted by the value parameter
/// See _unitSwitch for a list of supported values
// TODO change this to use an enum
class AtomicUnit extends StatelessWidget {
  final double fontSize;

  const AtomicUnit(this.value, {Key? key, this.fontSize = 24}) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return _unitSwitch();
  }

  Widget _unitSwitch() {
    switch (value) {
      case "Melting Point":
        return Math.tex(r'K', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Boiling Point":
        return Math.tex(r'K', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Density":
        return Math.tex(r'gL^{-1}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Phase":
        return const SizedBox(width: 10, height: 10);

      case "Atomic Mass":
        return Math.tex(r'u', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Molar Heat":
        return Math.tex(r'Jmol^{-1}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Electron Negativity":
        return Math.tex(r'\text{Pauling scale}', textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200));

      case "Electron Configuration":
        return const SizedBox(width: 10, height: 10);

      default:
        return const SizedBox(width: 10, height: 10);
    }
  }
}
