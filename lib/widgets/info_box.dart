import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/data/settings_bloc.dart';

import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/element_property_selector.dart';

class InfoBox extends HookConsumerWidget {
  const InfoBox({this.element, Key? key}) : super(key: key);

  final AtomicData? element;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return element == null ? _buildNullElement(context, ref) : _buildElementInfo(context, ref);
  }

  Widget _buildElementInfo(BuildContext context, WidgetRef ref) {
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
              child: Hero(
                tag: 'bohrModel',
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AtomicBohrModel(
                    element!,
                    key: ValueKey('${element!.symbol}atomic'),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildNullElement(BuildContext context, WidgetRef ref) {
    final elementsBloc = ref.watch(elementsBlocProvider);
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
                    const IconWithText(Icons.library_add, header: 'Right Click', text: 'to mass compounds').expanded(),
                    const IconWithText(Icons.poll, header: 'Switch Views', text: 'to explore the\n rest of the app').expanded(),
                    const IconWithText(Icons.assignment, header: 'Click Element', text: 'to naviage\n to a detailed description').expanded(),
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
          text: '${element.atomicNumber.toString()} – ${element.name}\n',
          style: const TextStyle(
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

class _InfoDataRow extends ConsumerStatefulWidget {
  const _InfoDataRow({Key? key, required this.element}) : super(key: key);

  final AtomicData element;

  @override
  _InfoDataRowState createState() => _InfoDataRowState();
}

class _InfoDataRowState extends ConsumerState<_InfoDataRow> {
  @override
  Widget build(BuildContext context) {
    final settingsBloc = ref.watch(settingsBlocProvider);

    return Expanded(
      flex: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: settingsBloc.loading
            ? [const Center(child: CircularProgressIndicator())]
            : [
                ElementalInfo(
                  widget.element,
                  intialValue: settingsBloc.shouldPersistAtomicPreviewCategories ? settingsBloc.savedAtomicPropertyCategories[0] : AtomicProperty.boilingPoint,
                  onChanged: (property) {
                    if (settingsBloc.shouldPersistAtomicPreviewCategories) settingsBloc.setSavedAtomicPropertyCategory(0, property);
                  },
                ).expanded(),
                ElementalInfo(
                  widget.element,
                  intialValue: settingsBloc.shouldPersistAtomicPreviewCategories ? settingsBloc.savedAtomicPropertyCategories[1] : AtomicProperty.meltingPoint,
                  onChanged: (property) {
                    if (settingsBloc.shouldPersistAtomicPreviewCategories) settingsBloc.setSavedAtomicPropertyCategory(1, property);
                  },
                ).expanded(),
                ElementalInfo(
                  widget.element,
                  intialValue: settingsBloc.shouldPersistAtomicPreviewCategories ? settingsBloc.savedAtomicPropertyCategories[2] : AtomicProperty.phase,
                  onChanged: (property) {
                    if (settingsBloc.shouldPersistAtomicPreviewCategories) settingsBloc.setSavedAtomicPropertyCategory(2, property);
                  },
                ).expanded(),
              ],
      ),
    );
  }
}

class ElementalInfo extends ConsumerStatefulWidget {
  const ElementalInfo(this.elementData, {this.onChanged, this.intialValue, Key? key}) : super(key: key);

  final AtomicData elementData;
  final AtomicProperty? intialValue;
  final void Function(AtomicProperty)? onChanged;

  @override
  _ElementalInfoState createState() => _ElementalInfoState();
}

class _ElementalInfoState extends ConsumerState<ElementalInfo> {
  late AtomicProperty atomicProperty;

  @override
  void initState() {
    atomicProperty = widget.intialValue ?? AtomicProperty.density;

    print("Init state:!" + atomicProperty.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final dropDown = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AtomicAttributeSelector(
          intialValue: AtomicData.getPropertyStringName(atomicProperty),
          onChanged: (val) {
            setState(() => atomicProperty = atomicPropertyFromString(val!));
            widget.onChanged?.call(atomicPropertyFromString(val!));
          }),
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
                widget.elementData.getAssociatedStringValue(AtomicData.getPropertyStringName(atomicProperty)) == 'null'
                    ? 'Unknown'
                    : widget.elementData.getAssociatedStringValue(AtomicData.getPropertyStringName(atomicProperty)),
                style: TextStyle(fontSize: screenSize.width / 80, fontWeight: FontWeight.w200),
              ),
              AtomicUnit(AtomicData.getPropertyStringName(atomicProperty), fontSize: screenSize.width / 80)
            ],
          ),
        ).fittedBox(fit: BoxFit.fitWidth).flexible(),
      ],
    );
  }
}

class IconWithText extends StatelessWidget {
  const IconWithText(this.icon, {this.text = '', this.header = '', Key? key}) : super(key: key);

  final IconData icon;
  final String text;
  final String header;

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
