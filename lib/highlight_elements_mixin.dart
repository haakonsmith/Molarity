import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

mixin HighlightElementsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _showSearch = false;

  bool get showSearch => _showSearch;

  final keyBoardFocusNode = FocusNode();
  final shortcutFocusNode = FocusNode();

  bool shouldRequestFocusOnBuild = true;

  List<AtomicData> highlightedElements = [];

  late final Map<Type, Action<Intent>> actionMap;
  final Map<ShortcutActivator, Intent> shortcutMap = const {
    SingleActivator(LogicalKeyboardKey.keyP, meta: true): ActivateIntent(),
  };

  final searchController = TextEditingController();

  @override
  void initState() {
    intialiseActions();

    super.initState();
  }

  void intialiseActions() {
    actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (Intent intent) => setState(toggleSearch),
      ),
    };

    keyBoardFocusNode.onKeyEvent = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(toggleSearch);
      }

      return KeyEventResult.ignored;
    };
  }

  void reFocus() {
    if (shouldRequestFocusOnBuild) shortcutFocusNode.requestFocus();
    shouldRequestFocusOnBuild = false;
  }

  // @override
  // @mustCallSuper
  // Widget build(BuildContext context) {
  //   reFocus();

  //   return super.build(context);
  // }

  void toggleSearch() {
    _showSearch = !_showSearch;
    if (_showSearch) {
      keyBoardFocusNode.requestFocus();
    } else {
      highlightedElements.clear();
      searchController.clear();
      shouldRequestFocusOnBuild = true;
    }
  }

  void closeSearch(_) {
    highlightedElements.clear();
    searchController.clear();
    shouldRequestFocusOnBuild = true;
    setState(() => _showSearch = false);
  }

  void highlightElements(String value) => setState(() => highlightedElements = ref.read(elementsBlocProvider).elements.where((element) => element.symbol.toLowerCase().contains(value)).toList());

  @override
  void dispose() {
    searchController.dispose();
    keyBoardFocusNode.dispose();
    shortcutFocusNode.dispose();

    super.dispose();
  }
}
