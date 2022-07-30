import 'package:flutter/material.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/atomic_info_widgets/atomic_bohr_modal.dart';
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
    showDialog(
      context: context,
      builder: (context) => AtomicBohrModal(atomicData),
    );
  }
}
