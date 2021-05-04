import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;

import 'periodic_table.dart';

class InfoBox extends StatefulWidget {
  ElementData? element;

  InfoBox({this.element, Key? key}) : super(key: key);

  @override
  _InfoBoxState createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  @override
  Widget build(BuildContext context) {
    return widget.element == null ? _buildNullElement(context) : _buildElementInfo(context);
  }

  @override
  Widget _buildElementInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Icon(Icons.library_add),
            Icon(Icons.poll),
            Icon(Icons.assignment),
          ]),
        ),
      ),
    );
    ;
  }

  @override
  Widget _buildNullElement(BuildContext context) {
    final icon_size = MediaQuery.of(context).size.width * 0.05;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // constraints: BoxConstraints.expand(height: 100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: IconWithText(Icons.library_add, size: icon_size, header: "Right Click", text: "to mass compounds")),
              Expanded(child: IconWithText(Icons.poll, size: icon_size, header: "Switch Views", text: "to explore the rest of the app")),
              Expanded(child: IconWithText(Icons.assignment, size: icon_size, header: "Click Element", text: "to naviage to a detailed description")),
              Expanded(child: AtomicBohrModel(ElementsBloc.of(context).getElementBySymbol('pt'))),
            ]),
          ),
        ));
  }
}

class IconWithText extends StatelessWidget {
  double size;
  IconData icon;
  String text;
  String header;

  IconWithText(this.icon, {this.size = 8, this.text = "", this.header = ""});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w300, fontSize: 10),
        child: Column(
          children: [
            Icon(icon, size: size, color: Colors.white70),
            Text(header, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(text, textAlign: TextAlign.center),
          ],
        ));
  }
}

class AtomicBohrModel extends StatefulWidget {
  ElementData element;
  List electronConfiguration;
  double width, height;

  AtomicBohrModel(_element, {this.width = 100, this.height = 100, Key? key})
      : this.electronConfiguration = [],
        this.element = _element,
        super(key: key) {
    final configKeys = element.electronConfiguration.split(" ");

    for (var i = 0; i < element.shells.length; i++) {
      electronConfiguration.add({"s": 0, "p": 0, "d": 0, "f": 0});
    }

    for (var ckey in configKeys) {
      final shell = ckey[0];
      final sublevel = ckey[1];
      final numElectron = ckey[2];

      electronConfiguration[int.parse(shell) - 1][sublevel] += int.parse(numElectron);
    }
  }

  @override
  _AtomicBohrModelState createState() => _AtomicBohrModelState();
}

class _AtomicBohrModelState extends State<AtomicBohrModel> with TickerProviderStateMixin {
  late AnimationController controller;
  late String rawSvg;

  int size = 100;
  double angle = 0;

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();

    controller.addListener(() => setState(() {
          // set all the parameters as needed for the desired affect
          angle = controller.value * 360; // rotate in a complete circle
        }));
    updateSvg(0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: controller,
        child: flutter_svg.SvgPicture.string(
          rawSvg,
        ),
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(alignment: Alignment.center, angle: angle, child: child);
        },
      ),
    );
  }

  void updateSvg(double angle) {
    // print(categoryColorMapping[widget.element.category]!.toHex());
    // update the rawSvg Variable
    rawSvg = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="${size}" height="${size}" version="1.1" viewBox="-${size / 2} -${size / 2} ${size} ${size}">
          <circle cx="0" cy="0" r="20" fill="${categoryColorMapping[widget.element.category]!.toHex()}">
            <g>
            ${_updateRingGroup()}
            </g>
            <text x="0" y="3" class="element-symbol" text-anchor="middle" dominant-baseline="auto" stroke-width="2px" fill="white">${widget.element.symbol}</text>
            <g transform="rotate($angle,0,0)">${_updateElectronGroup(angle)}</g>
        </svg>''';
  }

  String _updateElectronGroup(double angle) {
    // final outerShell = widget.electronConfiguration[widget.electronConfiguration.length - 1];
    // final secondOuterShell = widget.electronConfiguration[widget.electronConfiguration.length - 2];

    final electrons = [];
    final electronBackgrounds = [];

    final minimumRadius = size / 6.0;
    final maximumRadius = size / 2.0;

    for (var i = 0; i < widget.electronConfiguration.length; i++) {
      final configuration = widget.electronConfiguration[i];
      final totalValenceElectrons = configuration['s'] + configuration['p'] + configuration['d'] + configuration['f'];

      for (var j = 0; j < totalValenceElectrons; j++) {
        final ringRadius = minimumRadius + (i + 1) * (maximumRadius - minimumRadius) / (widget.electronConfiguration.length + 1);
        final phaseShift = i * math.pi / 8.0;

        final cx = (math.sin((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);
        final cy = (math.cos((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);

        // final electronType = this._getElectronType(j, configuration);
        // final opacity = this._getOpacity(i, j, configuration, electronConfiguration, outerShell, secondOuterShell);

        final electron = '<circle cx="${cx}" cy="${cy}" r="${size / 50.0}"/>';
        final electronBackground = '<circle cx="${cx}" cy="${cy}" r="${size / 50.0 + size / 75.0}"/>';

        electronBackgrounds.add(electronBackground);
        electrons.add(electron);
      }
    }

    final raw = []..addAll(electronBackgrounds)..addAll(electrons);

    return raw.join("");

    // final configKeys = widget.electronConfiguration;

    // print(configKeys);

    // String result = "";

    // int i = 0;

    // for (var ckey in configKeys) {
    //   final shell = int.parse(ckey[0]);

    //   // print(widget.element.shells[shell - 1]);
    //   print(i);

    //   final computedAngle = angle + (math.pi / widget.element.shells[shell - 1]) * (i);

    //   i += 1;

    //   // print(i);

    //   final cx = math.cos(computedAngle * math.pi) * _calculateRingRadius(shell - 1, widget.element.shells.length);
    //   final cy = math.sin(computedAngle * math.pi) * _calculateRingRadius(shell - 1, widget.element.shells.length);

    //   if (i > widget.element.shells[shell - 1]) {
    //     i = 0;
    //   }
    //   result += '''
    // <circle
    //   cx="${cx}"
    //   cy="$cy"
    //   r="4"
    //   stroke="white"
    //   fill="white"
    // />
    // ''';
    // }
    // return result;
    // return Iterable<int>.generate(widget.element.shells.length)
    //     .map((e) {

    //       // print(e);
    //       ;
    //     })
    //     .toList()
    //     .join("");
  }

  String _updateRingGroup() {
    return Iterable<int>.generate(widget.element.shells.length)
        .map((e) {
          // print(e);
          return '''
    <circle  
      cx="0" 
      cy="0"
      r="${_calculateRingRadius(e, widget.element.shells.length)}"
      stroke="white"
      fill="none"
    />
    ''';
        })
        .toList()
        .join("");
  }

  double _calculateRingRadius(ringIndex, amountOfRings) {
    final minimumRadius = (size) / 6.0;
    final maximumRadius = (size) / 2.0;

    final radius = minimumRadius + (ringIndex + 1) * (maximumRadius - minimumRadius) / (amountOfRings + 1);

    return radius;
  }

  // List<int> _calculateConfiguration(ElementData element) {
  //   element
  // }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
