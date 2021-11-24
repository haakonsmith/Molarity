import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/atomic_info_widgets/atomic_attribute.dart';
import 'package:molarity/widgets/atomic_info_widgets/atomic_image.dart';
import 'package:molarity/widgets/atomic_info_widgets/atomic_properties.dart';
import 'package:molarity/widgets/atomic_info_widgets/bohr_model.dart';
import 'package:molarity/widgets/atomic_info_widgets/trends_card.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
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
        AspectRatio(aspectRatio: 2 / 1.5, child: AtomicInfoPreview(element)).inGridArea('preview'),
        _AtomicDetails(element).inGridArea('info'),
        AtomicProperties(element).inGridArea('prop'),
        AspectRatio(aspectRatio: 2 / 1.5, child: TrendsCard(element: element, key: _trendKey)).inGridArea('trend'),
        _AtomicEmissionSpectra(element).inGridArea('spectra'),
      ],
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(3, [1.fr]),
      rowSizes: repeat(5, [auto]),
      areas: '''
      bohr trend trend
      preview trend trend
      prop prop prop
      info info info
      spectra spectra spectra
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        // AspectRatio(aspectRatio: 1 / 1.5, child: AtomicInfoPreview(element)).inGridArea('preview'),
        AspectRatio(aspectRatio: 2 / 1.5, child: TrendsCard(element: element, key: _trendKey)).inGridArea('trend'),
        _AtomicDetails(element, key: const ValueKey('Atomic Details')).inGridArea('info'),
        AtomicProperties(element).inGridArea('prop'),
        AtomicImage().inGridArea('preview'),
        AtomicBohrCard(atomicData: element).inGridArea('bohr'),
        _AtomicEmissionSpectra(element).inGridArea('spectra'),
      ],
    );
  }
}

class AtomicInfoPreview extends StatelessWidget {
  const AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  final AtomicData element;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
          flex: 6,
          child: FittedBox(fit: BoxFit.contain, child: SizedBox(width: 200, height: 300, child: Hero(tag: 'bohrModel', child: AtomicBohrModel(element)))),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: AtomicAttribute('Atomic Number', element.atomicNumber.toString())),
              Flexible(child: AtomicAttribute('Atomic Mass', element.getAssociatedStringValue('Atomic Mass'))),
            ],
          ).fittedBox(),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: AtomicAttribute('Electron Configuration', element.semanticElectronConfiguration)),
              Flexible(child: AtomicAttribute('Atomic Number', element.atomicNumber.toString())),
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
            title: const Text('Emission Spectrum', textAlign: TextAlign.center),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: (elementsBloc.getSpectralImage(element.name) ?? Container()),
            ),
          )
        : Container();
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
