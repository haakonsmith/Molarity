import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LayoutBoundary extends ConsumerStatefulWidget {
  const LayoutBoundary({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  ConsumerState<LayoutBoundary> createState() => _LayoutBoundaryState();
}

class _LayoutBoundaryState extends ConsumerState<LayoutBoundary> with RouteAware {
  @override
  void didPopNext() {
    if (mounted) setState(() {});

    super.didPopNext();
  }

  @override
  void didPushNext() {
    if (mounted) setState(() {});

    super.didPushNext();
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
    if (!ModalRoute.of(context)!.isCurrent) return const SizedBox();

    return widget.child;
  }
}

final routeObserver = Provider((_) => RouteObserver<ModalRoute>());
