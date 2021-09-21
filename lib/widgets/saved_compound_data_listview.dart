import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/preferenced_compounds.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

typedef void IndexCallback(int index);

class SavedCompoundDataListview extends ConsumerStatefulWidget {
  SavedCompoundDataListview({
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

    return Container(
      // color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: (data.length * 36) + (1 * 30) + 26,
      child: Card(
        // margin: const EdgeInsets.all(7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: ListView.separated(itemBuilder: _itemBuilder, separatorBuilder: _separatorBuilder, itemCount: data.length + 1),
        ),
      ),
    );
  }

  Widget _itemBuilder(context, index) {
    if (index == 0) return const _ListHeader();

    return _ListRow(
      molecularFormula: Math.tex(data[index - 1].toTex()),
      molarMass: Math.tex(data[index - 1].molarMass.toStringAsFixed(2)),
      onDelete: () {
        print(index - 1);
        ref.read(preferencedCompoundsProvider).removeSavedCompountAt(index - 1);

        widget.onDelete?.call(index - 1);
      },
      onCopy: () {
        Clipboard.setData(ClipboardData(text: data[index - 1].molarMass.toStringAsFixed(2)));
      },
    );
  }

  Widget _separatorBuilder(context, index) {
    return Divider();
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ListRow(
      molecularFormula: Text(
        "Molecular Formula",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      molarMass: Text(
        "Molar Mass",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      isHeader: true,
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.molecularFormula,
    required this.molarMass,
    this.isHeader = false,
    this.onDelete,
    this.onCopy,
    Key? key,
  }) : super(key: key);

  final bool isHeader;

  final Widget molecularFormula;
  final Widget molarMass;

  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: !isHeader ? 20 : 30,
      child: Row(
        children: [
          SizedBox(
            child: molecularFormula,
            width: width / 2.5,
          ),
          molarMass,
          Spacer(),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              iconSize: 24,
              splashRadius: 20,
              icon: const Icon(Icons.delete),
              padding: const EdgeInsets.all(0),
            ),
          if (!isHeader)
            IconButton(
              onPressed: onCopy,
              iconSize: 24,
              splashRadius: 20,
              icon: const Icon(Icons.copy),
              padding: const EdgeInsets.all(0),
            ),
        ],
      ),
    );
  }
}
