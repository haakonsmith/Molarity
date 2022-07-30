import 'package:flutter/material.dart';

class ImageModal extends StatelessWidget {
  const ImageModal(this.imagePath, {Key? key}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16))),
        child: Image.asset(imagePath),
      ),
    );
  }
}
