import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/active_selectors.dart';

import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/info_box.dart';
import 'package:molarity/widgets/molar_mass_box.dart';

enum InteractiveState { noElement, calculationBox, element }

/// This creates an interactive box for a combination of atomic previews and molar mass calculations.
class InteractiveBox extends ConsumerWidget {
  const InteractiveBox({Key? key, this.onCompoundSaved, this.numberOfInfoboxes = 3}) : super(key: key);

  final CompoundDataCallback? onCompoundSaved;
  final int numberOfInfoboxes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // debugPrint("Build InteractiveBox");

    final handle = ref.watch(interactiveBoxHandle);

    switch (handle.state) {
      case InteractiveState.element:
        return InfoBox(element: ref.watch(activeAtomicData).atomicData, numberOfInfoboxes: numberOfInfoboxes);
      case InteractiveState.calculationBox:
        return MolarMassBox(
          compound: handle.compound,
          onSave: onCompoundSaved,
          onClear: () {
            handle.compound.clear();
            handle.state = InteractiveState.element;
          },
          onClose: () {
            handle.state = InteractiveState.element;
          },
        );
      default:
        return InfoBox(
          element: null,
          numberOfInfoboxes: numberOfInfoboxes,
        );
    }
  }
}

class InteractiveBoxHandle extends ChangeNotifier {
  InteractiveBoxHandle() {
    compound.addListener(() => notifyListeners());
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
