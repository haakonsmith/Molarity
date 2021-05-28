import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';

class Compound {
  final Map<ElementData, int> rawCompound;

  Compound(this.rawCompound);

  factory Compound.fromList(List<ElementData> elements) {
    Map<ElementData, int> compoundMap = {};

    elements.forEach((element) {
      compoundMap.update(element, (value) => value + 1, ifAbsent: () => 1);
    });

    return Compound(compoundMap);
  }

  double get molarMass {
    double molarMass = 0;

    rawCompound.forEach((key, value) {
      molarMass += double.parse(key.atomicMass) * value;
    });

    return molarMass;
  }

  Compound addElement(ElementData element) {
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

class MolarMassBox extends StatefulWidget {
  final Compound compound;
  final VoidCallback? onClear;

  MolarMassBox({required this.compound, this.onClear, Key? key}) : super(key: key);

  @override
  _MolarMassBoxState createState() => _MolarMassBoxState();
}

class _MolarMassBoxState extends State<MolarMassBox> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    print(screenSize.width / 80);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Container(
        color: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: widget.onClear!,
              icon: Icon(
                Icons.close,
                // size: screenSize.width / 40,
              ),
              padding: const EdgeInsets.all(0),
              iconSize: screenSize.width / 40,
              splashRadius: screenSize.width / 40,
              constraints: BoxConstraints.tightFor(width: screenSize.width / 20, height: screenSize.width / 20),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                _generateText(),
                style: TextStyle(fontSize: screenSize.width / 80),
                maxLines: 3,
              )),
              Expanded(
                child: Row(
                  children: [
                    Math.tex(
                      widget.compound.toTex(),
                      textScaleFactor: screenSize.width / 1000,
                    ),
                    Spacer(),
                    Text(
                      widget.compound.molarMass.toStringAsFixed(2),
                      textScaleFactor: screenSize.width / 1000,
                    ),
                    Math.tex(
                      r"molg^{-1}",
                      textScaleFactor: screenSize.width / 1000,
                    ),
                  ],
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }

  String _generateText() {
    String str = "";

    widget.compound.rawCompound.forEach((key, value) {
      str += "$value(${key.atomicMass}) + ";
    });

    return str.substring(0, str.length - 3);
  }
}
