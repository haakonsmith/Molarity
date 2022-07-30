import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:molarity/widgets/atomic_info_widgets/image_modal.dart';
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicImage extends StatelessWidget {
  const AtomicImage(this.atomicData, {Key? key}) : super(key: key);

  final AtomicData atomicData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TitledCard(
        title: const Text('Photo'),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
          child: Center(
            child: FutureBuilder<String>(
              future: _findImage(),
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return GestureDetector(
                    child: Image.asset(snapshot.data!, scale: 0.7),
                    onTap: () => _showModal(context, snapshot.data!), // Dart should have partial functions, bite me
                  );
                if (snapshot.hasError)
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No Image Found.'),
                  );
                return const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _findImage() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('physical_photos/'))
        .where((String key) => key.toLowerCase().contains(atomicData.name.toLowerCase())) //
        .toList();

    return imagePaths.first;
  }

  void _showModal(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(child: Image.asset(imagePath), onTap: () => Navigator.pop(context)),
    );
  }
}
