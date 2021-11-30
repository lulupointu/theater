import 'package:flutter/widgets.dart';

import '../route/s_route_interface.dart';
import 'root_flutter_navigator_builder.dart';

/// The widget which creates the [Navigator] and map the current
/// [SRoute] to a list of pages to display in [Navigator.pages]
///
///
/// This does NOT handle android back button press since it should be handled
/// only by the [RootSFlutterNavigatorBuilder]
///
/// This does NOT handle the onPop directly, but rather pass the onPop call to
/// the navigator above
///
///
/// "Nested" refers to the fact that this is created by [SRouteInterface]
/// inside [SRouter] (since [SRouter] created a navigator, this was is
/// necessarily nested)
class NestedSFlutterNavigatorBuilder<T> extends StatefulWidget {

  /// The [SRouteInterface] which pages to display in the [Navigator]
  final SRouteInterface sRoute;

  /// The key of the navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  // ignore: public_member_api_docs
  const NestedSFlutterNavigatorBuilder({
    Key? key,
    required this.sRoute,
    required this.navigatorKey,
    required this.navigatorObservers,
  }) : super(key: key);

  @override
  _NestedSFlutterNavigatorBuilderState createState() => _NestedSFlutterNavigatorBuilderState();
}

class _NestedSFlutterNavigatorBuilderState extends State<NestedSFlutterNavigatorBuilder> {
  /// Returns the stack of pages associated with the given [sRoute]
  List<Page> _getPagesFromSRoute(SRouteInterface sRoute) {
    final sRouteBellow = sRoute.buildSRouteBellow(context);

    return [
      if (sRouteBellow != null) ..._getPagesFromSRoute(sRouteBellow),
      sRoute.pageBuilder(context),
    ];
  }

  /// Call the root onPopPage
  bool _onPopPage(Route<dynamic> route, dynamic data) {
    return RootSFlutterNavigatorBuilder.onPopPage(context, route, data);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      observers: widget.navigatorObservers,
      pages: _getPagesFromSRoute(widget.sRoute),
      onPopPage: _onPopPage,
    );
  }
}
