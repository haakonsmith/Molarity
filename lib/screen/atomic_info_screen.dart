import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/widgets/atomic_bohr_model.dart';

import '../theme.dart';

class AtomicInfoScreen extends StatelessWidget {
  final ElementData element;

  const AtomicInfoScreen(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                "${element.atomicNumber.toString()} – ${element.name}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                element.categoryValue.capitalizeFirstofEach,
                textAlign: TextAlign.left,
                style: TextStyle(color: categoryColorMapping[element.category], fontWeight: FontWeight.w200),
              ),
            ])),
        body: LayoutBuilder(builder: (context, constraints) {
          return Padding(padding: const EdgeInsets.all(8), child: _buildLargeScreen(context));
        }));
  }

  Widget _buildSmallScreen(BuildContext context) {
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(18, [1.fr]),
      rowSizes: repeat(10, [auto]),
      areas: '''
      header header header
      
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [],
    ));
  }

  Widget _buildLargeScreen(BuildContext context) {
    return Container(
        child: LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: repeat(3, [1.fr]),
      rowSizes: repeat(2, [1.fr]),
      areas: '''
      preview trend trend
      info info info
      ''',
      columnGap: 1,
      rowGap: 1,
      children: [
        _AtomicInfoPreview(element).inGridArea('preview'),
        _AtomicInfoPreview(element).inGridArea('trend'),
        _AtomicDetails(element).inGridArea('info'),
      ],
    ));
  }
}

class _AtomicInfoPreview extends StatelessWidget {
  final ElementData element;

  const _AtomicInfoPreview(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          color: Colors.white.withOpacity(0.1),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              flex: 7,
              child: Container(width: 200, height: 300, child: AtomicBohrModel(element)),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildAttribute(context, "Atomic Number", element.atomicNumber.toString()),
              _buildAttribute(context, "Atomic Mass", element.atomicMass),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildAttribute(context, "Electron Configuration", element.semanticElectronConfiguration),
              _buildAttribute(context, "Atomic Number", element.atomicNumber.toString()),
            ]),
          ]),
        ));
  }

  Widget _buildAttribute(BuildContext context, String name, String value) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w200),
          ),
          Text(name),
        ]));
  }
}

class _AtomicDetails extends StatelessWidget {
  final ElementData element;

  const _AtomicDetails(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black.withOpacity(0.4),
          child: _buildGeneralDescription(context),
        ),
      ],
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
          Text(element.summary),
        ],
      ),
    );
  }
}

// class _AtomicInfoHeader extends StatelessWidget {
//   final ElementData element;

//   const _AtomicInfoHeader(this.element, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 3 / 1,
//       child: Row(children: [
//         Column(
//           children: [Text(element.name)],
//         ),
//       ]),
//     );
//   }
// }
