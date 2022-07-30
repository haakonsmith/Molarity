import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/highlighted_search_bar_controller.dart';
import 'package:molarity/data/settings_bloc.dart';

class HighlightElementsShortcut extends ConsumerWidget {
  const HighlightElementsShortcut({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(settingsBlocProvider).enableKeyboardShortcuts) return child;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): () {
          ref.read(highlightedSearchBarController).showSearchBar = !ref.read(highlightedSearchBarController).showSearchBar;
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(highlightedSearchBarController).showSearchBar = false;
        },
      },
      // This gives the shortcut focus when pages are switched.
      child: Focus(
        child: child,
        autofocus: true,
        focusNode: ref.watch(highlightedSearchBarController).shortcutFocusNode,
      ),
    );
  }
}
