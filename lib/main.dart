import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';

import 'package:molarity/data/highlighted_search_bar_controller.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/theme.dart';
import 'package:molarity/util.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/chemoinfomatics/widgets/grid_periodic_display.dart';
import 'package:molarity/widgets/highlight_elements_shortcut.dart';

import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:molarity/widgets/layout_boundary.dart';

void main() {
  // timeDilation = 10.0;

  runApp(
    const ProviderScope(
      child: Molarity(),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = const Size(400, 300);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Molarity';
    appWindow.show();
  });
}

const borderColor = Color(0xFF805306);

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
        debugShowCheckedModeBanner: false,
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
            // pageTransitionsTheme: const PageTransitionsTheme(
            //   builders: {TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder()},
            // ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              },
            )),
        navigatorObservers: [ref.read(routeObserver)],
        home: const PeriodicTableScreen(),
      ),
    );
  }
}

const sidebarColor = Color(0xFFF6A00C);

class LeftSide extends StatelessWidget {
  const LeftSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: Container(
            color: sidebarColor,
            child: Column(
              children: [WindowTitleBarBox(child: MoveWindow()), Expanded(child: Container())],
            )));
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [backgroundStartColor, backgroundEndColor], stops: [0.0, 1.0]),
        ),
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          )
        ]),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306), mouseOver: const Color(0xFFF6A00C), mouseDown: const Color(0xFF805306), iconMouseOver: const Color(0xFF805306), iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(mouseOver: const Color(0xFFD32F2F), mouseDown: const Color(0xFFB71C1C), iconNormal: const Color(0xFF805306), iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        if (appWindow.isMaximized)
          TextButton(
            onPressed: maximizeOrRestore,
            child: Text("testttttttttt"),
          )
        else
          TextButton(
            onPressed: maximizeOrRestore,
            child: Text("testttttttttt"),
          ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class TestLandingPage extends ConsumerWidget {
  const TestLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightedElements = ref.watch(highlightedSearchBarController).highlightedElements;

    return Scaffold(
      body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GridPeriodicDisplay(
                tileColor: (AtomicData atomicData) {
                  if (highlightedElements.isEmpty) return categoryColorMapping[atomicData.category]!;
                  return highlightedElements.contains(atomicData) ? categoryColorMapping[atomicData.category]! : categoryColorMapping[atomicData.category]!.darken(0.2).desaturate();
                },
              )
            ],
          )),
    );
  }
}
