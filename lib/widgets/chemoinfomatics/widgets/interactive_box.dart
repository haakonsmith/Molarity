import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_atomic_data.dart';

import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/info_box.dart';
import 'package:molarity/widgets/molar_mass_box.dart';

enum InteractiveState { noElement, calculationBox, element }

/// This creates an interactive box for a combination of atomic previews and molar mass calculations.
class InteractiveBox extends ConsumerWidget {
  const InteractiveBox({Key? key, this.onCompoundSaved}) : super(key: key);

  final CompoundDataCallback? onCompoundSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handle = ref.watch(interactiveBoxHandle);

    switch (handle.state) {
      case InteractiveState.element:
        return InfoBox(element: ref.watch(activeAtomicDataNotifier).state);
      case InteractiveState.calculationBox:
        return MolarMassBox(
          compound: handle.compound,
          onSave: onCompoundSaved,
          onClear: () {
            handle.compound.clear();
            handle.state = InteractiveState.noElement;
          },
          onClose: () {
            handle.state = InteractiveState.noElement;
          },
        );
      default:
        return const InfoBox(element: null);
    }
  }
}

class InteractiveBoxHandle extends ChangeNotifier {
  InteractiveBoxHandle() {
    print("Here3");
    compound.addListener(() {
      print("Here");
      notifyListeners();
    });
  }

  CompoundData compound = CompoundData.empty();
  InteractiveState _state = InteractiveState.element;

  set state(InteractiveState other) {
    _state = other;

    notifyListeners();
  }

  InteractiveState get state => _state;
}

final interactiveBoxHandle = ChangeNotifierProvider((ref) => InteractiveBoxHandle());
