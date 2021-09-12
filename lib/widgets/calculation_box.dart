import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'chemoinfomatics/data.dart';

class MolarMassBox extends StatefulWidget {
  final CompoundData compound;
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
      child: Card(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 60),
                      child: Text(
                        _generateText(),
                        style: TextStyle(fontSize: screenSize.width / 80),
                        maxLines: 3,
                      ),
                    ),
                  ),
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
                          r"gmol^{-1}",
                          textScaleFactor: screenSize.width / 1000,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              // heightFactor: 10.5,
              alignment: Alignment.topRight,
              child: Card(
                elevation: 10,
                margin: EdgeInsets.all(15),
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onTap: widget.onClear!,
                    child: Icon(
                      Icons.close,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
