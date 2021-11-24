import '../pushables/pushables.dart';
import '../s_route_interface.dart';

/// Description of a tab of [STabbedRoute]
class STab {
  /// The initial route of the tab
  final SRouteInterface<NonSPushable> initialSRoute;

  /// The current route to be displayed
  ///
  ///
  /// If this is null, the current route will be the last route that has been
  /// used in this tab
  /// If this tab is new (and therefore there is no "last used route")
  /// [initialSRoute] will be used
  final SRouteInterface<NonSPushable>? currentSRoute;

  // ignore: public_member_api_docs
  STab({required this.initialSRoute, required this.currentSRoute});
}
