import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import '../../../util.dart';

class AtomicTrends extends StatefulWidget {
  final AtomicData? element;

  const AtomicTrends({this.element, Key? key}) : super(key: key);

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
  late final ValueNotifier<AtomicAttributeDataWrapper> attribute;
  late final ValueNotifier<bool> showAll;

  @override
  void initState() {
    this.attribute = ValueNotifier(AtomicAttributeDataWrapper("Density", (e) => e.density));
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
          builder: (context, AtomicAttributeDataWrapper attribute, child) {
            final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => shouldRemove && (double.tryParse(attribute.infoGetter!(e)) == null));

            final yMax = elementsData.map<double>((e) => double.tryParse(attribute.infoGetter!(e)) ?? 0).reduce((e1, e2) => max(e1, e2));

            final annotationX = elementsData.indexOf(widget.element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble() + 1;

            return LineChart(
              LineChartData(
                rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: [
                  if (widget.element != null) VerticalRangeAnnotation(x1: annotationX, x2: annotationX + .3, color: AtomicTrends.colorMap[attribute.value]!.withRed(200)),
                ]),
                lineTouchData: _constructLineTouchData(attribute, context, elementsData),
                lineBarsData: [
                  LineChartBarData(
                    spots: elementsData.mapIndexed((e, i) => FlSpot(i.toDouble() + 1, double.tryParse(attribute.infoGetter!(e)) ?? 0)).toList(),
                    isCurved: false,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: true, colors: [AtomicTrends.colorMap[attribute.value]!.withOpacity(0.4)]),
                    colors: [AtomicTrends.colorMap[attribute.value]!],
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
                      showTitles: true,
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
                    interval: (yMax / 8).floorToDouble() <= 2 ? 1 : (yMax / 8).floorToDouble(),
                    showTitles: true,
                    getTextStyles: (i) => const TextStyle(fontSize: 8),
                    getTitles: (value) {
                      return value.toString();
                    },
                  ),
                ),
                axisTitleData: FlAxisTitleData(
                  leftTitle: AxisTitle(
                    showTitle: true,
                    textStyle: const TextStyle(fontSize: 12),
                    titleText: attribute.value,
                    margin: 10,
                  ),
                  bottomTitle: AxisTitle(
                    showTitle: true,
                    margin: 30,
                    titleText: 'Element',
                    textStyle: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (yMax / 8) <= 1 ? 1 : (yMax / 8),
                ),
              ),
            );
          },
        );
      },
    );

    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          controlStrip,
          Expanded(flex: 10, child: graph),
        ]),
      ),
    );
  }

  SizedBox _generateControlStrip(Checkbox checkButton, ElementAttributeSelector dropdown) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          checkButton,
          Text(
            "Remove Unknown Values",
            style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
          ),
          Center(child: dropdown),
          Spacer(),
          Text("Unit: "),
          ValueListenableBuilder(
            valueListenable: attribute,
            builder: (context, AtomicAttributeDataWrapper value, child) => Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: AtomicUnit(
                value.value!,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }

  LineTouchData _constructLineTouchData(AtomicAttributeDataWrapper attribute, BuildContext context, List<AtomicData> elementsData) {
    return LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
          return indicators.map((int index) {
            /// Indicator Line
            var lineColor = barData.colors[0];
            if (barData.dotData.show) {
              lineColor = AtomicTrends.colorMap[attribute.value]!;
            }
            const lineStrokeWidth = 2.0;
            final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

            final dotData = FlDotData(
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      color: AtomicTrends.colorMap[attribute.value]!,
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
