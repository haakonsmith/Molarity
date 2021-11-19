import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_trends.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicInfoScreen extends StatelessWidget {
  AtomicInfoScreen(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  final _trendKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final appBarTitle = Text.rich(
      TextSpan(children: [
        TextSpan(text: '${element.atomicNumber.toString()} – ${element.name} ', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
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
    final screenSize = MediaQuery.of(context).size;

    return LayoutGrid(
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
        _AtomicEmissionSpectra(element).inGridArea('spectra'),
      ],
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    return LayoutGrid(
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
        _AtomicDetails(element, key: const ValueKey('Atomic Details')).inGridArea('info'),
        // _TrendsCard(element: element, key: _trendKey).inGridArea('trend'),
        _AtomicProperties(element).inGridArea('prop'),
        _AtomicEmissionSpectra(element).inGridArea('spectra'),
      ],
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({Key? key, required this.element}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const Text('Atomic Property Trend'),
        child: AtomicTrends(element: element, displayLabels: MediaQuery.of(context).size.width >= 530),
      ),
    );
  }
}

class _AtomicInfoPreview extends StatelessWidget {
  const _AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 7,
            child: Hero(
              tag: 'bohrModel',
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AtomicBohrModel(element),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _AtomicAttribute('Atomic Number', element.atomicNumber.toString()),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _AtomicAttribute('Atomic Mass', element.getAssociatedStringValue('Atomic Mass')),
                ),
              ],
            ).fittedBox(),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _AtomicAttribute('Electron Configuration', element.semanticElectronConfiguration),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: _AtomicAttribute('Atomic Number', element.atomicNumber.toString()),
                ),
              ],
            ).fittedBox(),
          ),
          const Spacer()
        ],
      ),
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
            title: const Text('Emission Spectrum', textAlign: TextAlign.center),
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
          SelectableText(
            name,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

// TODO rename to atomic summary
class _AtomicDetails extends StatelessWidget {
  const _AtomicDetails(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const SelectableText(
          'General',
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
        title: const Text('Properties', textAlign: TextAlign.center),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: element.associatedProperties.map((value) => _AtomicAttribute(value, element.getAssociatedStringValue(value))).toList(),
        ),
      ),
    );
  }
}
