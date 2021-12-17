import 'dart:async';

import 'package:flutter/widgets.dart';

import '../routes/framework.dart';
import '../s_router/s_router.dart';

/// The widget which creates the [Navigator] and map the current
/// [SRoute] to a list of pages to display in [Navigator.pages]
///
///
/// This also handles onPop and onBack
///
///
/// "Root" refers to the fact that this is the one created by [SRouter] directly,
/// event if it might not be the "root navigator" per say.
class RootSFlutterNavigatorBuilder extends StatefulWidget {
  /// The pages to display in the [Navigator]
  final List<Page> pages;

  /// Called when a pop event happened in the created [Navigator]
  ///
  ///
  /// This callback should end up removing the last page of [pages]
  final VoidCallback onPop;

  /// Called when a system pop (android back button press) occured
  final VoidCallback onSystemPop;

  /// The key of the navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  // ignore: public_member_api_docs
  const RootSFlutterNavigatorBuilder({
    Key? key,
    required this.pages,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.onPop,
    required this.onSystemPop,
  }) : super(key: key);

  @override
  _RootSFlutterNavigatorBuilderState createState() => _RootSFlutterNavigatorBuilderState();
}

class _RootSFlutterNavigatorBuilderState extends State<RootSFlutterNavigatorBuilder> {
  /// The key of the navigator created in [build]
  ///
  /// Used to call pop
  late final GlobalKey<NavigatorState> _navigatorKey =
      widget.navigatorKey ?? GlobalKey<NavigatorState>();

  /// Call when [Navigator.onPopPage] is called
  bool _onPopPage(Route<dynamic> route, Object? data) {
    // First check if the route did pop
    final didPop = route.didPop(data);

    if (didPop) {
      // If the page did pop, call [onPop] so that the last [Page] of
      // [widget.pages] gets removed
      widget.onPop();
    }

    return didPop;
  }

  /// Called when the android back button is pressed
  Future<bool> _onBackButtonPressed() async {
    // If the root navigator (certainly the one created by WidgetApp) can pop,
    // it means that a ModalRoute (Dialog, BottomSheet, ...) has been pushed on
    // top of everything so pop it
    if (Navigator.maybeOf(context, rootNavigator: true)?.canPop() ?? false) {
      Navigator.of(context, rootNavigator: true).pop();
      return true;
    }

    // If the navigator created here has something which is not associated with
    // a page (therefore not associated with an SRouter) at the of its routes,
    // pop it
    final _currentRoute = _getTopNavigatorRoute();
    if (_currentRoute?.settings is! Page) {
      _navigatorKey.currentState!.pop();
      return true;
    }

    widget.onSystemPop();

    // SRouter always handles the android back button press
    return true;
  }

  /// Returns the [Route] (NOT [SRoute]) which is at the top of the [Navigator]
  /// created in [build]
  ///
  /// Returns null if [build] has not yet been called
  Route? _getTopNavigatorRoute() {
    Route? topNavigatorRoute;
    _navigatorKey.currentState?.popUntil((route) {
      topNavigatorRoute = route;
      return true;
    });
    return topNavigatorRoute;
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: _onBackButtonPressed,
      child: Navigator(
        key: _navigatorKey,
        observers: widget.navigatorObservers,
        pages: widget.pages,
        onPopPage: _onPopPage,
      ),
    );
  }
}
