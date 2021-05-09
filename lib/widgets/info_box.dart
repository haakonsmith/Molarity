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
    var title = FittedBox(
        fit: BoxFit.fitHeight,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "${widget.element!.atomicNumber.toString()} – ${widget.element!.name}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            widget.element!.categoryValue.capitalizeFirstofEach,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: categoryColorMapping[widget.element!.category],
              fontSize: 7,
            ),
          ),
        ]));

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
                child: title,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: ElementalInfo(
                          widget.element!,
                          intialValue: "Boiling Point",
                          intialGetter: () => widget.element!.boilingPointValue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: ElementalInfo(
                          widget.element!,
                          intialValue: "Melting Point",
                          intialGetter: () => widget.element!.meltingPointValue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: ElementalInfo(
                          widget.element!,
                          intialValue: "Phase",
                          intialGetter: () => widget.element!.phase,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AtomicBohrModel(widget.element),
                    ),
                  ],
                ),
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

class ElementalInfo extends StatefulWidget {
  final ElementData elementData;
  final String Function()? intialGetter;
  final String? intialValue;

  ElementalInfo(this.elementData, {this.intialGetter, this.intialValue, Key? key}) : super(key: key);

  @override
  _ElementalInfoState createState() => _ElementalInfoState(displayedInfoGetter: intialGetter, displayedValue: intialValue);
}

class _ElementalInfoState extends State<ElementalInfo> {
  String Function()? displayedInfoGetter = () => "Fuclk something is wrong";
  String? displayedValue = "Melting Point";

  _ElementalInfoState({this.displayedInfoGetter, this.displayedValue});

  @override
  Widget build(BuildContext context) {
    var dropDown = Container(
      child: DropdownButton<String>(
        underline: Container(),
        value: displayedValue,
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
              style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            displayedValue = value!;

            switch (value) {
              case "Melting Point":
                displayedInfoGetter = () => widget.elementData.meltingPointValue;
                print(widget.elementData.ionisationEnergies);
                break;
              case "Boiling Point":
                displayedInfoGetter = () => widget.elementData.boilingPointValue;
                break;
              case "Phase":
                displayedInfoGetter = () => widget.elementData.phase;
                break;
              case "Density":
                displayedInfoGetter = () => widget.elementData.density;
                break;
              case "Atomic Mass":
                displayedInfoGetter = () => widget.elementData.atomicMass;
                break;
              case "Molar Heat":
                displayedInfoGetter = () => widget.elementData.molarHeat;
                break;
              case "Electron Negativity":
                displayedInfoGetter = () => widget.elementData.electronNegativity;
                break;
              // case "First Ionisation Energy":
              //   displayedInfoGetter = () => widget.elementData.ionisationEnergies.isEmpty ? "Uknown" : widget.elementData.ionisationEnergies[0].toString();
              //   break;
              case "Electron Configuration":
                displayedInfoGetter = () => widget.elementData.semanticElectronConfiguration;
                break;
            }
          });
        },
      ),
    );

    return Column(
      children: [
        dropDown,
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            displayedInfoGetter!() == "null" ? "Unknown" : displayedInfoGetter!(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          ),
        )
      ],
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
