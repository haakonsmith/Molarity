import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/preferenced_compounds.dart';

import 'chemoinfomatics/data.dart';

class MolarMassBox extends ConsumerStatefulWidget {
  final CompoundData compound;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final CompoundDataCallback? onSave;

  MolarMassBox({required this.compound, this.onClear, Key? key, this.onClose, this.onSave}) : super(key: key);

  @override
  _MolarMassBoxState createState() => _MolarMassBoxState();
}

class _MolarMassBoxState extends ConsumerState<MolarMassBox> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final clearButton = _ControlButton(
      icon: Icon(Icons.delete_forever),
      onTap: widget.onClear,
    );

    final closeButton = _ControlButton(
      icon: Icon(Icons.close),
      onTap: widget.onClose,
    );

    final saveButton = _ControlButton(
      icon: Icon(Icons.save),
      onTap: () {
        ref.read(preferencedCompoundsProvider).addSavedCompound(widget.compound.copy());

        widget.onSave?.call(widget.compound);
      },
    );

    final copyToClipboard = _ControlButton(
      icon: Icon(Icons.copy),
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.compound.molarMass.toString()));
      },
    );

    final math = Math.tex(
      _generateText(),
      textStyle: TextStyle(fontSize: screenSize.width / 80),
      // textScaleFactor: screenSize.width / 1000,
      // maxLines: 3,
    ).texBreak().parts;

    final controlPanel = Card(
      elevation: 10,
      margin: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [clearButton, saveButton, closeButton, copyToClipboard],
      ),
    );

    final working = Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 60),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: math,
          ),
        ),
      ),
    );

    final molecularFormula = Expanded(
      child: Row(
        children: [
          Math.tex(
            "=" + widget.compound.toTex(),
            textScaleFactor: screenSize.width / 1000,
          ),
        ],
      ),
    );

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
                  working,
                  molecularFormula,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Math.tex(
                      "=" + widget.compound.molarMass.toStringAsFixed(2) + r"gmol^{-1}",
                      textScaleFactor: screenSize.width / 1000,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              // heightFactor: 10.5,
              alignment: Alignment.centerRight,
              child: FittedBox(child: controlPanel),
            ),
          ],
        ),
      ),
    );
  }

  String _generateText() {
    String str = "= \~\~";

    widget.compound.rawCompound.forEach((key, value) {
      str += '$value(${key.atomicMass?.toStringAsFixed(2)})\~ + \~';
    });

    return str.substring(0, str.length - 5);
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    Key? key,
    this.onTap,
    this.icon,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: InkWell(
        borderRadius: const BorderRadius.all(const Radius.circular(20)),
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
