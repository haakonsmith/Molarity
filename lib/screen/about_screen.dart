import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/list_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ListDrawer(),
      appBar: const MolarityAppBar(
        title: Text('About'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width, 600),
          child: Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<String>(
              future: rootBundle.loadString("assets/about.md"),
              builder: (context, snapshot) {
                if (snapshot.hasData) return Markdown(data: snapshot.data!);
                if (snapshot.hasError) return const Text("Something went really wrong!");
                return const Center(child: CircularProgressIndicator());
              },
            ),
          )),
        ),
      ),
    );
  }
}
