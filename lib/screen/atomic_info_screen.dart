import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/trends_card.dart';

import '../theme.dart';
import '../util.dart';

class AtomicInfoScreen extends StatelessWidget {
  final AtomicData element;

  AtomicInfoScreen(this.element, {Key? key}) : super(key: key);

  final _trendKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final appBarTitle = Text.rich(
      TextSpan(children: [
        TextSpan(text: "${element.atomicNumber.toString()} – ${element.name} ", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
        TextSpan(text: element.categoryValue.capitalizeFirstofEach, style: TextStyle(color: categoryColorMapping[element.category], fontWeight: FontWeight.w200)),
      ]),
    );

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(context, appBarTitle),
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
  final AtomicData element;

  const _AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // width: 200,
      margin: const EdgeInsets.all(15),
      // color: Colors.white.withOpacity(0.1),
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
    );
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
        ));
  }
}

class _AtomicDetails extends StatelessWidget {
  final AtomicData element;

  const _AtomicDetails(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Card(
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
