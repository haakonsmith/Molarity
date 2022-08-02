import 'package:flutter/material.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/atomic_bohr_model.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicBohrModal extends StatelessWidget {
  const AtomicBohrModal(this.atomicData, {Key? key}) : super(key: key);

  final AtomicData atomicData;

  @override
  Widget build(BuildContext context) {
    final appBarTitle = Align(
      alignment: Alignment.topLeft,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '${atomicData.atomicNumber.toString()} – ${atomicData.name} ', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
              TextSpan(text: atomicData.categoryValue.capitalizeFirstofEach, style: TextStyle(color: categoryColorMapping[atomicData.category], fontWeight: FontWeight.w200, fontSize: 18)),
            ]),
          ),
        ),
      ),
    );

    final legend = Align(
      alignment: Alignment.topLeft,
      child: TitledCard(
        title: const Text('Electron Subgroup Legend'),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            // children: AtomicBohrModelPainter.electronColorMapping.entries.map(_buildLegendItem).toList().cast().,
            itemBuilder: (context, index) => _buildLegendItem(context, AtomicBohrModelPainter.electronColorMapping.entries.elementAt(index)),
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
        ),
      ),
    );
    return GestureDetector(
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              appBarTitle,
              AtomicBohrModel(atomicData).fixedSize(height: MediaQuery.of(context).size.height * 0.6), // 0.67
              legend.fixedSize(height: 180),
            ],
          ),
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildLegendItem(BuildContext context, MapEntry<String, Paint> item) {
    final colorLabel = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: item.value.color,
        border: Border.all(color: Theme.of(context).cardColor.darken(0.02)),
      ),
    );

    return Row(
      children: [const SizedBox(width: 20), colorLabel, const SizedBox(width: 10), Text('Subgroup: ${item.key}')],
    );
  }
}
