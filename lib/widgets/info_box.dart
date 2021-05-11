import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';

import '../theme.dart';
import 'atomic_bohr_model.dart';

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
              Center(child: IconWithText(Icons.library_add, size: iconSize, header: "Right Click", text: "to mass compounds")),
              Expanded(child: IconWithText(Icons.poll, size: iconSize, header: "Switch Views", text: "to explore the rest of the app")),
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
                intialGetter: () => widget.element.boilingPointValue,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: ElementalInfo(
                widget.element,
                intialValue: "Melting Point",
                intialGetter: () => widget.element.meltingPointValue,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: ElementalInfo(
                widget.element,
                intialValue: "Phase",
                intialGetter: () => widget.element.phase,
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

class _ElementalAttributeDataWrapper {
  final String Function()? infoGetter;
  final String? value;

  _ElementalAttributeDataWrapper(this.value, this.infoGetter);
}

class ElementalInfo extends StatefulWidget {
  final ElementData elementData;
  final String Function()? intialGetter;
  final String? intialValue;

  ElementalInfo(this.elementData, {this.intialGetter, this.intialValue, Key? key}) : super(key: key);

  @override
  _ElementalInfoState createState() => _ElementalInfoState(infoGetter: intialGetter, displayedValue: intialValue);
}

class _ElementalInfoState extends State<ElementalInfo> {
  final ValueNotifier<_ElementalAttributeDataWrapper> attribute;

  _ElementalInfoState({infoGetter, displayedValue}) : this.attribute = ValueNotifier(_ElementalAttributeDataWrapper(displayedValue, infoGetter)) {
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
    var dropDown = _ElementAttributeSelector(
      attribute: attribute,
      element: widget.elementData,
    );

    return Column(
      children: [
        dropDown,
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            attribute.value.infoGetter!() == "null" ? "Unknown" : attribute.value.infoGetter!(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          ),
        )
      ],
    );
  }
}

class _ElementAttributeSelector extends StatefulWidget {
  const _ElementAttributeSelector({
    required this.attribute,
    Key? key,
    required this.element,
  }) : super(key: key);

  final ElementData element;
  final ValueNotifier<_ElementalAttributeDataWrapper> attribute;

  @override
  State<StatefulWidget> createState() => _ElementAttributeSelectorState();
}

class _ElementAttributeSelectorState extends State<_ElementAttributeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: DropdownButton<String>(
        // underline: Container(),
        value: widget.attribute.value.value,
        items: <String>[
          'Melting Point',
          'Boiling Point',
          'Phase',
          'Density',
          'Atomic Mass',
          'Molar Heat',
          'Electron Negativity',
          // 'First Ionisation Energy',
          'Electron Configuration',
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
            ),
          );
        }).toList(),
        onChanged: (value) {
          String Function() infoGetter = () => "Oh no";
          switch (value) {
            case "Melting Point":
              infoGetter = () => widget.element.meltingPointValue;
              break;
            case "Boiling Point":
              infoGetter = () => widget.element.boilingPointValue;
              break;
            case "Phase":
              infoGetter = () => widget.element.phase;
              break;
            case "Density":
              infoGetter = () => widget.element.density;
              break;
            case "Atomic Mass":
              infoGetter = () => widget.element.atomicMass;
              break;
            case "Molar Heat":
              infoGetter = () => widget.element.molarHeat;
              break;
            case "Electron Negativity":
              infoGetter = () => widget.element.electronNegativity;
              break;
            // case "First Ionisation Energy":
            //   infoGetter = () => widget.element.ionisationEnergies.isEmpty ? "Uknown" : widget.element.ionisationEnergies[0].toString();
            //   break;
            case "Electron Configuration":
              infoGetter = () => widget.element.semanticElectronConfiguration;
              break;
          }
          widget.attribute.value = _ElementalAttributeDataWrapper(value, infoGetter);

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
            Text(header, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
