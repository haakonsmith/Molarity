import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import '../../../util.dart';

// TODO fix weird scaling with the control strip. Possibly using a [Wrap]
class AtomicTrends extends StatefulWidget {
  final AtomicData? element;
  final int intervalCount;
  final bool displayLabels;
  final ValueNotifier<String>? attribute;

  const AtomicTrends({this.attribute, this.element, this.displayLabels = true, this.intervalCount = 8, Key? key}) : super(key: key);

  static const colorMap = {
    "Boiling Point": Color.fromRGBO(252, 69, 56, 1),
    "Melting Point": Color.fromRGBO(252, 88, 56, 1),
    "Density": Color.fromRGBO(88, 56, 252, 1),
    "Atomic Mass": Color.fromRGBO(72, 252, 56, 1),
    "Molar Heat": Color.fromRGBO(252, 56, 118, 1),
    "Electron Negativity": Color.fromRGBO(252, 245, 56, 1),
  };

  @override
  _AtomicTrendsState createState() => _AtomicTrendsState();
}

class _AtomicTrendsState extends State<AtomicTrends> {
  late final ValueNotifier<String> attribute;
  late final ValueNotifier<bool> showAll;

  @override
  void initState() {
    this.attribute = widget.attribute ?? ValueNotifier("Density");
    this.showAll = ValueNotifier(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    final dropdown = ElementAttributeSelector(
      attribute: attribute,
      selectables: ['Melting Point', 'Boiling Point', 'Density', 'Atomic Mass', 'Molar Heat', 'Electron Negativity'],
    );

    final checkButton = Checkbox(
        value: !showAll.value,
        activeColor: Theme.of(context).scaffoldBackgroundColor,
        onChanged: (val) => setState(() {
              showAll.value = !val!;
            }));

    final controlStrip = _generateControlStrip(checkButton, dropdown);

    final graph = ValueListenableBuilder(
      valueListenable: showAll,
      builder: (context, bool showAll, child) {
        final shouldRemove = !showAll;
        return ValueListenableBuilder(
          valueListenable: attribute,
          builder: (context, String attribute, child) {
            final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => shouldRemove && (double.tryParse(e.getAssociatedStringValue(attribute)) == null));

            final yMax = elementsData.map<double>((e) => double.tryParse(e.getAssociatedStringValue(attribute)) ?? 0).reduce((e1, e2) => max(e1, e2));

            final annotationX = elementsData.indexOf(widget.element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble() + 1;

            return LineChart(
              LineChartData(
                rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: [
                  if (widget.element != null) VerticalRangeAnnotation(x1: annotationX, x2: annotationX + .3, color: AtomicTrends.colorMap[attribute]!.withRed(200).desaturate(.05)),
                ]),
                lineTouchData: _constructLineTouchData(attribute, context, elementsData),
                lineBarsData: [
                  LineChartBarData(
                    spots: elementsData.mapIndexed((e, i) => FlSpot(i.toDouble() + 1, double.tryParse(e.getAssociatedStringValue(attribute)) ?? 0)).toList(),
                    isCurved: false,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: true, colors: [AtomicTrends.colorMap[attribute]!.withOpacity(0.4).desaturate(.01)]),
                    colors: [AtomicTrends.colorMap[attribute]!.desaturate(.01)],
                    dotData: FlDotData(
                      show: false,
                    ),
                  ),
                ],
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
                      getTextStyles: (i) => TextStyle(fontSize: MediaQuery.of(context).size.width / 200),
                      getTitles: (value) {
                        String title;

                        try {
                          title = elementsData.elementAt(value.toInt() - 1).name;
                        } catch (execption) {
                          title = "Error";
                        }
                        return title;
                      }),
                  leftTitles: SideTitles(
                    interval: (yMax / widget.intervalCount).floorToDouble() <= 2 ? 1 : (yMax / widget.intervalCount).floorToDouble(),
                    showTitles: widget.displayLabels,
                    getTextStyles: (i) => const TextStyle(fontSize: 8),
                    getTitles: (value) {
                      return value.toString();
                    },
                  ),
                ),
                axisTitleData: FlAxisTitleData(
                  leftTitle: AxisTitle(
                    showTitle: widget.displayLabels,
                    textStyle: const TextStyle(fontSize: 12),
                    titleText: attribute,
                    margin: 5,
                  ),
                  // bottomTitle: AxisTitle(
                  //   showTitle: true,
                  //   margin: 30,
                  //   titleText: 'Element',
                  //   textStyle: const TextStyle(fontSize: 12),
                  //   textAlign: TextAlign.center,
                  // ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (yMax / widget.intervalCount) <= 1 ? 1 : (yMax / widget.intervalCount),
                ),
              ),
            );
          },
        );
      },
    );

    return Column(
      children: [
        Flexible(child: controlStrip),
        Expanded(flex: 5, child: graph),
      ],
    );
  }

  Widget _generateControlStrip(Checkbox checkButton, ElementAttributeSelector dropdown) {
    return Row(
      children: [
        SizedBox(width: 15),
        checkButton.fittedBox(),
        Text(
          "Remove Unknown Values",
          style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
        ).fittedBox(fit: BoxFit.fitHeight).expanded(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(child: dropdown).fittedBox(fit: BoxFit.fitHeight).expanded(),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text("Unit: ").fittedBox(),
        ),
        ValueListenableBuilder(
          valueListenable: attribute,
          builder: (context, String value, child) => Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 5),
            child: AtomicUnit(
              value,
              fontSize: 14,
            ),
          ),
        ).fittedBox()
      ],
    );
  }

  LineTouchData _constructLineTouchData(String attribute, BuildContext context, List<AtomicData> elementsData) {
    return LineTouchData(
        enabled: widget.displayLabels,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
          return indicators.map((int index) {
            /// Indicator Line
            var lineColor = barData.colors[0];
            if (barData.dotData.show) {
              lineColor = AtomicTrends.colorMap[attribute]!;
            }
            const lineStrokeWidth = 2.0;
            final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

            final dotData = FlDotData(
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      color: AtomicTrends.colorMap[attribute]!,
                      strokeWidth: 0,
                    ));

            return TouchedSpotIndicatorData(flLine, dotData);
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Theme.of(context).scaffoldBackgroundColor,
          getTooltipItems: (touchedSpots) => touchedSpots.map((LineBarSpot touchedSpot) {
            final textStyle = TextStyle(
              color: touchedSpot.bar.colors[0],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            );
            return LineTooltipItem(
              touchedSpot.y.toString() + " – " + elementsData[touchedSpot.x.toInt() - 1].name,
              textStyle,
            );
          }).toList(),
        ));
  }
}
