import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';

import '../theme.dart';
import 'chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'chemoinfomatics/data.dart';
import 'chemoinfomatics/util.dart';
import '../util.dart';

class InfoBox extends StatefulWidget {
  final AtomicData? element;

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
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              flex: 2,
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
                  // Definitely don't add a key to this
                  _InfoDataRow(
                    element: widget.element!,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AtomicBohrModel(
                widget.element,
                key: ValueKey(widget.element!.symbol + "atomic"),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildNullElement(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: IconWithText(Icons.library_add, header: "Right Click", text: "to mass compounds"),
                    ),
                    Expanded(
                      child: IconWithText(Icons.poll, header: "Switch Views", text: "to explore the rest of the app"),
                    ),
                    Expanded(child: IconWithText(Icons.assignment, header: "Click Element", text: "to naviage to a detailed description")),
                  ])
                ],
              ),
            ),
            Expanded(
              child: AtomicBohrModel(ElementsBloc.of(context).getElementBySymbol('pt')),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoTitle extends StatelessWidget {
  const _InfoTitle({
    Key? key,
    required this.element,
  }) : super(key: key);

  final AtomicData element;

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

  final AtomicData element;

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
        ],
      ),
    );
  }
}

class ElementalInfo extends StatefulWidget {
  final AtomicData elementData;
  final String Function(AtomicData)? intialGetter;
  final String? intialValue;

  ElementalInfo(this.elementData, {this.intialGetter, this.intialValue, Key? key}) : super(key: key);

  @override
  _ElementalInfoState createState() => _ElementalInfoState(infoGetter: intialGetter, displayedValue: intialValue);
}

class _ElementalInfoState extends State<ElementalInfo> {
  final ValueNotifier<AtomicAttributeDataWrapper> attribute;

  _ElementalInfoState({infoGetter, displayedValue}) : this.attribute = ValueNotifier(AtomicAttributeDataWrapper(displayedValue, infoGetter)) {
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

  final ValueNotifier<AtomicAttributeDataWrapper> attribute;
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
          String Function(AtomicData) infoGetter = (_) => "Oh no";
          switch (value) {
            case "Melting Point":
              infoGetter = (AtomicData element) => element.meltingPointValue;
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

          widget.attribute.value = AtomicAttributeDataWrapper(value, infoGetter);

          setState(() {});
        },
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData icon;
  final String text;
  final String header;

  const IconWithText(this.icon, {this.text = "", this.header = "", Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: 100,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w300, fontSize: screenSize.width / 100),
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: Icon(icon, size: screenSize.width / 20, color: Colors.white70),
            ),
            Flexible(
                child: Text(
              header,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
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
