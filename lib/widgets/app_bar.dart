import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:molarity/util.dart';
import 'package:universal_platform/universal_platform.dart';

// ignore: avoid_classes_with_only_static_members
class MolarityAppBar {
  static PreferredSizeWidget buildTitle(BuildContext context, Widget? title, {double? height}) {
    final appBar = AppbarWithTab(
      title: title!,
    );

    final preferredSize = PreferredSize(
      preferredSize: Size.fromHeight(height ?? computePrefferedSize(context)),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: appBar,
      ),
    );

    return UniversalPlatform.isMacOS ? preferredSize : appBar;
  }

  static double computePrefferedSize(BuildContext context) {
    // final double height = (MediaQuery.of(context).size.width / 25) >= 60 ? MediaQuery.of(context).size.width / 25 : 60;
    final double height = (MediaQuery.of(context).size.width / 20);

    // if (!UniversalPlatform.isDesktop) height = 30;

    return max(75, height);
    // return (MediaQuery.of(context).size.width / 25).clamp(50, 70);
  }
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight) : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

/// This is an [Appbar] replacement that displays the an extra tab and creates
/// a gap between the large appbar and the tab displayed.
///
/// Half of the options don't work...
class AppbarWithTab extends StatefulWidget implements PreferredSizeWidget {
  AppbarWithTab({
    Key? key,
    this.tabVisible = true,
    this.tabShape,
    this.tabRadius = 20,
    required this.title,
    this.onPressed,
    this.leading,
    this.onTitleTapped,
    this.elevation = 10,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.onBackButtonPressed,
    this.toolbarHeight,
  })  : preferredSize = _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height),
        kTabShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(tabRadius),
            bottomRight: Radius.circular(tabRadius),
          ),
        ),
        kAppbarShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(tabRadius),
            bottomLeft: Radius.circular(tabRadius),
          ),
        ),
        super(key: key);

  final bool tabVisible;

  final double tabRadius;

  final ShapeBorder? tabShape;

  final Widget title;
  final Widget? leading;
  final VoidCallback? onPressed;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onTitleTapped;
  final double elevation;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final TextStyle titleTextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white);

  /// {@template flutter.material.appbar.bottom}
  /// This widget appears across the bottom of the app bar.
  ///
  /// Typically a [TabBar]. Only widgets that implement [PreferredSizeWidget] can
  /// be used at the bottom of an app bar.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [PreferredSize], which can be used to give an arbitrary widget a preferred size.
  final PreferredSizeWidget? bottom;

  /// {@template flutter.material.appbar.toolbarHeight}
  /// Defines the height of the toolbar component of an [AppBar].
  ///
  /// By default, the value of `toolbarHeight` is [kToolbarHeight].
  /// {@endtemplate}
  final double? toolbarHeight;

  final ShapeBorder kTabShape;
  final ShapeBorder kAppbarShape;
  final Widget kBackBtn = const Icon(
    Icons.arrow_back_ios,
    // color: Colors.black54,
  );

  @override
  final Size preferredSize;

  @override
  State<StatefulWidget> createState() => _AppbarWithTabState();
}

class _AppbarWithTabState extends State<AppbarWithTab> {
  Color? backgroundColor;
  Widget? leading;

  late bool canPop;

  @override
  Widget build(BuildContext context) {
    final parentRoute = ModalRoute.of(context);

    canPop = (parentRoute!.canPop) && !Scaffold.of(context).isDrawerOpen;

    backgroundColor = widget.backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor;

    leading = widget.leading;

    if (leading == null && widget.automaticallyImplyLeading) {
      if (Scaffold.of(context).hasDrawer) {
        leading = IconButton(
          splashRadius: 20,
          icon: const Icon(Icons.menu),
          onPressed: Scaffold.of(context).openDrawer,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (canPop) {
          leading = _BackButton(onPressed: widget.onBackButtonPressed);
        } else {
          leading = null;
        }
      }
    }

    return SafeArea(
      top: true,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!canPop) _buildTab(context),
          if (!canPop) const Spacer(),
          Hero(
            tag: '_topBarBtn',
            transitionOnUserGestures: true,
            createRectTween: (Rect? begin, Rect? end) => RectTween(
              begin: Rect.fromCenter(
                center: Offset(
                  // Make a rectangle that is centred at the middle of the right main split app bar
                  // MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / (1.5 * 2),
                  begin!.center.dx,
                  begin.center.dy,
                ),
                // Make a rectangle that is the width of the right main split app bar
                width: MediaQuery.of(context).size.width / 2,
                height: begin.height,
              ),
              end: end,
            ),
            child: _buildAppbar(context),
          ).expanded(flex: 2),
        ],
      ),
    );
  }

  // This is the small tab that carries the leading
  Widget _buildTab(BuildContext context) {
    // Okay this may look stupid, but if you use the elevation on the card widget it creates a weight artifact with semi opaque colors
    return Material(
      elevation: widget.elevation,
      color: Colors.transparent,
      child: Card(
        color: backgroundColor,
        elevation: widget.elevation,
        shape: widget.tabShape ?? widget.kTabShape,
        margin: EdgeInsets.zero,
        child: SafeArea(
          right: false,
          top: false,
          minimum: const EdgeInsets.only(left: 10),
          child: SizedBox(
            height: double.infinity,
            child: leading?.fittedBox(fit: BoxFit.fitHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    // Okay this may look stupid, but if you use the elevation on the card widget it creates a weight artifact with semi opaque colors
    return Material(
      elevation: widget.elevation,
      color: Colors.transparent,
      child: Card(
        color: backgroundColor,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: widget.kAppbarShape,
        child: Container(
          margin: EdgeInsets.all(widget.tabRadius / 3),
          height: double.infinity,
          alignment: Alignment.centerLeft,
          // This is a row because sometimes it has the leading widget
          child: Row(
            children: [
              if (canPop) leading!.fittedBox(),
              widget.title.fittedBox().withTextStyle(style: const TextStyle(fontSize: 24)).withPaddingOnly(left: 10),
            ],
          ),
        ),
      ),
    );
  }
}

ShapeBorder kBackButtonShape = const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);

Widget kBackBtn = const Icon(
  Icons.arrow_back_ios,
  // color: Colors.black54,
);

class _BackButton extends StatelessWidget {
  const _BackButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: const BackButtonIcon(),
      splashRadius: 23,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
