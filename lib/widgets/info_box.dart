import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';

import '../theme.dart';
import 'atomic_bohr_model.dart';

class AtomicUnit extends StatelessWidget {
  final double fontSize;

  const AtomicUnit(this.value, {Key? key, this.fontSize = 24}) : super(key: key);

  final String value;

  // final Map<String, Widget> atomicUnitMap = {
  //   "Melting Point": Math.tex(r'K', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200)),
  //   "Boiling Point": Math.tex(r'K', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200)),
  //   "Density": Math.tex(r'gL^{-1}', textStyle: const TextStyle(fontWeight: FontWeight.w200)),
  //   "Phase": const SizedBox(width: 10, height: 10),
  //   "Atomic Mass": Math.tex(r'u', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200)),
  //   "Molar Heat": Math.tex(r'Jmol^{-1}', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200)),
  //   "Electron Negativity": Math.tex(r'\text{Pauling scale}', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200)),
  //   "Electron Configuration": const SizedBox(width: 10, height: 10),
  // };

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
        return Math.tex(r'gL^{-1}', textStyle: const TextStyle(fontWeight: FontWeight.w200));

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

class InfoBox extends StatefulWidget {
  final ElementData? element;

  InfoBox({this.element, Key? key}) : super(key: key);

  @override
  _InfoBoxState createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  @override
  Widget build(BuildContext context) {
    return widget.element == null ? _buildNullElement(context) : _buildElementInfo(context);
  }

  Widget _buildElementInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: _InfoTitle(
                    element: widget.element!,
                  ),
                ),
              ),
              _InfoDataRow(
                element: widget.element!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNullElement(BuildContext context) {
    final double iconSize = MediaQuery.of(context).size.width * 0.05;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // constraints: BoxConstraints.expand(height: 100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(
                child: IconWithText(Icons.library_add, size: iconSize, header: "Right Click", text: "to mass compounds"),
              ),
              Expanded(
                child: IconWithText(Icons.poll, size: iconSize, header: "Switch Views", text: "to explore the rest of the app"),
              ),
              Expanded(child: IconWithText(Icons.assignment, size: iconSize, header: "Click Element", text: "to naviage to a detailed description")),
              Expanded(child: AtomicBohrModel(ElementsBloc.of(context).getElementBySymbol('pt'))),
            ]),
          ),
        ));
  }
}

class _InfoTitle extends StatelessWidget {
  const _InfoTitle({
    Key? key,
    required this.element,
  }) : super(key: key);

  final ElementData element;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "${element.atomicNumber.toString()} – ${element.name}",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w200,
        ),
      ),
      Text(
        element.categoryValue.capitalizeFirstofEach,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: categoryColorMapping[element.category],
          fontSize: 7,
        ),
      ),
    ]);
  }
}

class _InfoDataRow extends StatefulWidget {
  const _InfoDataRow({
    Key? key,
    required this.element,
  }) : super(key: key);

  final ElementData element;

  @override
  State<StatefulWidget> createState() => _InfoDataRowState();
}

class _InfoDataRowState extends State<_InfoDataRow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: ElementalInfo(
                widget.element,
                intialValue: "Boiling Point",
                intialGetter: (element) => element.boilingPointValue,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: ElementalInfo(
                widget.element,
                intialValue: "Melting Point",
                intialGetter: (element) => element.meltingPointValue,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: ElementalInfo(
                widget.element,
                intialValue: "Phase",
                intialGetter: (element) => element.phase,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AtomicBohrModel(
                widget.element,
                key: ValueKey(widget.element.symbol + "atomic"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementalAttributeDataWrapper {
  final String Function(ElementData)? infoGetter;
  final String? value;

  ElementalAttributeDataWrapper(this.value, this.infoGetter);
}

class ElementalInfo extends StatefulWidget {
  final ElementData elementData;
  final String Function(ElementData)? intialGetter;
  final String? intialValue;

  ElementalInfo(this.elementData, {this.intialGetter, this.intialValue, Key? key}) : super(key: key);

  @override
  _ElementalInfoState createState() => _ElementalInfoState(infoGetter: intialGetter, displayedValue: intialValue);
}

class _ElementalInfoState extends State<ElementalInfo> {
  final ValueNotifier<ElementalAttributeDataWrapper> attribute;

  _ElementalInfoState({infoGetter, displayedValue}) : this.attribute = ValueNotifier(ElementalAttributeDataWrapper(displayedValue, infoGetter)) {
    this.attribute.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    attribute.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dropDown = ElementAttributeSelector(
      attribute: attribute,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        dropDown,
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                attribute.value.infoGetter!(widget.elementData) == "null" ? "Unknown" : attribute.value.infoGetter!(widget.elementData),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200),
              ),
              AtomicUnit(attribute.value.value!)
            ],
          ),
        ),
      ],
    );
  }
}

class ElementAttributeSelector extends StatefulWidget {
  const ElementAttributeSelector({
    required this.attribute,
    Key? key,
    this.selectables = defualtSelectables,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final ValueNotifier<ElementalAttributeDataWrapper> attribute;
  final List<String> selectables;

  static const defualtSelectables = const <String>[
    'Melting Point',
    'Boiling Point',
    'Phase',
    'Density',
    'Atomic Mass',
    'Molar Heat',
    'Electron Negativity',
    // 'First Ionisation Energy',
    'Electron Configuration',
  ];

  final backgroundColor;

  @override
  State<StatefulWidget> createState() => _ElementAttributeSelectorState();
}

class _ElementAttributeSelectorState extends State<ElementAttributeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: widget.backgroundColor,
      child: DropdownButton<String>(
        // underline: Container(),
        value: widget.attribute.value.value,
        items: widget.selectables.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
            ),
          );
        }).toList(),
        onChanged: (value) {
          String Function(ElementData) infoGetter = (_) => "Oh no";
          switch (value) {
            case "Melting Point":
              infoGetter = (ElementData element) => element.meltingPointValue;
              break;
            case "Boiling Point":
              infoGetter = (element) => element.boilingPointValue;
              break;
            case "Phase":
              infoGetter = (element) => element.phase;
              break;
            case "Density":
              infoGetter = (element) => element.density;
              break;
            case "Atomic Mass":
              infoGetter = (element) => element.atomicMass;
              break;
            case "Molar Heat":
              infoGetter = (element) => element.molarHeat;
              break;
            case "Electron Negativity":
              infoGetter = (element) => element.electronNegativity;
              break;
            // case "First Ionisation Energy":
            //   infoGetter = (element) => element.ionisationEnergies.isEmpty ? "Uknown" : widget.element.ionisationEnergies[0].toString();
            //   break;
            case "Electron Configuration":
              infoGetter = (element) {
                String electronConfig = '';
                element.semanticElectronConfiguration.split(' ').forEachIndexed((element, i) {
                  if (i == 3)
                    electronConfig += '\n' + element;
                  else
                    electronConfig += ' ' + element;
                });

                return electronConfig.trim();
              };
              break;
          }

          widget.attribute.value = ElementalAttributeDataWrapper(value, infoGetter);

          setState(() {});
        },
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final double size;
  final IconData icon;
  final String text;
  final String header;

  IconWithText(this.icon, {this.size = 8, this.text = "", this.header = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w300, fontSize: 10),
        child: Column(
          children: [
            Icon(icon, size: size, color: Colors.white70),
            Flexible(child: Text(header, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
    );
  }
}
