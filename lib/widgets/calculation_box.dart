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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Container(
        color: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(onPressed: widget.onClear!, icon: Icon(Icons.cancel_presentation_sharp)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                _generateText(),
                style: const TextStyle(fontSize: 20),
                maxLines: 3,
              )),
              Expanded(
                child: Row(children: [Spacer(), Text(widget.compound.molarMass.toStringAsFixed(2)), Math.tex(r"molg^{-1}")]),
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
