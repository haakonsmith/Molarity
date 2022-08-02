import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/helix_display.dart';

class GridPeriodicDisplay extends ConsumerWidget {
  const GridPeriodicDisplay({this.tileColor, Key? key}) : super(key: key);

  final Color Function(AtomicData atomicData)? tileColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = max(35.0 * 18.0, MediaQuery.of(context).size.width);
    final size = Size(width, width * 10 / 18);
    print(width);

    return SizedBox.fromSize(
      size: size,
      // constraints: BoxConstraints.tight(Size.square(width)),
      // ,
      child: FutureBuilder<void>(
        future: ref.read(elementsBlocProvider).elementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("!!here");
            return GestureDetector(
              onTapDown: (details) {
                // _detectTap(details, size);
                final atomicIndex = _transformTapToIndex(details, size);
                final atomicDatum = ref.read(elementsBlocProvider).elements.firstWhere((element) => element.x == atomicIndex.dx || element.y == atomicIndex.dy + 1);

                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AtomicInfoScreen(atomicDatum)));
              },
              child: CustomPaint(
                painter: _GridPeriodicPainter(
                  atomicData: ref.read(elementsBlocProvider).elements,
                  tileColor: tileColor,
                ),
                size: Size.square(width),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
    // return
  }

  Offset _transformTapToIndex(TapDownDetails details, Size size) {
    return Offset(
      (details.globalPosition.dx / size.width * 18).floorToDouble(),
      (details.localPosition.dy / size.height * 10).floorToDouble(),
    );
  }
}

class _GridPeriodicPainter extends CustomPainter {
  const _GridPeriodicPainter({this.tileColor, required this.atomicData});

  final Color Function(AtomicData atomicData)? tileColor;

  final double gap = 5;
  static Paint painter = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  static int columnsCount = 18;
  static int rowCount = 10;
  final List<AtomicData> atomicData;

  @override
  void paint(Canvas canvas, Size size) {
    final double cardDimension = size.width / 18;
    // blocs.asMap().forEach((index, bloc) {
    //   setColor(bloc);
    // });
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textScaleFactor: cardDimension / 70);
    textPainter.text = TextSpan(text: "Hh", style: const TextStyle(color: Colors.white, fontSize: 24));

    textPainter.layout();

    for (final datum in atomicData) {
      print("!!here");

      final tileOffset = Offset(datum.x * 1.0, datum.y * 1.0) * cardDimension;

      painter.color = tileColor!.call(datum);

      // final style = const TextStyle();

      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                tileOffset.dx,
                tileOffset.dy,
                cardDimension - gap,
                cardDimension - gap,
              ),
              const Radius.circular(8.0)),
          painter);

      // textPainter.text = TextSpan(text: datum.atomicNumber.toString(), style: const TextStyle(color: Colors.white));

      // textPainter.layout(minWidth: 0, maxWidth: 200);
      // textPainter.paint(canvas, tileOffset.translate(3, 1));

      textPainter.text = TextSpan(text: datum.symbol.length == 2 ? datum.symbol : "Hh", style: const TextStyle(color: Colors.white, fontSize: 24));

      // textPainter.layout();
      textPainter.paint(canvas, tileOffset.translate(0.5 * cardDimension - textPainter.width / 2 - gap / 2, 0.5 * cardDimension - textPainter.height / 2 - gap / 2));
    }
  }

  // double getTop(int index) {
  //   return (index / crossAxisCount).floor().toDouble() * blocSize;
  // }

  // double getLeft(int index) {
  //   return (index % crossAxisCount).floor().toDouble() * blocSize;
  // }

  @override
  bool shouldRepaint(_GridPeriodicPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(_GridPeriodicPainter oldDelegate) => true;

  // void setColor(BlockTypes bloc) {
  //   switch (bloc) {
  //     case BlockTypes.red:
  //       painter.color = Colors.red;
  //       break;
  //     case BlockTypes.gray:
  //       painter.color = Colors.grey;
  //       break;
  //     case BlockTypes.green:
  //       painter.color = Colors.green;
  //       break;
  //     case BlockTypes.yellow:
  //       painter.color = Colors.yellow;
  //       break;
  //   }
  // }
}
