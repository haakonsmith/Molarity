import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/info_box.dart';

final Map<AtomicElementCategory, Color> categoryColorMapping = {
  AtomicElementCategory.actinide: HSLColor.fromAHSL(0.8, 279, 32 / 100, 25 / 100).toColor(),
  AtomicElementCategory.alkaliMetal: HSLColor.fromAHSL(0.8, 345, 37 / 100, 45 / 100).toColor(),
  AtomicElementCategory.alkalineEarthMetal: HSLColor.fromAHSL(0.8, 23, 27 / 100, 49 / 100).toColor(),
  AtomicElementCategory.lanthanide: Color.fromRGBO(120, 107, 151, 0.9),
  AtomicElementCategory.metalloid: Color.fromRGBO(74, 114, 146, 0.9),
  AtomicElementCategory.nobleGas: Color.fromRGBO(136, 100, 170, 0.9),
  AtomicElementCategory.otherNonmetal: Color.fromRGBO(91, 93, 153, 0.9),
  AtomicElementCategory.postTransitionMetal: Color.fromRGBO(74, 134, 119, 0.9),
  AtomicElementCategory.transitionMetal: HSLColor.fromAHSL(0.8, 218, 18 / 100, 44 / 100).toColor(),
  AtomicElementCategory.unknown: Color(0xffcccccc),
};

class PeriodicTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PeriodicTableState();
}

class _PeriodicTableState extends State<PeriodicTable> {
  @override
  Widget build(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return elementsBloc.loading ? Center(child: Text('Loading...')) : _buildGrid(context);

    // : GridView.count(crossAxisCount: 18, childAspectRatio: 1, mainAxisSpacing: 2, crossAxisSpacing: 2, children: elementsBloc.elementsTable);
  }

  final ValueNotifier<ElementData?> trackedElement = ValueNotifier(null);

  Widget _buildGrid(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      columnGap: 1,
      rowGap: 1,
      children: [
        ValueListenableBuilder<ElementData?>(
            valueListenable: trackedElement,
            builder: (BuildContext context, ElementData? element, Widget? child) {
              return InfoBox(
                element: element,
              ).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
            }),
        for (final e in elementsBloc.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              onHover: (element) {
                trackedElement.value = element;
                print("test");
              },
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }
}

class PeriodicTableTile extends StatelessWidget {
  final ElementData element;
  final Function(ElementData)? onHover;

  const PeriodicTableTile(
    this.element, {
    this.onHover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var elementTitle = Text(element.symbol.toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: constraints.maxWidth / 2.5));

      return InkWell(
        onTap: () {},
        onHover: (value) => onHover!(element),
        child: Container(
          constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
          color: categoryColorMapping[element.category],
          padding: EdgeInsets.all(1),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: Colors.white60.withOpacity(0.8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.atomicNumber.toString(),
                  style: TextStyle(fontSize: constraints.maxWidth / 5),
                ),
                Expanded(child: Center(child: elementTitle)),
                Text(
                  element.symbol,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: constraints.maxWidth / 5),
                )
                // Expanded(child: Center(child: elementTitle)),
              ],
            ),
          ),
        ),
      );
    });
  }
}
