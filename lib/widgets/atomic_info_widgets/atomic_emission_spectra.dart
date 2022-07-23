import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicEmissionSpectra extends ConsumerWidget {
  const AtomicEmissionSpectra(this.element, {Key? key}) : super(key: key);

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
