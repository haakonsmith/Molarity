import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/info_box.dart';

final categoryColorMapping = {
  AtomicElementCategory.actinide: Color.fromRGBO(110, 89, 121, 0.9),
  AtomicElementCategory.alkaliMetal: Color.fromRGBO(120, 80, 90, 0.9),
  AtomicElementCategory.alkalineEarthMetal: Color.fromRGBO(133, 113, 101, 0.9),
  AtomicElementCategory.lanthanide: Color.fromRGBO(120, 107, 151, 0.9),
  AtomicElementCategory.metalloid: Color.fromRGBO(74, 114, 146, 0.9),
  AtomicElementCategory.nobleGas: Color.fromRGBO(136, 100, 170, 0.9),
  AtomicElementCategory.otherNonmetal: Color.fromRGBO(91, 93, 153, 0.9),
  AtomicElementCategory.postTransitionMetal: Color.fromRGBO(74, 134, 119, 0.9),
  AtomicElementCategory.transitionMetal: Color.fromRGBO(99, 113, 138, 0.9),
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

  Widget _buildGrid(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      columnGap: 1,
      rowGap: 1,
      children: [
        InfoBox().withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3),
        for (final e in elementsBloc.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }
}

class PeriodicTableTile extends StatelessWidget {
  final ElementData element;

  const PeriodicTableTile(
    this.element, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var elementTitle = Text(element.symbol.toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18));

    return Container(
        constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
        color: categoryColorMapping[element.category],
        padding: EdgeInsets.all(1),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                element.atomicNumber.toString(),
                style: TextStyle(fontSize: 7),
              ),
              Expanded(child: Center(child: elementTitle)),
              Text(
                element.symbol,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 7),
              )
              // Expanded(child: Center(child: elementTitle)),
            ],
          ),
        ));
  }
}
