import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/info_box.dart';

import '../theme.dart';

class AtomicInfoScreen extends StatelessWidget {
  final ElementData element;

  AtomicInfoScreen(this.element, {Key? key}) : super(key: key);

  final _trendKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (Platform.isMacOS) SizedBox(height: 10),
          Text(
            "${element.atomicNumber.toString()} – ${element.name}",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
          Text(
            element.categoryValue.capitalizeFirstofEach,
            textAlign: TextAlign.left,
            style: TextStyle(color: categoryColorMapping[element.category], fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
    var preferredSize = PreferredSize(
      preferredSize: Size.fromHeight(90.0),
      child: Container(
        color: Theme.of(context).bottomAppBarColor,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: SafeArea(child: appBar),
      ),
    );
    return Scaffold(
      appBar: Platform.isMacOS ? preferredSize : appBar,
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(padding: const EdgeInsets.all(8), child: constraints.maxWidth > 940 ? _buildLargeScreen(context) : _buildSmallScreen(context));
        }),
      ),
    );
  }

  Widget _buildSmallScreen(BuildContext context) {
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(1, [1.fr]),
      rowSizes: repeat(3, [auto]),
      areas: '''
      preview
      info
      trend
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        AspectRatio(aspectRatio: 2 / 1.5, child: _AtomicInfoPreview(element)).inGridArea('preview'),
        _AtomicDetails(element).inGridArea('info'),
        AspectRatio(aspectRatio: 2 / 1.5, child: AtomicTrends(element: element, key: _trendKey)).inGridArea('trend'),
      ],
    ));
  }

  Widget _buildLargeScreen(BuildContext context) {
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(3, [1.fr]),
      rowSizes: repeat(2, [auto]),
      areas: '''
      preview trend trend
      info info info
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        AspectRatio(aspectRatio: 1 / 1.5, child: _AtomicInfoPreview(element)).inGridArea('preview'),
        // _AtomicInfoPreview(element).inGridArea('trend'),
        _AtomicDetails(element).inGridArea('info'),
        AtomicTrends(element: element, key: _trendKey).inGridArea('trend'),
      ],
    ));
  }
}

class _AtomicInfoPreview extends StatelessWidget {
  final ElementData element;

  const _AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 200,
          color: Colors.white.withOpacity(0.1),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              flex: 6,
              child: FittedBox(fit: BoxFit.contain, child: Container(width: 200, height: 300, child: AtomicBohrModel(element))),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _buildAttribute(context, "Atomic Number", element.atomicNumber.toString()),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _buildAttribute(context, "Atomic Mass", element.atomicMass),
                ),
              ]),
            ),
            Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: _buildAttribute(context, "Electron Configuration", element.semanticElectronConfiguration),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: _buildAttribute(context, "Atomic Number", element.atomicNumber.toString()),
                    ),
                  ],
                )),
          ]),
        ));
  }

  Widget _buildAttribute(BuildContext context, String name, String value) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Text(name),
          )
        ],
      ),
    );
  }
}

class _AtomicDetails extends StatelessWidget {
  final ElementData element;

  const _AtomicDetails(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            color: Colors.white.withOpacity(0.1),
            child: _buildGeneralDescription(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              width: double.infinity,
              child: Text(
                "General",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              )),
          SelectableText(element.summary),
        ],
      ),
    );
  }
}

class AtomicTrends extends StatefulWidget {
  final ElementData? element;

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
  late final ValueNotifier<ElementalAttributeDataWrapper> attribute;
  late final ValueNotifier<bool> showAll;

  @override
  void initState() {
    this.attribute = ValueNotifier(ElementalAttributeDataWrapper("Density", (e) => e.density));
    this.showAll = ValueNotifier(false);

    print("STOPPPPP");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final elementsBloc = ElementsBloc.of(context, listen: true);

    final dropdown = ElementAttributeSelector(
      attribute: attribute,
      selectables: ['Melting Point', 'Boiling Point', 'Density', 'Atomic Mass', 'Molar Heat', 'Electron Negativity'],
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );

    final checkButton = Checkbox(
        value: !showAll.value,
        activeColor: Theme.of(context).scaffoldBackgroundColor,
        onChanged: (val) => setState(() {
              showAll.value = !val!;
            }));

    final controlStrip = SizedBox(
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
              builder: (context, ElementalAttributeDataWrapper value, child) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: AtomicUnit(
                    value.value!,
                    fontSize: 14,
                  )))
        ],
      ),
    );

    final graph = ValueListenableBuilder(
      valueListenable: showAll,
      builder: (context, bool showAll, child) {
        final shouldRemove = !showAll;
        return ValueListenableBuilder(
            valueListenable: attribute,
            builder: (context, ElementalAttributeDataWrapper attribute, child) {
              final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => shouldRemove && (double.tryParse(attribute.infoGetter!(e)) == null));

              final yMax = elementsData.map<double>((e) => double.tryParse(attribute.infoGetter!(e)) ?? 0).reduce((e1, e2) => max(e1, e2));

              final annotationX = elementsData.indexOf(widget.element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble();

              return LineChart(
                LineChartData(
                  rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: [
                    if (widget.element != null) VerticalRangeAnnotation(x1: annotationX, x2: annotationX + .3, color: AtomicTrends.colorMap[attribute.value]!.withRed(200)),
                  ]),
                  lineTouchData: LineTouchData(
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

                          var dotSize = 10.0;
                          if (barData.dotData.show) {
                            dotSize = 4.0 * 1.8;
                          }

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
                      )),
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
                          // print(value);
                          String title;

                          // print(elementsData);

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
                        return '${value}';
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
                    horizontalInterval: (yMax / 8).floorToDouble() <= 2 ? 1 : (yMax / 8).floorToDouble(),
                  ),
                ),
                // swapAnimationDuration: const Duration(milliseconds: 500),
                // swapAnimationCurve: Curves.easeInExpo,
              );
            });
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white.withOpacity(0.1),
        child: Column(children: [
          controlStrip,
          Expanded(flex: 10, child: graph),
        ]),
      ),
    );
  }
}

class AtomicUnitMap {}

// class TrendSelector extends StatefulWidget {
//   TrendSelector({Key? key}) : super(key: key);

//   @override
//   _TrendSelectorState createState() => _TrendSelectorState();
// }

// class _TrendSelectorState extends State<TrendSelector> {
//   String selectorValue = 'Density';

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       child: DropdownButton<String>(
//         // underline: Container(),
//         value: selectorValue,
//         items: <String>[
//           'Melting Point',
//           'Boiling Point',
//           'Phase',
//           'Density',
//           'Atomic Mass',
//           'Molar Heat',
//           'Electron Negativity',
//           // 'First Ionisation Energy',
//           'Electron Configuration',
//         ].map((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
//             ),
//           );
//         }).toList(),
//         onChanged: (value) {
//           String Function(ElementData) infoGetter = (_) => "Oh no";
//           switch (value) {
//             case "Melting Point":
//               infoGetter = (ElementData element) => element.meltingPointValue;
//               break;
//             case "Boiling Point":
//               infoGetter = (element) => element.boilingPointValue;
//               break;
//             case "Phase":
//               infoGetter = (element) => element.phase;
//               break;
//             case "Density":
//               infoGetter = (element) => element.density;
//               break;
//             case "Atomic Mass":
//               infoGetter = (element) => element.atomicMass;
//               break;
//             case "Molar Heat":
//               infoGetter = (element) => element.molarHeat;
//               break;
//             case "Electron Negativity":
//               infoGetter = (element) => element.electronNegativity;
//               break;
//             // case "First Ionisation Energy":
//             //   infoGetter = (element) => element.ionisationEnergies.isEmpty ? "Uknown" : widget.element.ionisationEnergies[0].toString();
//             //   break;
//             case "Electron Configuration":
//               infoGetter = (element) => element.semanticElectronConfiguration;
//               break;
//           }

//           widget.attribute.value = _ElementalAttributeDataWrapper(value, infoGetter);

//           setState(() {});
//         },
//       ),
//     );
//   }
// }
