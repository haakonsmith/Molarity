import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LayoutBoundary extends ConsumerStatefulWidget {
  const LayoutBoundary({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  ConsumerState<LayoutBoundary> createState() => _LayoutBoundaryState();
}

class _LayoutBoundaryState extends ConsumerState<LayoutBoundary> with RouteAware {
  final _key = GlobalKey();
  bool _isVisible = true;

  @override
  void didPopNext() {
    if (mounted)
      setState(() {
        _isVisible = true;
      });

    super.didPopNext();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(routeObserver).subscribe(this, ModalRoute.of(context)!);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox();

    return VisibilityDetector(
      key: _key,
      child: widget.child,
      onVisibilityChanged: (info) {
        setState(() {
          _isVisible = info.visibleFraction > 0;
        });
      },
    );
  }
}

final routeObserver = Provider((_) => RouteObserver<ModalRoute>());
