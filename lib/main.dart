import 'package:flutter/material.dart';
import 'package:molarity/BLoC/elements_data_bloc.dart';
import 'package:molarity/screen/periodic_table_screen.dart';
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
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
        // brightness: Brightness.dark,
        scaffoldBackgroundColor: Color.fromRGBO(26, 31, 44, 1),
      ),
      home: PeriodicTableScreen(),
    );
  }
}
