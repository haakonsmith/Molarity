/// This whole file is just a bunch of utilites that don't really have a better place to go

// ignore_for_file: unnecessary_this

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension HSLColors on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color saturate([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withSaturation((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color desaturate([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withSaturation((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

extension CapExtension on String {
  String get inCaps => this.isNotEmpty ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => toUpperCase();
  String get capitalizeFirstofEach => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.inCaps).join(' ');
  String get lowerCaseFirstLetter => this.isNotEmpty ? '${this[0].toLowerCase()}${this.substring(1)}' : '';
}

extension StyledWidget on Widget {
  Expanded expanded({int flex = 1}) {
    return Expanded(
      child: this,
      flex: flex,
    );
  }

  FittedBox fittedBox({BoxFit fit = BoxFit.contain}) {
    return FittedBox(
      child: this,
      fit: fit,
    );
  }

  Flexible flexible({int flex = 1}) {
    return Flexible(
      child: this,
      flex: flex,
    );
  }

  SizedBox fixedSize({double? width, double? height}) {
    return SizedBox(child: this, width: width, height: height);
  }

  Widget withTextStyle({TextStyle? style}) {
    return DefaultTextStyle.merge(style: style, child: this);
  }

  Widget withPaddingOnly({
    double left = 0,
    double bottom = 0,
    double top = 0,
    double right = 0,
  }) {
    return Padding(padding: EdgeInsets.only(left: left, right: right, top: top, bottom: bottom), child: this);
  }
}

mixin AsyncSafeData {
  bool _loading = false;

  bool get loading => _loading;

  Future<void> asyncDataUpdate(Future<void> Function() update) async {
    _loading = true;

    await update();

    _loading = false;
  }

  /// Returns the data, if it has been loaded, otherwise returns null
  T? asyncSafeData<T>(T Function() getter) => loading ? null : getter();

  /// Returns the data, if it has been loaded, otherwise returns null
  // Widget asyncLoadingWidget<Widget>(Widget Function() getter) => loading ? (Widget) Container()  : getter();

}
