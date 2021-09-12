import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
import 'package:molarity/theme.dart';

void main() {
  runApp(
    ProviderScope(
      child: Molarity(),
    ),
  );
}

// TODO add molar search screen
// TODO add trends screen
// TODO add temperature experimentation screen
// TODO profile memory usage
class Molarity extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molarity',
      checkerboardOffscreenLayers: true,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: mcgpalette0,
        toggleableActiveColor: mcgpalette0.shade500,
        cardColor: Colors.white.withOpacity(0.05),

        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),

        // primaryColor: mcgpalette0.shade500
        scaffoldBackgroundColor: const Color.fromRGBO(26, 31, 44, 1),
      ),
      home: PeriodicTableScreen(),
    );
  }
}
