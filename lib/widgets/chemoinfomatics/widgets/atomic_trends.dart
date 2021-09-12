import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import '../../../util.dart';
import 'element_property_selector.dart';

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/util.dart';
import 'package:molarity/widgets/info_box.dart';

import '../data.dart';
import '../../../util.dart';

class _AtomicGraphModel {
  final double maxY;
  final List<AtomicData> elements;
  final double? annotationX;

  const _AtomicGraphModel(this.maxY, this.elements, this.annotationX);
}

// TODO fix weird scaling with the control strip. Possibly using a [Wrap]
class AtomicTrends extends ConsumerStatefulWidget {
  final AtomicData? element;
  final int intervalCount;
  final bool displayLabels;
  final ValueNotifier<String>? attribute;

  const AtomicTrends({this.attribute, this.element, this.displayLabels = true, this.intervalCount = 8, Key? key}) : super(key: key);

  @override
  _AtomicTrendsState createState() => _AtomicTrendsState();
}

class _AtomicTrendsState extends ConsumerState<AtomicTrends> {
  final ValueNotifier<String> attribute = ValueNotifier("Density");
  final ValueNotifier<bool> showAll = ValueNotifier(false);

  @override
  void dispose() {
    attribute.dispose();
    showAll.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final elementsBloc = ref.watch(elementsBlocProvider);

    final dropdown = AtomicAttributeSelector(
      onChanged: (val) {
        attribute.value = val!;
      },
      intialValue: "Density",
      selectables: ['Melting Point', 'Boiling Point', 'Density', 'Atomic Mass', 'Molar Heat', 'Electron Negativity'],
    );

    final checkButton = Checkbox(
      value: !showAll.value,
      activeColor: Theme.of(context).scaffoldBackgroundColor,
      onChanged: (val) => setState(
        () {
          showAll.value = !val!;
        },
      ),
    );
    // print("build parent");

    final controlStrip = _generateControlStrip(checkButton, dropdown);
    // final controlStrip = _ControlPanel(
    //   onCheckBoxChanged: (val) {
    //     showAll.value = val;
    //   },
    //   onDropDownChanged: (val) {
    //     attribute.value = val;
    //   },
    // );

    // final graph =

    return Column(
      children: [
        Flexible(child: controlStrip),
        Expanded(
          flex: 5,
          child: ValueListenableBuilder(
            valueListenable: showAll,
            builder: (context, bool showAll, child) {
              return ValueListenableBuilder(
                valueListenable: attribute,
                builder: (BuildContext context, String property, Widget? child) {
                  // print("dataCache.value" + property);
                  return AtomicPropertyGraph(
                    atomicProperty: property,
                    showAll: showAll,
                    element: widget.element,
                    // key: ValueKey("AtomicPropertyGraph" + property),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _generateControlStrip(Checkbox checkButton, Widget dropdown) {
    return Row(
      children: [
        SizedBox(width: 15),
        checkButton.fittedBox(),
        Text(
          "Remove Unknown Values",
          style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
        ).fittedBox(fit: BoxFit.fitHeight),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(child: dropdown).fittedBox(fit: BoxFit.fitHeight),
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
}

// TODO fix weird scaling with the control strip. Possibly using a [Wrap]
// class AtomicTrends extends HookConsumerWidget {
//   final AtomicData? element;
//   final int intervalCount;
//   final bool displayLabels;
//   final ValueNotifier<String>? attribute;

//   const AtomicTrends({this.attribute, this.element, this.displayLabels = true, this.intervalCount = 8, Key? key}) : super(key: key);

//   static const colorMap = {
//     "Boiling Point": Color.fromRGBO(252, 69, 56, 1),
//     "Melting Point": Color.fromRGBO(252, 88, 56, 1),
//     "Density": Color.fromRGBO(88, 56, 252, 1),
//     "Atomic Mass": Color.fromRGBO(72, 252, 56, 1),
//     "Molar Heat": Color.fromRGBO(252, 56, 118, 1),
//     "Electron Negativity": Color.fromRGBO(252, 245, 56, 1),
//   };

//   // @override
//   // void initState() {
//   //   this.attribute = widget.attribute ?? ValueNotifier("Density");
//   //   this.showAll = ValueNotifier(false);

//   //   super.initState();
//   // }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final elementsBloc = ref.watch(elementsBlocProvider);

//     final atomicProperty = attribute ?? useState("Density");
//     final showAll = useState(false);

//     final controlStrip = _ControlPanel(
//       onCheckBoxChanged: (value) => showAll.value = value,
//       onDropDownChanged: (value) => atomicProperty.value = value,
//     );

//     final graph = ValueListenableBuilder(
//       valueListenable: showAll,
//     print(atomicProperty.value);
//       builder: (context, bool showAll, child) {
//         final shouldRemove = !showAll;
//         return ValueListenableBuilder(
//           valueListenable: atomicProperty,
//           builder: (context, String attribute, child) {
//             final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => shouldRemove && (double.tryParse(e.getAssociatedStringValue(attribute)) == null));

//             final yMax = elementsData.map<double>((e) => double.tryParse(e.getAssociatedStringValue(attribute)) ?? 0).reduce((e1, e2) => max(e1, e2));

//             final annotationX = elementsData.indexOf(element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble() + 1;

//             return LineChart(
//               LineChartData(
//                 rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: [
//                   if (element != null) VerticalRangeAnnotation(x1: annotationX, x2: annotationX + .3, color: AtomicTrends.colorMap[attribute]!.withRed(200).desaturate(.05)),
//                 ]),
//                 lineTouchData: _constructLineTouchData(attribute, context, elementsData),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: elementsData.mapIndexed((e, i) => FlSpot(i.toDouble() + 1, double.tryParse(e.getAssociatedStringValue(attribute)) ?? 0)).toList(),
//                     isCurved: false,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(show: true, colors: [AtomicTrends.colorMap[attribute]!.withOpacity(0.4).desaturate(.01)]),
//                     colors: [AtomicTrends.colorMap[attribute]!.desaturate(.01)],
//                     dotData: FlDotData(
//                       show: false,
//                     ),
//                   ),
//                 ],
//                 minY: 0,
//                 minX: 1,
//                 maxX: elementsData.length.toDouble(),
//                 maxY: yMax + yMax / 10,
//                 titlesData: FlTitlesData(
//                   bottomTitles: SideTitles(
//                       showTitles: displayLabels,
//                       reservedSize: 6,
//                       rotateAngle: 70,
//                       interval: 1,
//                       getTextStyles: (i) => TextStyle(fontSize: MediaQuery.of(context).size.width / 200),
//                       getTitles: (value) {
//                         String title;

//                         try {
//                           title = elementsData.elementAt(value.toInt() - 1).name;
//                         } catch (execption) {
//                           title = "Error";
//                         }
//                         return title;
//                       }),
//                   leftTitles: SideTitles(
//                     interval: (yMax / intervalCount).floorToDouble() <= 2 ? 1 : (yMax / intervalCount).floorToDouble(),
//                     showTitles: displayLabels,
//                     getTextStyles: (i) => const TextStyle(fontSize: 8),
//                     getTitles: (value) {
//                       return value.toString();
//                     },
//                   ),
//                 ),
//                 axisTitleData: _generateAxisTitleData(),
//                 gridData: FlGridData(
//                   show: true,
//                   horizontalInterval: (yMax / intervalCount) <= 1 ? 1 : (yMax / intervalCount),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );

//     return Column(
//       children: [
//         Flexible(child: controlStrip),
//         Expanded(flex: 5, child: graph),
//       ],
//     );
//   }

//   FlAxisTitleData _generateAxisTitleData() => FlAxisTitleData(
//         leftTitle: AxisTitle(
//           showTitle: displayLabels,
//           textStyle: const TextStyle(fontSize: 12),
//           titleText: attribute?.value,
//           margin: 5,
//         ),
//         // bottomTitle: AxisTitle(
//         //   showTitle: true,
//         //   margin: 30,
//         //   titleText: 'Element',
//         //   textStyle: const TextStyle(fontSize: 12),
//         //   textAlign: TextAlign.center,
//         // ),
//       );

//   LineTouchData _constructLineTouchData(String attribute, BuildContext context, List<AtomicData> elementsData) {
//     return LineTouchData(
//         enabled: displayLabels,
//         getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
//           return indicators.map((int index) {
//             /// Indicator Line
//             var lineColor = barData.colors[0];
//             if (barData.dotData.show) {
//               lineColor = AtomicTrends.colorMap[attribute]!;
//             }
//             const lineStrokeWidth = 2.0;
//             final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

//             final dotData = FlDotData(
//                 getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
//                       color: AtomicTrends.colorMap[attribute]!,
//                       strokeWidth: 0,
//                     ));

//             return TouchedSpotIndicatorData(flLine, dotData);
//           }).toList();
//         },
//         touchTooltipData: LineTouchTooltipData(
//           tooltipBgColor: Theme.of(context).scaffoldBackgroundColor,
//           getTooltipItems: (touchedSpots) => touchedSpots.map((LineBarSpot touchedSpot) {
//             final textStyle = TextStyle(
//               color: touchedSpot.bar.colors[0],
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             );
//             return LineTooltipItem(
//               touchedSpot.y.toString() + " – " + elementsData[touchedSpot.x.toInt() - 1].name,
//               textStyle,
//             );
//           }).toList(),
//         ));
//   }
// }

class AtomicPropertyGraph extends ConsumerStatefulWidget {
  const AtomicPropertyGraph({
    this.atomicProperty = "Density",
    this.showAll = false,
    this.element,
    this.displayLabels = false,
    this.intervalCount = 8,
    Key? key,
  }) : super(key: key);

  static const Map<String, Color> colorMap = const {
    "Boiling Point": const Color.fromRGBO(252, 69, 56, 1),
    "Melting Point": const Color.fromRGBO(252, 88, 56, 1),
    "Density": const Color.fromRGBO(88, 56, 252, 1),
    "Atomic Mass": const Color.fromRGBO(72, 252, 56, 1),
    "Molar Heat": const Color.fromRGBO(252, 56, 118, 1),
    "Electron Negativity": const Color.fromRGBO(252, 245, 56, 1),
  };

  final String atomicProperty;

  final bool showAll;
  final bool displayLabels;
  final AtomicData? element;
  final int intervalCount;

  @override
  _AtomicPropertyGraphState createState() => _AtomicPropertyGraphState();
}

class _AtomicPropertyGraphState extends ConsumerState<AtomicPropertyGraph> {
  late final ValueNotifier<_AtomicGraphModel> dataCache;
  late Color baseColor;

  @override
  void initState() {
    super.initState();
    print("state");

    dataCache = ValueNotifier(_getData());
    print(widget.atomicProperty);
    baseColor = AtomicPropertyGraph.colorMap[widget.atomicProperty]!;
  }

  // @override
  // void initState() {
  //   // atomicProperty.addListener(() {
  //   //   // didChangeDependencies();
  //   //   setState(() {
  //   //     dataCache.value = _getData();
  //   //   });
  //   // });

  //   // atomicProperty.addListener(() {
  //   //   // didChangeDependencies();
  //   //   setState(() {
  //   //     dataCache.value = _getData();
  //   //   });
  //   // });

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder(
    //   valueListenable: dataCache,
    //   builder: (context, _AtomicGraphModel data, child) {
    // print("data");
    print("build");
    return LineChart(_generateChartDataFromModel(dataCache.value));
    //   },
    // );
  }

  @override
  void didChangeDependencies() {
    // setState(() {

    // });
    baseColor = AtomicPropertyGraph.colorMap[widget.atomicProperty]!;

    print(dataCache.value.maxY);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    dataCache.dispose();

    super.dispose();
  }

  _AtomicGraphModel _getData() {
    final elementsBloc = ref.read(elementsBlocProvider);

    final elementsData = elementsBloc.getElements(ignoreThisValue: (e) => widget.showAll && (double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) == null));

    final yMax = elementsData.map<double>((e) => double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) ?? 0).reduce((e1, e2) => max(e1, e2));

    final double? annotationX;

    if (widget.element != null)
      annotationX = elementsData.indexOf(widget.element ?? elementsBloc.getElementByAtomicNumber(1)).toDouble() + 1;
    else
      annotationX = null;

    print("get data");

    return _AtomicGraphModel(yMax, elementsData, annotationX);
  }

  FlSpot _getSpotData(e, i) => FlSpot(i.toDouble() + 1, double.tryParse(e.getAssociatedStringValue(widget.atomicProperty)) ?? 0);

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
                  touchedSpot.y.toString() + " – " + elementsData[touchedSpot.x.toInt() - 1].name,
                  TextStyle(color: touchedSpot.bar.colors[0], fontWeight: FontWeight.bold, fontSize: 14),
                ))
            .toList(),
      ),
    );
  }

  LineChartData _generateChartDataFromModel(_AtomicGraphModel data) {
    print("generate");
    final yMax = data.maxY;
    final annotationX = data.annotationX;
    final elementsData = data.elements;

    final rangeAnnotations = data.annotationX != null
        ? RangeAnnotations(verticalRangeAnnotations: [
            if (widget.element != null) VerticalRangeAnnotation(x1: annotationX!, x2: annotationX + .3, color: baseColor.withRed(200).desaturate(.05)),
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
          getTitles: (value) => value.toString(),
        ),
      ),
      axisTitleData: FlAxisTitleData(
        leftTitle: AxisTitle(showTitle: widget.displayLabels, textStyle: const TextStyle(fontSize: 12), titleText: widget.atomicProperty, margin: 5),
      ),
      gridData: FlGridData(show: true, horizontalInterval: (yMax / widget.intervalCount) <= 1 ? 1 : (yMax / widget.intervalCount)),
    );
  }
}

class _ControlPanel extends HookWidget {
  const _ControlPanel({Key? key, this.onCheckBoxChanged, this.onDropDownChanged}) : super(key: key);

  final ValueChanged<bool>? onCheckBoxChanged;
  final ValueChanged<String>? onDropDownChanged;

  @override
  Widget build(BuildContext context) {
    final atomicAttribute = useValueNotifier("Melting Point");
    final showAll = useValueNotifier(false);

    print("build");

    final dropdown = AtomicAttributeSelector(
      selectables: ['Melting Point', 'Boiling Point', 'Density', 'Atomic Mass', 'Molar Heat', 'Electron Negativity'],
      onChanged: (val) {
        atomicAttribute.value = val!;

        if (onDropDownChanged != null) onDropDownChanged!(val);
      },
    );

    final checkButton = Checkbox(
      value: !showAll.value,
      activeColor: Theme.of(context).scaffoldBackgroundColor,
      onChanged: (val) {
        if (onCheckBoxChanged != null) onCheckBoxChanged!(val!);
      },
    );

    return Row(
      children: [
        SizedBox(width: 15),
        checkButton.fittedBox(),
        Text(
          "Remove Unknown Values",
          style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white54),
        ).fittedBox(fit: BoxFit.fitHeight),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(child: dropdown).fittedBox(fit: BoxFit.fitHeight),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text("Unit: ").fittedBox(),
        ),
        ValueListenableBuilder(
          valueListenable: atomicAttribute,
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
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  ValueListenableBuilder2(
    this.first,
    this.second, {
    this.child,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}
