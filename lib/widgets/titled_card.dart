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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.darken(0.02),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.headline6!,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: title,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          child.expanded(),
        ],
      ),
    );
  }
}
