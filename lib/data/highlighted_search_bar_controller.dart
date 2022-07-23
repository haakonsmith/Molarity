import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';

class HighlightedSearchBarController extends ChangeNotifier {
  HighlightedSearchBarController() {
    addListener(() {
      keyBoardFocusNode.requestFocus();
    });
  }

  bool _showSearchBar = false;
  final keyBoardFocusNode = FocusNode();
  final shortcutFocusNode = FocusNode();

  final searchController = TextEditingController();

  bool get showSearchBar => _showSearchBar;
  set showSearchBar(bool val) {
    _showSearchBar = val;
    if (!val) _highlightedElements.clear();

    notifyListeners();
  }

  List<AtomicData> _highlightedElements = [];

  List<AtomicData> get highlightedElements => _highlightedElements;
  set highlightedElements(List<AtomicData> val) {
    _highlightedElements = val;

    notifyListeners();
  }
}

final highlightedSearchBarController = ChangeNotifierProvider((ref) => HighlightedSearchBarController());
