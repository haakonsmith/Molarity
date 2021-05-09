import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/widgets/info_box.dart';

import '../theme.dart';

class PeriodicTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PeriodicTableState();
}

class _PeriodicTableState extends State<PeriodicTable> {
  @override
  Widget build(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    return elementsBloc.loading ? Center(child: Text('Loading...')) : _buildGrid(context);
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
              return AspectRatio(
                  aspectRatio: 40.1 / 12.4,
                  child: InfoBox(
                    element: element,
                  )).withGridPlacement(columnSpan: 10, rowStart: 0, columnStart: 2, rowSpan: 3);
            }),
        for (final e in elementsBloc.elements)
          AspectRatio(
            aspectRatio: 40.1 / 42.4,
            child: PeriodicTableTile(
              e,
              onHover: (element) {
                trackedElement.value = element;
              },
              key: ValueKey(e.symbol),
            ),
          ).withGridPlacement(columnStart: e.x, rowStart: e.y),
      ],
    );
  }
}

class PeriodicTableTile extends StatefulWidget {
  final ElementData element;
  final Function(ElementData)? onHover;

  const PeriodicTableTile(
    this.element, {
    this.onHover,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeriodicTableTileState();
}

class _PeriodicTableTileState extends State<PeriodicTableTile> {
  Color tileColor = Colors.white;

  @override
  void initState() {
    super.initState();

    tileColor = categoryColorMapping[widget.element.category]!;
  }

  @override
  Widget build(BuildContext context) {
    var elementTitle = Text(
      widget.element.symbol.toString(),
      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
      textScaleFactor: 1.5,
    );

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AtomicInfoScreen(widget.element))),
      onHover: (value) => widget.onHover!(widget.element),
      child: Container(
        constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
        color: tileColor,
        padding: EdgeInsets.all(1),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.white60.withOpacity(0.8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(
                    widget.element.atomicNumber.toString(),
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
                    textScaleFactor: 0.7,
                    // style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: elementTitle,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(
                    widget.element.symbol,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
                  ),
                ),
              ),
              // Expanded(child: Center(child: elementTitle)),
            ],
          ),
        ),
      ),
    );
  }
}
