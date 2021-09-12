import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';

import '../theme.dart';
import '../util.dart';

class AtomicInfoScreen extends StatelessWidget {
  final AtomicData element;

  AtomicInfoScreen(this.element, {Key? key}) : super(key: key);

  final _trendKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // print("\nbuild22");
    final appBarTitle = Text.rich(
      TextSpan(children: [
        TextSpan(text: "${element.atomicNumber.toString()} – ${element.name} ", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
        TextSpan(text: element.categoryValue.capitalizeFirstofEach, style: TextStyle(color: categoryColorMapping[element.category], fontWeight: FontWeight.w200)),
      ]),
    );

    return Scaffold(
      appBar: MolarityAppBar.buildTitle(context, appBarTitle, height: MediaQuery.of(context).size.width / 15 >= 60 ? MediaQuery.of(context).size.width / 15 : 60),
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(padding: const EdgeInsets.all(8), child: constraints.maxWidth > 940 ? _buildLargeScreen(context) : _buildSmallScreen(context));
        }),
      ),
    );
  }

  Widget _buildSmallScreen(BuildContext context) {
    // print("Build 33");
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(1, [1.fr]),
      rowSizes: repeat(5, [auto]),
      areas: '''
      preview
      info
      prop
      trend
      spectra
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        AspectRatio(aspectRatio: 2 / 1.5, child: _AtomicInfoPreview(element)).inGridArea('preview'),
        _AtomicDetails(element).inGridArea('info'),
        _AtomicProperties(element).inGridArea('prop'),
        AspectRatio(aspectRatio: 2 / 1.5, child: _TrendsCard(element: element, key: _trendKey)).inGridArea('trend'),
        _AtomicEmissionSpectra(element).inGridArea("spectra"),
      ],
    ));
  }

  Widget _buildLargeScreen(BuildContext context) {
    // print("Build 44");
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(3, [1.fr]),
      rowSizes: repeat(4, [auto]),
      areas: '''
      preview trend trend
      info info info
      prop prop prop
      spectra spectra spectra
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        AspectRatio(aspectRatio: 1 / 1.5, child: _AtomicInfoPreview(element)).inGridArea('preview'),
        AspectRatio(aspectRatio: 2 / 1.5, child: _TrendsCard(element: element, key: _trendKey)).inGridArea('trend'),
        _AtomicDetails(element, key: ValueKey("Atomic Details")).inGridArea('info'),
        // _TrendsCard(element: element, key: _trendKey).inGridArea('trend'),
        _AtomicProperties(element).inGridArea("prop"),
        _AtomicEmissionSpectra(element).inGridArea("spectra"),
      ],
    ));
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({Key? key, required this.element}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    // print("build");
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: Text(
          "Atomic Property Trend",
          // textAlign: TextAlign.center,
        ),
        child: AtomicTrends(element: element),
        // child: TestState(),
      ),
    );
  }
}

class _AtomicInfoPreview extends StatelessWidget {
  final AtomicData element;

  const _AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // width: 200,
      margin: const EdgeInsets.all(12),
      // color: Colors.white.withOpacity(0.1),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
          flex: 6,
          child: FittedBox(fit: BoxFit.contain, child: Container(width: 200, height: 300, child: AtomicBohrModel(element))),
        ),
        // _AtomicAttribute("Atomic Number", element.atomicNumber.toString()).expanded(),
        Expanded(
          flex: 2,
          // fit: FlexFit.tight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: _AtomicAttribute("Atomic Number", element.atomicNumber.toString()),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: _AtomicAttribute("Atomic Mass", element.getAssociatedStringValue('Atomic Mass')),
              ),
            ],
          ).fittedBox(),
        ),
        Expanded(
          flex: 2,
          // fit: FlexFit.tight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: _AtomicAttribute("Electron Configuration", element.semanticElectronConfiguration),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: _AtomicAttribute("Atomic Number", element.atomicNumber.toString()),
              ),
            ],
          ).fittedBox(),
        ),
      ]),
    );
  }
}

class _AtomicEmissionSpectra extends ConsumerWidget {
  const _AtomicEmissionSpectra(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementsBloc = ref.watch(elementsBlocProvider);

    return element.hasSpectralImage
        ? TitledCard(
            title: Text("Emission Spectrum", textAlign: TextAlign.center),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: (elementsBloc.getSpectralImage(element.name) ?? Container()),
            ),
          )
        : Container();
  }
}

class _AtomicAttribute extends StatelessWidget {
  const _AtomicAttribute(this.name, this.value, {Key? key}) : super(key: key);

  final String value;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: SelectableText(name),
          )
        ],
      ),
    );
  }
}

// TODO rename to atomic summary
class _AtomicDetails extends StatelessWidget {
  final AtomicData element;

  const _AtomicDetails(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: SelectableText(
          "General",
          textAlign: TextAlign.center,
        ),
        child: SelectableText(element.summary),
      ),
    );
  }
}

// TODO populate with more properties, this means defining them in the relevant functions defined in the [AtomicData] class
// TODO combine [_AtomicProperties] and [_AtomicDetails] into a tabbed view.
class _AtomicProperties extends StatelessWidget {
  const _AtomicProperties(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: Text("Properties", textAlign: TextAlign.center),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: element.associatedProperties.map((value) => _AtomicAttribute(value, element.getAssociatedStringValue(value))).toList(),
        ),
      ),
    );
  }
}

class TitledCard extends StatelessWidget {
  const TitledCard({Key? key, required this.title, required this.child}) : super(key: key);

  final Widget title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DefaultTextStyle(
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                child: title,
              ),
            ),
            child.expanded()
          ],
        ),
      ),
    );
  }
}
