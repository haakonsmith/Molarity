import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:molarity/data/highlighted_search_bar_controller.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/widgets/highlight_elements_shortcut.dart';

import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  // timeDilation = 10.0;

  runApp(
    const ProviderScope(
      child: Molarity(),
    ),
  );
}

// TODO add molar search screen
// TODO add trends screen
// TODO add temperature experimentation screen
// TODO profile memory usage
class Molarity extends ConsumerWidget {
  const Molarity({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HighlightElementsShortcut(
      child: MaterialApp(
        title: 'Molarity',
        // checkerboardOffscreenLayers: true,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: mcgpalette0,
          toggleableActiveColor: mcgpalette0.shade500,
          // cardColor: Colors.white.withOpacity(0.05),
          cardColor: Color.fromARGB(255, 33, 39, 56),
          cardTheme: CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
          scaffoldBackgroundColor: const Color.fromRGBO(26, 31, 44, 1),
          textSelectionTheme: const TextSelectionThemeData(selectionColor: Color.fromARGB(255, 49, 61, 93)),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder()},
          ),
        ),
        home: const PeriodicTableScreen(),
      ),
    );
  }
}
