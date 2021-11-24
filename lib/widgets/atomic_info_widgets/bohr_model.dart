import 'package:flutter/material.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicBohrCard extends StatelessWidget {
  const AtomicBohrCard({Key? key, required this.atomicData}) : super(key: key);

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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: AtomicBohrModel(atomicData)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
