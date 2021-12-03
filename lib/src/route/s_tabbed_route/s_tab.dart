import '../pushables/pushables.dart';
import '../s_route_interface.dart';

/// Description of a tab of [STabbedRoute]
class STab {
  /// The initial route of the tab
  final SRouteInterface<NonSPushable> initialSRoute;

  /// Builds the [SRouteInterface] of the associated tab
  ///
  ///
  /// The [tab] argument given in this builder is the previous visible tab
  final SRouteInterface<NonSPushable> Function(SRouteInterface<NonSPushable> tab)
      tabRouteBuilder;

  /// Describes a tab which might get updated
  ///
  ///
  /// [tabRouteBuilder] is used to build a new tab based on the previous visible
  /// one
  ///
  /// [initialSRoute] is needed and will be used in [tabRouteBuilder] if there
  /// is no "previous visible" tab
  STab(this.tabRouteBuilder, {required this.initialSRoute});

  /// Describes a tab in which the [SRoute] is always the same
  STab.static(this.initialSRoute) : tabRouteBuilder = ((tab) => initialSRoute);
}
