import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:molarity/theme.dart';

import 'package:molarity/widgets/chemoinfomatics/data.dart';

/// This is the atomic bohr model spinning thing
class AtomicBohrModel extends StatefulWidget {
  const AtomicBohrModel(this.element, {this.width = 100, this.height = 100, Key? key}) : super(key: key);

  final AtomicData element;
  final double width, height;

  @override
  _AtomicBohrModelState createState() => _AtomicBohrModelState();
}

class _AtomicBohrModelState extends State<AtomicBohrModel> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..forward();
    _animation = Tween<double>(begin: 0, end: -2 * math.pi).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        margin: const EdgeInsets.all(20),
        width: widget.width,
        height: widget.height,
        child: RepaintBoundary(
          child: CustomPaint(
            size: const Size(100, 100),
            painter: AtomicBohrModelPainter(
              element: widget.element,
              listenable: _animation,
            ),
          ),
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

/// This is the painter for the
// TODO(haakonsmith): make sure all the electrons are being coloured correct,
class AtomicBohrModelPainter extends CustomPainter {
  AtomicBohrModelPainter({
    this.rotationOffset = 0,
    required this.listenable,
    required this.element,
  }) : super(repaint: listenable) {
    final List<String> configKeys = element.electronConfiguration.split(' ');

    for (int i = 0; i < element.shells.length; i++) {
      electronConfiguration.add({'s': 0, 'p': 0, 'd': 0, 'f': 0});
    }

    for (final String ckey in configKeys) {
      final String shell = ckey[0];
      final String sublevel = ckey[1];
      final int numElectron = int.parse(ckey[2]);

      electronConfiguration[int.parse(shell) - 1].update(sublevel, (int value) => value + numElectron);
    }
  }

  final Animation<double> listenable;
  final List<Map<String, int>> electronConfiguration = [];
  final AtomicData element;

  final double canvasSize = 100;
  double rotationOffset = 0;
  Offset centerOffset = Offset.zero;

  static Map<String, Paint> electronColorMapping = {
    's': Paint()..color = const Color(0xFF2196f3),
    'p': Paint()..color = const Color(0xFFff9800),
    'd': Paint()..color = const Color(0xFF4caf50),
    'f': Paint()..color = const Color(0xFFe91e63),
  };

  @override
  void paint(Canvas canvas, Size size) {
    rotationOffset = listenable.value;
    final Paint paint = Paint()..color = categoryColorMapping[element.category]!;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: element.symbol, style: TextStyle(color: Colors.white, fontSize: canvasSize / 9)),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    centerOffset = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(centerOffset, canvasSize / 8, paint);
    textPainter.paint(canvas, centerOffset - Offset(textPainter.size.width / 2, textPainter.size.height / 2 + 1));

    _paintRings(canvas);
    _paintElectrons(canvas);
  }

  @override
  bool shouldRepaint(covariant AtomicBohrModelPainter oldDelegate) {
    return rotationOffset != oldDelegate.rotationOffset;
  }

  void _paintRings(Canvas canvas) {
    final Paint ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    for (final int e in Iterable<int>.generate(element.shells.length)) {
      ringPaint.color = ringPaint.color.withOpacity(e == element.shells.length - 1 ? 1.0 : 0.3);
      canvas.drawCircle(centerOffset, _calculateRingRadius(e, element.shells.length), ringPaint);
    }
  }

  void _paintElectrons(Canvas canvas) {
    final Map<String, int> outerShell = electronConfiguration[electronConfiguration.length - 1];
    final Map<String, int> secondOuterShell =
        electronConfiguration.contains(electronConfiguration.length - 2) ? electronConfiguration[electronConfiguration.length - 2] : {'d': 0, 's': 0, 'p': 0, 'f': 0};

    final double minimumRadius = canvasSize / 6.0;
    final double maximumRadius = canvasSize / 2.0;

    for (int i = 0; i < electronConfiguration.length; i++) {
      final Map<String, int> configuration = electronConfiguration[i];
      final int totalValenceElectrons = configuration['s']! + configuration['p']! + configuration['d']! + configuration['f']!;

      for (int j = 0; j < totalValenceElectrons; j++) {
        final double ringRadius = minimumRadius + (i + 1) * (maximumRadius - minimumRadius) / (electronConfiguration.length + 1);
        final double phaseShift = i * math.pi / 8.0 + rotationOffset;

        final double cx = (math.sin((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);
        final double cy = (math.cos((2 * math.pi) * (j / totalValenceElectrons) + phaseShift) * ringRadius);

        final double opacity = _getOpacity(i, j, configuration, outerShell, secondOuterShell);
        final Paint electronType = _getPaintFromIndex(j, configuration);

        electronType.color = electronType.color.withOpacity(opacity);

        canvas.drawCircle(centerOffset - Offset(cx, cy), 300 / canvasSize, electronType);
      }
    }
  }

  double _calculateRingRadius(int ringIndex, int amountOfRings) {
    final double minimumRadius = canvasSize / 6.0;
    final double maximumRadius = canvasSize / 2.0;

    final double radius = minimumRadius + (ringIndex + 1) * (maximumRadius - minimumRadius) / (amountOfRings + 1);

    return radius;
  }

  Paint _getPaintFromIndex(int j, Map<String, int> configuration) {
    final int d = configuration['d']!;
    final int s = configuration['s']!;
    final int p = configuration['p']!;

    if (j >= s && j >= p + s && j >= d + p + s) return electronColorMapping['f']!;
    if (j >= s && j >= p + s) return electronColorMapping['d']!;
    if (j >= s) return electronColorMapping['p']!;
    return electronColorMapping['s']!;
  }

  double _getOpacity(int i, int j, Map<String, int> configuration, Map<String, int> outerShell, Map<String, int> secondOuterShell) {
    if (j >= configuration['p']! + configuration['s']!) {
      if (j >= configuration['d']! + configuration['p']! + configuration['s']!) {
        if (secondOuterShell['d']! <= 1 && electronConfiguration.length - i == 3) {
          return 1.0;
        }
      } else {
        if (outerShell['p']! <= 0 && electronConfiguration.length - i == 2) {
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
