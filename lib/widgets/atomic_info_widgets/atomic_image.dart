import 'package:flutter/material.dart';
import 'package:molarity/widgets/titled_card.dart';

class AtomicImage extends StatelessWidget {
  const AtomicImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: TitledCard(
        title: Text('Photos'),
        child: FittedBox(
          child: FlutterLogo(
            size: 20,
          ),
        ),
      ),
    );
  }
}
