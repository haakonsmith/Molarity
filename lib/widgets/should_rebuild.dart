import 'package:flutter/material.dart';

typedef ShouldRebuildFunction<T> = bool Function(T oldWidget, T newWidget);

class ShouldRebuild<T extends Widget> extends StatefulWidget {
  final T child;
  final ShouldRebuildFunction<T>? shouldRebuild;

  ShouldRebuild({required this.child, this.shouldRebuild})
      : assert(() {
          if (child == null) {
            throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('ShouldRebuild widget: builder must be not  null')]);
          }
          return true;
        }());
  @override
  _ShouldRebuildState createState() => _ShouldRebuildState<T>();
}

class _ShouldRebuildState<T extends Widget> extends State<ShouldRebuild> {
  @override
  ShouldRebuild<Widget> get widget => super.widget;
  Widget? oldWidget;
  @override
  Widget build(BuildContext context) {
    final Widget newWidget = widget.child;
    if (this.oldWidget == null || (widget.shouldRebuild == null ? false : widget.shouldRebuild!(oldWidget!, newWidget))) {
      this.oldWidget = newWidget;
    }
    return oldWidget!;
  }
}
