import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/preferenced_compounds.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/pubchem_client.dart';

typedef IndexCallback = void Function(int index);

class SavedCompoundDataListview extends ConsumerStatefulWidget {
  const SavedCompoundDataListview({
    Key? key,
    this.onDelete,
  }) : super(key: key);

  final IndexCallback? onDelete;

  @override
  _SavedCompoundDataListviewState createState() => _SavedCompoundDataListviewState();
}

class _SavedCompoundDataListviewState extends ConsumerState<SavedCompoundDataListview> {
  List<CompoundData> data = [];

  @override
  Widget build(BuildContext context) {
    data = ref.watch(preferencedCompoundsProvider).savedCompounds;

    return SizedBox(
      // color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: (data.length * 36) + (1 * 30) + 26,

      child: Card(
        // margin: const EdgeInsets.all(7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: ListView.separated(
            itemBuilder: _itemBuilder,
            separatorBuilder: _separatorBuilder,
            itemCount: data.length + 1,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == 0) return const _ListHeader();

    final pubChemClient = ref.read(pubChemClientProvider);

    return _ListRow(
      name: FutureBuilder(
        future: pubChemClient.getPropertiesOf(data[index - 1], {PubChemProperties.Title}),
        builder: (BuildContext context, AsyncSnapshot<PubChemCompoundData> snapshot) => snapshot.hasData
            ? Text(
                '(${snapshot.data!.title})',
                overflow: TextOverflow.clip,
              )
            : const SizedBox(
                child: Center(
                    child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
                width: 16,
                height: 16,
              ),
      ),
      molecularFormula: Math.tex(data[index - 1].toTex()),
      molarMass: Math.tex(data[index - 1].molarMass.toStringAsFixed(2)),
      onDelete: () {
        ref.read(preferencedCompoundsProvider).removeSavedCompountAt(index - 1);

        widget.onDelete?.call(index - 1);
      },
      onCopy: () {
        Clipboard.setData(ClipboardData(text: data[index - 1].molarMass.toStringAsFixed(2)));
      },
    );
  }

  Widget _separatorBuilder(context, index) {
    return const Divider();
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ListRow(
      molecularFormula: Text(
        'Molecular Formula',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      molarMass: Text(
        'Molar Mass',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      isHeader: true,
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.molecularFormula,
    required this.molarMass,
    this.name,
    this.isHeader = false,
    this.onDelete,
    this.onCopy,
    Key? key,
  }) : super(key: key);

  final bool isHeader;

  final Widget? name;

  final Widget molecularFormula;
  final Widget molarMass;

  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: !isHeader ? 20 : 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Row(
            children: [
              molecularFormula,
              const SizedBox(width: 10),
              if (name != null) Expanded(child: name!),
            ],
          )),
          Expanded(
              child: Row(
            children: [
              molarMass,
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  iconSize: 24,
                  splashRadius: 20,
                  icon: const Icon(Icons.delete),
                  padding: EdgeInsets.zero,
                ),
              if (!isHeader)
                IconButton(
                  onPressed: onCopy,
                  iconSize: 24,
                  splashRadius: 20,
                  icon: const Icon(Icons.copy),
                  padding: EdgeInsets.zero,
                ),
            ],
          )),
          // if (isHeader)
          //   SizedBox(
          //     width: 48,
          //   )
        ],
      ),
    );
  }
}
