import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ElementsBloc>(create: (_) => ElementsBloc()),
  ], child: Molarity()));
}

class Molarity extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molarity',
      checkerboardOffscreenLayers: true,
      // checkerboardRasterCacheImages: true,
      // themeMode: ThemeMode.dark,
      // darkTheme: ThemeData.from(
      //   colorScheme: ColorScheme.fromSwatch(
      //     primarySwatch: mcgpalette0,
      //     brightness: Brightness.dark,
      //     cardColor: mcgpalette0.shade400,
      //     accentColor: mcgpalette0Accent,
      //     backgroundColor: mcgpalette0.shade800,
      //   ),
      // ),
      // darkTheme: ThemeData(
      //   primarySwatch: mcgpalette0,
      //   brightness: Brightness.dark,
      //   cardColor: mcgpalette0.shade300,

      //   // accentColor: mcgpalette0Accent,
      //   scaffoldBackgroundColor: mcgpalette0.shade800,
      // ),
      theme: ThemeData(
        // This is the theme of your application.
        // colorScheme: ColorScheme.fromSwatch(
        //   primarySwatch: mcgpalette0,
        //   brightness: Brightness.dark,
        //   cardColor: mcgpalette0.shade500,
        //   accentColor: mcgpalette0Accent,
        //   backgroundColor: mcgpalette0.shade100,
        // ),
        brightness: Brightness.dark,
        primarySwatch: mcgpalette0,
        accentColor: mcgpalette0.shade500,
        toggleableActiveColor: mcgpalette0.shade500,
        textSelectionColor: mcgpalette0.shade500,
        // primaryColorDark: mcgpalette0.shade500,
        // cardColor: Color.fromRGBO(26, 31, 44, 1),
        cardColor: Colors.white.withOpacity(0.05),

        // primaryColor: mcgpalette0.shade500
        scaffoldBackgroundColor: Color.fromRGBO(26, 31, 44, 1),
      ),
      home: PeriodicTableScreen(),
    );
  }
}
