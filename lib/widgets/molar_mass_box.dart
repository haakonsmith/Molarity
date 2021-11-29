import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/preferenced_compounds.dart';
import 'package:molarity/util.dart';

import 'package:molarity/widgets/chemoinfomatics/data.dart';

class MolarMassBox extends ConsumerStatefulWidget {
  const MolarMassBox({required this.compound, this.onClear, Key? key, this.onClose, this.onSave}) : super(key: key);

  final CompoundData compound;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final CompoundDataCallback? onSave;

  @override
  _MolarMassBoxState createState() => _MolarMassBoxState();
}

class _MolarMassBoxState extends ConsumerState<MolarMassBox> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final clearButton = _ControlButton(
      icon: const Icon(Icons.delete_forever),
      onTap: widget.onClear,
    );

    final closeButton = _ControlButton(
      icon: const Icon(Icons.close),
      onTap: widget.onClose,
    );

    final saveButton = _ControlButton(
      icon: const Icon(Icons.save),
      onTap: () {
        ref.read(preferencedCompoundsProvider).addSavedCompound(widget.compound.copy());

        widget.onSave?.call(widget.compound);
      },
    );

    final copyToClipboard = _ControlButton(
      icon: const Icon(Icons.copy),
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.compound.molarMass.toString()));
      },
    );

    final double fontSize = orientation == Orientation.landscape ? screenSize.width / 80 : 14;

    final math = Math.tex(
      _generateText(),
      textStyle: TextStyle(fontSize: fontSize),
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
            '=${widget.compound.toTex()}',
            textStyle: TextStyle(fontSize: fontSize),
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
                      '=' + widget.compound.molarMass.toStringAsFixed(2) + r'gmol^{-1}',
                      textStyle: TextStyle(fontSize: fontSize),
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
    String str = '= \~\~';

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
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
