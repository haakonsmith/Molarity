import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_property_selector.dart';

class _AtomicGraphModel {
  const _AtomicGraphModel(this.maxY, this.elements, this.annotationX);

  final double maxY;
  final List<AtomicData> elements;
  final double? annotationX;
}

// TODO fix weird scaling with the control strip. Possibly using a [Wrap]
class AtomicTrends extends ConsumerStatefulWidget {
  const AtomicTrends({
    this.onAtomicPropertyChanged,
    this.element,
    this.initialProperty,
    this.displayLabels = true,
    this.displayGrid = true,
    this.intervalCount = 8,
    Key? key,
  }) : super(key: key);

  final AtomicData? element;
  final int intervalCount;
  final bool displayLabels;
  final bool displayGrid;
  final AtomicProperty? initialProperty;
  final ValueChanged<String>? onAtomicPropertyChanged;

  @override
  _AtomicTrendsState createState() => _AtomicTrendsState();
}

class _AtomicTrendsState extends ConsumerState<AtomicTrends> {
  late AtomicProperty property;
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    property = widget.initialProperty ?? ref.read(activeSelectorsProvider).atomicProperty;

    final controlStrip = _ControlPanel(
      initialProperty: property,
      onCheckBoxChanged: (val) {
        setState(() => showAll = val);
      },
      onDropDownChanged: (val) {
        if (widget.onAtomicPropertyChanged != null) widget.onAtomicPropertyChanged!(val);

        ref.read(activeSelectorsProvider).atomicProperty = atomicPropertyFromString(val);
        setState(() {
          property = atomicPropertyFromString(val);
        });
      },
    );

    return Column(
      children: [
        Flexible(child: controlStrip),
        Expanded(
          flex: 5,
          child: AtomicPropertyGraph(
            atomicProperty: AtomicData.getPropertyStringName(property),
            showAll: showAll,
            element: widget.element,
            displayGrid: widget.displayGrid,
            displayLabels: widget.displayLabels,
          ),
        ),
      ],
    );
  }
}

class AtomicPropertyGraph extends ConsumerStatefulWidget {
  const AtomicPropertyGraph({
    this.atomicProperty = 'Density',
    this.showAll = false,
    this.element,
    this.displayLabels = false,
    this.displayGrid = true,
    this.intervalCount = 8,
    Key? key,
  }) : super(key: key);

  static const Map<String, Color> colorMap = {
    'Boiling Point': Color.fromRGBO(252, 69, 56, 1),
    'Melting Point': Color.fromRGBO(252, 88, 56, 1),
    'Density': Color.fromRGBO(88, 56, 252, 1),
    'Atomic Mass': Color.fromRGBO(72, 252, 56, 1),
    'Molar Heat': Color.fromRGBO(252, 56, 118, 1),
    'Electron Negativity': Color.fromRGBO(252, 245, 56, 1),
  };

  final String atomicProperty;

  final bool showAll;
  final bool displayLabels;
  final bool displayGrid;
  final AtomicData? element;
  final int intervalCount;

  @override
  _AtomicPropertyGraphState createState() => _AtomicPropertyGraphState();
}

class _AtomicPropertyGraphState extends ConsumerState<AtomicPropertyGraph> {
  late final ValueNotifier<_AtomicGraphModel> dataCache;
  late Color baseColor;
  late LineChartData lineChartData = _generateChartDataFromModel(_getData());

  @override
  void initState() {
    super.initState();

    dataCache = ValueNotifier(_getData());
    baseColor = AtomicPropertyGraph.colorMap[widget.atomicProperty]!;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      lineChartData,
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant AtomicPropertyGraph oldWidget) {
    if (oldWidget.atomicProperty != widget.atomicProperty || oldWidget.element != widget.element || oldWidget.showAll != widget.showAll || oldWidget.displayLabels != widget.displayLabels) {
      dataCache.value = _getData();
      baseColor = AtomicPropertyGraph.colorMap[widget.atomicProperty]!;
      lineChartData = _generateChartDataFromModel(dataCache.value);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    dataCache.dispose();

    super.dispose();
  }

  _AtomicGraphModel _getData() {
    final elementsBloc = ref.read(elementsBlocProvider);

    final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => !widget.showAll && (double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) == null));

    final yMax = elementsData.map<double>((e) => double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) ?? 0).reduce((e1, e2) => max(e1, e2));

    final double? annotationX;

    if (widget.element != null)
      annotationX = elementsData.indexOf(widget.element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble() + 1;
    else
      annotationX = null;

    return _AtomicGraphModel(yMax, elementsData, annotationX);
  }

  FlSpot _getSpotData(AtomicData e, int i) => FlSpot(i.toDouble() + 1, double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) ?? 0);

  List<TouchedSpotIndicatorData> _getSpotIndicators(
    LineChartBarData barData,
    List<int> indicators,
  ) =>
      indicators.map(
        (int index) {
          /// Indicator Line
          var lineColor = barData.colors[0];
          if (barData.dotData.show) {
            lineColor = baseColor;
          }
          const lineStrokeWidth = 2.0;
          final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

          final dotData = FlDotData(
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              color: baseColor,
              strokeWidth: 0,
            ),
          );

          return TouchedSpotIndicatorData(flLine, dotData);
        },
      ).toList();

  LineTouchData _getLineTouchData(String attribute, BuildContext context, List<AtomicData> elementsData) {
    return LineTouchData(
      enabled: widget.displayLabels,
      getTouchedSpotIndicator: _getSpotIndicators,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).scaffoldBackgroundColor,
        getTooltipItems: (touchedSpots) => touchedSpots
            .map((LineBarSpot touchedSpot) => LineTooltipItem(
                  '${touchedSpot.y} – ${elementsData[touchedSpot.x.toInt() - 1].name}',
                  TextStyle(color: touchedSpot.bar.colors[0], fontWeight: FontWeight.bold, fontSize: 14),
                ))
            .toList(),
      ),
    );
  }

  LineChartData _generateChartDataFromModel(_AtomicGraphModel data) {
    final yMax = data.maxY;
    final annotationX = data.annotationX;
    final elementsData = data.elements;

    final borderSide = BorderSide(style: BorderStyle.solid, color: Colors.blueGrey.withAlpha(100));

    final ignoreThisValue = !widget.showAll && (double.tryParse(widget.element?.getAssociatedStringValue(widget.atomicProperty) ?? "") == null);

    final rangeAnnotations = data.annotationX != null && !ignoreThisValue
        ? RangeAnnotations(verticalRangeAnnotations: [
            if (widget.element != null) VerticalRangeAnnotation(x1: annotationX! - .15, x2: annotationX + .15, color: baseColor.withRed(200).desaturate(.05)),
          ])
        : null;

    final lineBarsData = [
      LineChartBarData(
        spots: elementsData.mapIndexed(_getSpotData).toList(),
        isCurved: false,
        barWidth: 2,
        belowBarData: BarAreaData(show: true, colors: [baseColor.withOpacity(0.4).desaturate(.01)]),
        colors: [baseColor.desaturate(.01)],
        dotData: FlDotData(show: false),
      ),
    ];

    return LineChartData(
      rangeAnnotations: rangeAnnotations,
      lineTouchData: _getLineTouchData(widget.atomicProperty, context, elementsData),
      lineBarsData: lineBarsData,
      borderData: FlBorderData(show: true, border: Border(left: borderSide, bottom: borderSide)),
      minY: 0,
      minX: 1,
      maxX: elementsData.length.toDouble(),
      maxY: yMax + yMax / 10,
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
            showTitles: widget.displayLabels,
            reservedSize: 6,
            rotateAngle: 70,
            interval: 1,
            getTextStyles: (_, __) => TextStyle(fontSize: MediaQuery.of(context).size.width / 200),
            getTitles: (value) {
              String title;

              try {
                title = elementsData.elementAt(value.toInt() - 1).name;
              } catch (execption) {
                title = 'Error';
              }
              return title;
            }),
        leftTitles: SideTitles(
          interval: (yMax / widget.intervalCount).floorToDouble() <= 2 ? 1 : (yMax / widget.intervalCount).floorToDouble(),
          showTitles: widget.displayLabels,
          getTextStyles: (_, __) => const TextStyle(fontSize: 8),
          getTitles: (value) => value.toString(),
        ),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      axisTitleData: FlAxisTitleData(
        leftTitle: AxisTitle(showTitle: widget.displayLabels, textStyle: const TextStyle(fontSize: 12), titleText: widget.atomicProperty, margin: 5),
      ),
      gridData: FlGridData(show: widget.displayGrid, horizontalInterval: (yMax / widget.intervalCount) <= 1 ? 1 : (yMax / widget.intervalCount)),
    );
  }
}

class _ControlPanel extends HookWidget {
  const _ControlPanel({
    Key? key,
    this.onCheckBoxChanged,
    this.onDropDownChanged,
    this.initialProperty,
  }) : super(key: key);

  final AtomicProperty? initialProperty;
  final ValueChanged<bool>? onCheckBoxChanged;
  final ValueChanged<String>? onDropDownChanged;

  @override
  Widget build(BuildContext context) {
    final atomicAttribute = useValueNotifier('Melting Point');
    final shouldRemove = useValueNotifier(true);

    atomicAttribute.value = AtomicData.getPropertyStringName(initialProperty ?? AtomicProperty.density);

    final windowSize = MediaQuery.of(context).size;
    final shouldDisplayUnit = windowSize.width <= 530;

    final dropdown = AtomicPropertySelector(
      selectables: const ['Melting Point', 'Boiling Point', 'Density', 'Atomic Mass', 'Molar Heat', 'Electron Negativity'],
      initialValue: atomicAttribute.value,
      onChanged: (val) {
        atomicAttribute.value = val!;

        if (onDropDownChanged != null) onDropDownChanged!(val);
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!shouldDisplayUnit) const SizedBox(width: 15),
        ValueListenableBuilder(
          valueListenable: shouldRemove,
          builder: (BuildContext context, bool value, Widget? child) {
            return Checkbox(
              value: value,
              activeColor: Theme.of(context).scaffoldBackgroundColor,
              onChanged: (val) {
                shouldRemove.value = val!;

                onCheckBoxChanged?.call(!val);
              },
            ).fittedBox();
          },
        ),
        const Text(
          'Remove Unknown Values',
          style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
        ).fittedBox(fit: BoxFit.fitWidth),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(child: dropdown).fittedBox(fit: BoxFit.fitHeight),
        ),
        const Spacer(),
        if (!shouldDisplayUnit)
          const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: FittedBox(child: Text('Unit: ')),
          ),
        if (!shouldDisplayUnit)
          ValueListenableBuilder(
            valueListenable: atomicAttribute,
            builder: (context, String value, child) => Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: AtomicUnit(value, fontSize: 14),
            ),
          ).fittedBox()
      ],
    );
  }
}
