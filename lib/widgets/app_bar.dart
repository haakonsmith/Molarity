import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MolarityAppBar {
  static PreferredSizeWidget buildTitle(BuildContext context, Widget? title, {double? height}) {
    var appBar = PillAppBar(
      title: title!,
      // backgroundColor: Colors.black54,
      backgroundColor: Colors.white.withOpacity(0.05),
    );
    var preferredSize = PreferredSize(
      preferredSize: Size.fromHeight(height ?? 90.0),
      child: Container(
        // color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: SafeArea(child: appBar),
      ),
    );

    return Platform.isMacOS ? preferredSize : appBar;
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
