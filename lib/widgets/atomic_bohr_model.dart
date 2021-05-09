import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'dart:math' as math;

import '../theme.dart';

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
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..forward();
    _animation = Tween<double>(begin: 0, end: -2 * math.pi).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller.reset();
    _controller.forward();

    return Container(
      child: CustomPaint(
        painter: AtomicModelPainter(
          element: widget.element,
          rotationOffset: _controller.value,
          listenable: _animation,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AtomicModelPainter extends CustomPainter {
  final Animation listenable;
  final List electronConfiguration = [];
  final ElementData element;
  double size = 100;
  double rotationOffset = 0;
  Offset centerOffset = Offset.zero;

  static Map electronColorMapping = {
    "s": Paint()..color = Color(0xFF2196f3),
    "p": Paint()..color = Color(0xFFff9800),
    "d": Paint()..color = Color(0xFF4caf50),
    "f": Paint()..color = Color(0xFFe91e63),
  };

  AtomicModelPainter({required this.listenable, this.rotationOffset = 0, required this.element}) : super(repaint: listenable) {
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

    categoryColorMapping.forEach((key, value) {
      Paint electronPaint = Paint()..color = value;

      electronColorMapping[key] = electronPaint;
    });
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    rotationOffset = listenable.value;
    size = canvasSize.width;

    Paint paint = Paint()..color = categoryColorMapping[element.category]!;

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: element.symbol, style: TextStyle(color: Colors.white, fontSize: size / 9)),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    centerOffset = Offset(canvasSize.width / 2, canvasSize.height / 2);

    canvas.drawCircle(centerOffset, size / 8, paint);
    textPainter.paint(canvas, centerOffset - Offset(textPainter.size.width / 2, textPainter.size.height / 2 + 1));

    _paintRings(canvas);
    _paintElectrons(canvas);
  }

  @override
  bool shouldRepaint(covariant AtomicModelPainter oldDelegate) {
    return (rotationOffset != oldDelegate.rotationOffset);
  }

  void _paintRings(Canvas canvas) {
    Paint ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    Iterable<int>.generate(element.shells.length).forEach((e) {
      ringPaint.color = ringPaint.color.withOpacity(e == element.shells.length - 1 ? 1.0 : 0.3);
      canvas.drawCircle(centerOffset, _calculateRingRadius(e, element.shells.length), ringPaint);
    });
  }

  void _paintElectrons(Canvas canvas) {
    final outerShell = electronConfiguration[electronConfiguration.length - 1];
    final secondOuterShell = electronConfiguration.contains(electronConfiguration.length - 2) ? electronConfiguration[electronConfiguration.length - 2] : {"d": 0, "s": 0, "p": 0, "f": 0};

    final minimumRadius = size / 6.0;
    final maximumRadius = size / 2.0;

    for (var i = 0; i < electronConfiguration.length; i++) {
      final configuration = electronConfiguration[i];
      final totalValenceElectrons = configuration['s'] + configuration['p'] + configuration['d'] + configuration['f'];

      for (var j = 0; j < totalValenceElectrons; j++) {
        final ringRadius = minimumRadius + (i + 1) * (maximumRadius - minimumRadius) / (electronConfiguration.length + 1);
        final phaseShift = i * math.pi / 8.0 + rotationOffset;

        final cx = (math.sin((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);
        final cy = (math.cos((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);

        final opacity = _getOpacity(i, j, configuration, outerShell, secondOuterShell);
        final electronType = _getPaintFromIndex(j, configuration);

        electronType.color = electronType.color.withOpacity(opacity);

        canvas.drawCircle(centerOffset - Offset(cx, cy), 3, electronType);
      }
    }
  }

  double _calculateRingRadius(ringIndex, amountOfRings) {
    final minimumRadius = (size) / 6.0;
    final maximumRadius = (size) / 2.0;

    final radius = minimumRadius + (ringIndex + 1) * (maximumRadius - minimumRadius) / (amountOfRings + 1);

    return radius;
  }

  Paint _getPaintFromIndex(int j, Map configuration) {
    final d = configuration["d"];
    final s = configuration["s"];
    final p = configuration["p"];

    if (j >= s && j >= p + s && j >= d + p + s) return electronColorMapping["f"];
    if (j >= s && j >= p + s) return electronColorMapping["d"];
    if (j >= s) return electronColorMapping["p"];
    return electronColorMapping["s"];
  }

  double _getOpacity(int i, int j, Map configuration, Map outerShell, Map secondOuterShell) {
    if (j >= configuration["p"] + configuration["s"]) {
      if (j >= configuration["d"] + configuration["p"] + configuration['s']) {
        if (secondOuterShell['d']! <= 1 && electronConfiguration.length - i == 3) {
          return 1.0;
        }
      } else {
        if (outerShell['p'] <= 0 && electronConfiguration.length - i == 2) {
          return 1.0;
        }
      }
    }

    if (i == electronConfiguration.length - 1) {
      return 1.0;
    } else {
      return 0.3;
    }
  }
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
