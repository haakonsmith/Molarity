import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';

import '../theme.dart';
import 'chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'chemoinfomatics/data.dart';
import 'chemoinfomatics/util.dart';
import '../util.dart';

class InfoBox extends HookConsumerWidget {
  final AtomicData? element;

  InfoBox({this.element, Key? key}) : super(key: key);

  late ElementsBloc elementsBloc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    elementsBloc = ref.watch(elementsBlocProvider);

    return element == null ? _buildNullElement(context) : _buildElementInfo(context);
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
                      fit: BoxFit.contain,
                      child: _InfoTitle(
                        element: element!,
                      ),
                    ),
                  ),
                  // Definitely don't add a key to this
                  _InfoDataRow(
                    element: element!,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AtomicBohrModel(
                element,
                key: ValueKey(element!.symbol + "atomic"),
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
                    IconWithText(Icons.library_add, header: "Right Click", text: "to mass compounds").expanded(),
                    IconWithText(Icons.poll, header: "Switch Views", text: "to explore the\n rest of the app").expanded(),
                    IconWithText(Icons.assignment, header: "Click Element", text: "to naviage\n to a detailed description").expanded(),
                    // Column(
                    //   children: [FlutterLogo().expanded()],
                    // )
                  ]).expanded()
                ],
              ),
            ),
            Expanded(
              child: AtomicBohrModel(elementsBloc.getElementBySymbol('pt')),
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
    return Text.rich(TextSpan(children: [
      TextSpan(
          text: "${element.atomicNumber.toString()} – ${element.name}\n",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w200,
          )),
      TextSpan(
        text: element.categoryValue.capitalizeFirstofEach,
        style: TextStyle(
          color: categoryColorMapping[element.category],
          fontSize: 7,
        ),
      )
    ]));
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
          ElementalInfo(
            widget.element,
            intialValue: "Boiling Point",
            intialGetter: (element) => element.getAssociatedStringValue("Boiling Point"),
          ).expanded(),
          ElementalInfo(
            widget.element,
            intialValue: "Melting Point",
            intialGetter: (element) => element.getAssociatedStringValue("Melting Point"),
          ).expanded(),
          ElementalInfo(
            widget.element,
            intialValue: "Phase",
            intialGetter: (element) => element.getAssociatedStringValue("Phase"),
          ).expanded(),
        ],
      ),
    );
  }
}

class ElementalInfo extends StatefulWidget {
  final AtomicData elementData;
  final String Function(AtomicData)? intialGetter;
  final String? intialValue;

  const ElementalInfo(this.elementData, {this.intialGetter, this.intialValue, Key? key}) : super(key: key);

  @override
  _ElementalInfoState createState() => _ElementalInfoState(infoGetter: intialGetter, displayedValue: intialValue);
}

class _ElementalInfoState extends State<ElementalInfo> {
  final ValueNotifier<String> attribute;

  _ElementalInfoState({infoGetter, displayedValue}) : this.attribute = ValueNotifier(displayedValue) {
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
    final screenSize = MediaQuery.of(context).size;

    var dropDown = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElementAttributeSelector(
        attribute: attribute,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        dropDown.fittedBox().expanded(flex: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                widget.elementData.getAssociatedStringValue(attribute.value) == "null" ? "Unknown" : widget.elementData.getAssociatedStringValue(attribute.value),
                style: TextStyle(fontSize: screenSize.width / 80, fontWeight: FontWeight.w200),
              ),
              AtomicUnit(attribute.value, fontSize: screenSize.width / 80)
            ],
          ),
        ).fittedBox(fit: BoxFit.fitWidth).flexible(),
      ],
    );
  }
}

// TODO seperate into own file
// TODO round the corners...
class ElementAttributeSelector extends StatefulWidget {
  const ElementAttributeSelector({
    required this.attribute,
    Key? key,
    this.selectables = kSelectables,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final ValueNotifier<String> attribute;
  final List<String> selectables;

  static const kSelectables = const <String>[
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
      color: widget.backgroundColor,
      child: DropdownButton<String>(
        // underline: Container(),
        value: widget.attribute.value,
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
          widget.attribute.value = value!;

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

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Icon(icon, size: screenSize.width / 20, color: Colors.white70),
        ),
        Expanded(
            child: Text(
          header,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: screenSize.width / 100, fontWeight: FontWeight.bold),
        )),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenSize.width / 100),
          ),
        )
      ],
    );
  }
}
