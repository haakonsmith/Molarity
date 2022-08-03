import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/elements_data_bloc.dart';
import 'package:molarity/data/highlighted_search_bar_controller.dart';
import 'package:molarity/screen/atomic_info_screen.dart';
import 'package:molarity/util.dart';
import 'package:universal_platform/universal_platform.dart';

class MolarityAppBar extends ConsumerStatefulWidget with PreferredSizeWidget {
  const MolarityAppBar({this.hasSearchBar = false, this.height, this.title, Key? key}) : super(key: key);

  final Widget? title;
  final double? height;
  final bool hasSearchBar;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MolarityAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height ?? (UniversalPlatform.isDesktopOrWeb ? 80 : 65));
}

class _MolarityAppBarState extends ConsumerState<MolarityAppBar> {
  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    final appBar = AppbarWithTab(
      title: !(ref.watch(highlightedSearchBarController).showSearchBar && widget.hasSearchBar)
          ? widget.title!
          : SizedBox(
              width: windowSize.width / 2,
              child: TextField(
                style: const TextStyle(fontSize: 40),
                focusNode: ref.read(highlightedSearchBarController).keyBoardFocusNode,
                autofocus: true,
                controller: ref.read(highlightedSearchBarController).searchController,
                onChanged: (value) {
                  ref.read(highlightedSearchBarController).highlightedElements = ref.read(elementsBlocProvider).elements.where((element) => element.symbol.toLowerCase().contains(value)).toList();
                  ref.read(highlightedSearchBarController).keyBoardFocusNode.requestFocus();
                },
                // onEditingComplete: () => ref.read(highlightedSearchBarController).showSearchBar = false,
                onSubmitted: (_) => Navigator.push(context, MaterialPageRoute(builder: (context) {
                  ref.read(highlightedSearchBarController).shortcutFocusNode.requestFocus();

                  return AtomicInfoScreen(ref.read(highlightedSearchBarController).highlightedElements.first);
                })).then((_) => ref.read(highlightedSearchBarController).showSearchBar = false),
              ),
            ),
    );

    final preferredSize = PreferredSize(
      preferredSize: const Size.fromHeight(20),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: appBar,
      ),
    );

    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 80),
      child: Column(children: [
        WindowTitleBarBox(
          child: Row(
            children: [
              Expanded(child: MoveWindow()),
              if (UniversalPlatform.isWindows) const Padding(padding: EdgeInsets.only(bottom: 5), child: WindowButtons()),
            ],
          ),
        ).fixedSize(width: MediaQuery.of(context).size.width, height: 30),
        // const SizedBox(height: 5),
        appBar.fixedSize(width: MediaQuery.of(context).size.width, height: 40),
        // UniversalPlatform.isMacOS ? preferredSize : appBar
      ]),
    );
  }

  static double computePrefferedSize(BuildContext context) {
    // final double height = (MediaQuery.of(context).size.width / 25) >= 60 ? MediaQuery.of(context).size.width / 25 : 60;
    // final double height = (MediaQuery.of(context).size.width / 20);
    double height = 80;

    if (!UniversalPlatform.isDesktop) height = 65;

    return height;
    // return (MediaQuery.of(context).size.width / 25).clamp(50, 70);
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306), mouseOver: const Color(0xFFF6A00C), mouseDown: const Color(0xFF805306), iconMouseOver: const Color(0xFF805306), iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(mouseOver: const Color(0xFFD32F2F), mouseDown: const Color(0xFFB71C1C), iconNormal: const Color(0xFF805306), iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  Widget _buildCard(Widget child) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor.darken(0.01),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      Row(
        children: [
          IconButton(
            onPressed: appWindow.minimize,
            icon: const Icon(Icons.minimize),
            padding: EdgeInsets.zero,
            iconSize: 18,
          ),
          IconButton(
            onPressed: maximizeOrRestore,
            icon: Icon(appWindow.isMaximized ? Icons.fullscreen_exit : Icons.fullscreen),
            padding: EdgeInsets.zero,
            iconSize: 18,
          ),
          IconButton(
            onPressed: appWindow.close,
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            iconSize: 18,
          ),
        ],
      ),
    );
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
    this.elevation = 8,
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
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!canPop) _buildTab(context),
          if (!canPop) const Spacer(),
          Hero(
            tag: '_topBarBtn',
            transitionOnUserGestures: true,
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
