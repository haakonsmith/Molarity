import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util.dart';

class MolarityAppBar {
  static PreferredSizeWidget buildTitle(BuildContext context, Widget? title, {double? height}) {
    var appBar = AppbarWithTab(
      title: title!,
      // backgroundColor: Colors.black54,
      backgroundColor: Colors.white.withOpacity(0.05),
    );
    var preferredSize = PreferredSize(
      preferredSize: Size.fromHeight(height ?? 90.0),
      child: Container(
        // color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: appBar,
      ),
    );

    return Platform.isMacOS ? preferredSize : appBar;
  }
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight) : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

/// This is an [Appbar] replacement that displays the an extra tab and creates
/// a gap between the large appbar and the tab displayed.
class AppbarWithTab extends StatefulWidget implements PreferredSizeWidget {
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
  final TextStyle titleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white);

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
  final Widget kBackBtn = Icon(
    Icons.arrow_back_ios,
    // color: Colors.black54,
  );

  @override
  final Size preferredSize;

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
          icon: Icon(Icons.menu),
          onPressed: Scaffold.of(context).openDrawer,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (canPop) {
          leading = _BackButton(onPressed: widget.onBackButtonPressed);
        } else {
          leading = Container();
        }
      }
    }

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!canPop) _buildTab(context),
          if (!canPop) Spacer(),
          Hero(
            tag: "_topBarBtn",
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
        margin: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          height: double.infinity,
          child: leading,
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
        margin: EdgeInsets.all(0),
        elevation: 0,
        shape: widget.kAppbarShape,
        child: Container(
          margin: EdgeInsets.all(widget.tabRadius / 3),
          height: double.infinity,
          alignment: Alignment.centerLeft,
          // This is a row because sometimes it has the leading widget
          child: Row(
            children: [
              if (canPop) leading!,
              widget.title.fittedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Based off my boy at: https://github.com/ketanchoyal/custom_top_bar

ShapeBorder kBackButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);

Widget kBackBtn = Icon(
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

// Generates a pill appbar contextually
class PillAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final VoidCallback? onPressed;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onTitleTapped;
  final double elevation;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final TextStyle titleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white);

  @override
  final Size preferredSize;

  PillAppBar({
    Key? key,
    required this.title,
    this.onPressed,
    this.leading,
    this.onTitleTapped,
    this.elevation = 10,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.onBackButtonPressed,
  }) : preferredSize = Size.fromHeight(80.0);

  State<StatefulWidget> createState() => _PillAppBarState();
}

class _PillAppBarState extends State<PillAppBar> {
  late TextStyle titleTextStyle;
  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final parentRoute = ModalRoute.of(context);

    final bool canPop = (parentRoute!.canPop) && !Scaffold.of(context).isDrawerOpen;

    backgroundColor = widget.backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor;

    titleTextStyle = widget.titleTextStyle.merge(TextStyle(color: (backgroundColor ?? Colors.white).computeLuminance() > 0.5 ? Colors.black : Colors.white));

    Widget? leading = widget.leading;

    if (leading == null && widget.automaticallyImplyLeading) {
      if (Scaffold.of(context).hasDrawer) {
        leading = IconButton(
          splashRadius: 20,
          icon: Icon(Icons.menu),
          onPressed: Scaffold.of(context).openDrawer,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (canPop) {
          leading = _BackButton(onPressed: widget.onBackButtonPressed);
        } else {
          leading = Container();
        }
      }
    }

    // return _drawSplitAppBar(appTheme, context, leading);
    return canPop ? _buildPillAppBar(context, leading!) : _buildSplitAppBar(context, leading!);
  }

  Widget _buildAppBarButton(BuildContext context, Widget leading) {
    return MaterialButton(
      height: 50,
      minWidth: 50,
      shape: kBackButtonShape,
      elevation: widget.elevation,
      onPressed: widget.onPressed,
      child: IconTheme.merge(data: Theme.of(context).iconTheme, child: leading),
    );
  }

  Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  Widget _buildTitleAlign() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: DefaultTextStyle(child: widget.title, style: titleTextStyle),
        ),
      ),
    );
  }

  // Make a rectTween that is centred at the middle of the right main split app bar
  RectTween _createRightCentredRectTween(Rect? begin, Rect? end) {
    return RectTween(
      begin: Rect.fromCenter(
        center: Offset(
          // Make a rectangle that is centred at the middle of the right main split app bar
          // MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / (1.5 * 2),
          begin!.center.dx,
          begin.center.dy,
        ),
        // Make a rectangle that is the width of the right main split app bar
        width: MediaQuery.of(context).size.width / 4,
        height: begin.height,
      ),
      end: end,
    );
  }

  SafeArea _buildPillAppBar(BuildContext context, Widget leading) {
    return SafeArea(
      child: Hero(
        tag: "title",
        // This creates the cool animation where it aligns with the main screen bar
        createRectTween: _createRightCentredRectTween,
        transitionOnUserGestures: true,
        child: Card(
          margin: EdgeInsets.only(top: 2, left: 2),
          color: backgroundColor,
          elevation: widget.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(15),
              topLeft: const Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              _buildAppBarButton(context, leading),
              Center(
                child: InkWell(onTap: widget.onTitleTapped, child: _buildTitleAlign()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitAppBar(BuildContext context, Widget leading) {
    return SafeArea(
      child: IconTheme.merge(
        data: Theme.of(context).iconTheme,
        child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Hero(
            tag: "_topBarBtn",
            transitionOnUserGestures: true,
            createRectTween: (Rect? begin, Rect? end) {
              return RectTween(
                begin: Rect.fromCenter(
                  center: Offset(
                    // Make a rectangle that is centred at the middle of the right main split app bar
                    // MediaQuery.of(context).size.width / (1.5 * 2 * 2),
                    // 50 / 2,
                    begin!.center.dx,
                    begin.center.dy,
                  ),
                  // Make a rectangle that is the width of the right main split app bar
                  width: MediaQuery.of(context).size.width / (1.5),
                  height: 80,
                ),
                end: end,
              );
            },
            child: Card(
              margin: EdgeInsets.all(0),
              color: backgroundColor,
              elevation: widget.elevation,
              shape: kBackButtonShape,
              child: SizedBox(height: 80, child: _buildAppBarButton(context, leading)),
            ),
          ),
          Hero(
            tag: 'title',
            transitionOnUserGestures: true,
            createRectTween: _createRightCentredRectTween,
            child: Card(
              margin: EdgeInsets.only(top: 2),
              color: backgroundColor,
              elevation: widget.elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(15),
                  topLeft: const Radius.circular(15),
                ),
              ),
              child: InkWell(
                onTap: widget.onTitleTapped,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: 80,
                  child: _buildTitleAlign(),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
