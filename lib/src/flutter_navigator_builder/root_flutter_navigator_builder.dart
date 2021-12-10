import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:move_to_background/move_to_background.dart';

import '../back_button_handler/s_back_button_handler.dart';
import '../route/on_pop_result/on_pop_result.dart';
import '../route/pushables/pushables.dart';
import '../route/s_route_interface.dart';
import '../s_router/build_context_s_router_extension.dart';
import '../s_router/s_router.dart';
import 'nested_flutter_navigator_builder.dart';

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
  /// The [SRouteInterface] which pages to display in the [Navigator]
  final SRouteInterface<SPushable> sRoute;

  /// When the current route [onPop] or [onBack] is called and their return
  /// value indicate that the event should be handled by the router, the router
  /// will send the app to the background.
  /// You can set [disableUniversalTranslator] to true to disable this behavior
  ///
  /// By default, such an event occurs when the current route doesn't have an
  /// sRouteBellow
  final bool disableSendAppToBackground;

  /// The key of the navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  // ignore: public_member_api_docs
  const RootSFlutterNavigatorBuilder({
    Key? key,
    required this.sRoute,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.disableSendAppToBackground,
  }) : super(key: key);

  @override
  _RootSFlutterNavigatorBuilderState createState() => _RootSFlutterNavigatorBuilderState();

  /// Calls the [RootSFlutterNavigatorBuilder] onPopPage method, this should be
  /// used in [NestedSFlutterNavigatorBuilder] when [Navigator.onPopPage] is called
  static bool onPopPage(BuildContext context, Route<dynamic> route, dynamic data) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_RootSFlutterNavigatorBuilderProvider>();
    assert(result != null, 'No RootSFlutterNavigatorBuilderProvider found in context');
    return result!.onPopPage(context, route, data);
  }
}

class _RootSFlutterNavigatorBuilderState extends State<RootSFlutterNavigatorBuilder> {
  /// The key of the navigator created in [build]
  ///
  /// Used to call pop
  late final GlobalKey<NavigatorState> _navigatorKey =
      widget.navigatorKey ?? GlobalKey<NavigatorState>();

  /// Returns the stack of pages associated with the given [sRoute]
  List<Page> _getPagesFromSRoute(SRouteInterface sRoute) {
    final sRouteBellow = sRoute.buildSRouteBellow(context);

    return [
      if (sRouteBellow != null) ..._getPagesFromSRoute(sRouteBellow),
      sRoute.pageBuilder(context),
    ];
  }

  /// Call when [Navigator.onPopPage] is called
  bool _onPopPage(BuildContext context, Route<dynamic> route, dynamic data) {
    // First handle the pop internally (i.e. inside the [Route] object)
    final internalShouldPop = route.didPop(data);
    if (!internalShouldPop) {
      return false;
    }

    return _handleSPop(widget.sRoute.onPop(context, data));
  }

  /// Called when the android back button is pressed
  FutureOr<bool> _onBackButtonEvent() async {
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
    if (_getTopNavigatorRoute()?.settings is Page) {
      _navigatorKey.currentState!.pop();
      return true;
    }

    return _handleSPop(await widget.sRoute.onBack(context));
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

  /// Act based on a [SPop] value return either by the onPop or onBack callback
  bool _handleSPop(SPop<SPushable> sPop) {
    return sPop.when(
      prevent: () => false,
      parent: () {
        if (!widget.disableSendAppToBackground) {
          MoveToBackground.moveTaskToBack();
          return true;
        }
        return false;
      },
      on: (newSRoute) {
        context.sRouter.to(newSRoute);
        return true;
      },
      historyGo: (delta) {
        context.sRouter.go(delta);
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _RootSFlutterNavigatorBuilderProvider(
      onPopPage: _onPopPage,
      child: SBackButtonHandler(
        onBackButtonEventCallback: _onBackButtonEvent,
        child: Navigator(
          key: _navigatorKey,
          observers: widget.navigatorObservers,
          pages: _getPagesFromSRoute(widget.sRoute),
          onPopPage: (route, data) => _onPopPage(context, route, data),
        ),
      ),
    );
  }
}

class _RootSFlutterNavigatorBuilderProvider extends InheritedWidget {
  final bool Function(BuildContext context, Route<dynamic> route, dynamic data) onPopPage;

  const _RootSFlutterNavigatorBuilderProvider({
    Key? key,
    required Widget child,
    required this.onPopPage,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_RootSFlutterNavigatorBuilderProvider old) => false;
}
