import 'package:flutter/material.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicBohrCard extends StatelessWidget {
  const AtomicBohrCard(this.atomicData, {Key? key}) : super(key: key);

  final AtomicData atomicData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TitledCard(
        title: const Text('Bohr Model'),
        child: Hero(
          tag: 'bohrModel',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: GestureDetector(
                      onTap: () => _showModal(context),
                      child: AtomicBohrModel(atomicData),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModal(BuildContext context) {
    final appBarTitle = Padding(
      padding: const EdgeInsets.all(8),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '${atomicData.atomicNumber.toString()} – ${atomicData.name} ', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
          TextSpan(text: atomicData.categoryValue.capitalizeFirstofEach, style: TextStyle(color: categoryColorMapping[atomicData.category], fontWeight: FontWeight.w200, fontSize: 18)),
        ]),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => GestureDetector(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            margin: const EdgeInsets.all(80),
            child: Column(
              children: [
                Align(
                  child: Card(child: appBarTitle),
                  alignment: Alignment.topLeft,
                ),
                AtomicBohrModel(atomicData).expanded(),
              ],
            ),
          ),
          onTap: () => Navigator.pop(context)),
    );
  }
}
