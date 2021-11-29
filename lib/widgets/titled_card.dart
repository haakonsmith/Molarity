import 'package:flutter/material.dart';
import 'package:molarity/util.dart';

class TitledCard extends StatelessWidget {
  const TitledCard({Key? key, required this.title, required this.child, this.titleAlignment}) : super(key: key);

  final Widget title;
  final Widget child;

  final TextAlign? titleAlignment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              child: title,
              textAlign: TextAlign.left,
            ),
            const Divider(),
            child.expanded(),
          ],
        ),
      ),
    );
  }
}
