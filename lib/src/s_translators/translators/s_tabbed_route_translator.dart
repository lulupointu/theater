import 'package:flutter/widgets.dart';

import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../route/s_tabbed_route/s_tabbed_route.dart';
import '../../route/s_tabbed_route/s_tabbed_route_state.dart';
import '../../s_router/s_router.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';
import '../s_translators_handler.dart';

/// A translator which should be used with a [STabbedRoute]
class STabbedRouteTranslator<TabbedRoute extends STabbedRoute<T, P>, T, P extends MaybeSPushable>
    extends STranslator<TabbedRoute, P> {
  // ignore: public_member_api_docs
  STabbedRouteTranslator({
    required this.tabsRouteToSTabbedRoute,
    this.tabsMatchToWebEntry = _defaultTabsMatchToWebEntry,
    required this.tabTranslators,
  }) : _sTranslatorsHandlers = {
          for (var key in tabTranslators.keys)
            key: STranslatorsHandler(translators: tabTranslators[key]!)
        };

  /// Map the tab index to the tab translators
  final Map<T, List<STranslator<SRouteInterface<NonSPushable>, NonSPushable>>> tabTranslators;

  /// Returns the [STabbedRoute] associated with the given [WebEntry]
  ///
  ///
  /// [webEntry] is this incoming [WebEntry]
  ///
  /// [tabsRoute] are the [SRouteInterface]s returned by each tab's translators
  /// if any
  ///
  ///
  /// For example, for a 3 tabbed route, a common way to implement this function
  /// would be the following:
  /// ```dart
  /// tabsRouteToWebEntry: (_, __, tabsRoute) {
  ///   final activeTabRoute = tabsRoute.entries.firstWhere((e) => e.value != null);
  ///
  ///   return MySTabbedRoute(
  ///     activeTab: activeTabRoute.key,
  ///     routeTab1: (activeTabRoute.key == 1) ? activeTabRoute.value! : null,
  ///     routeTab2: (activeTabRoute.key == 2) ? activeTabRoute.value! : null,
  ///     routeTab3: (activeTabRoute.key == 3) ? activeTabRoute.value! : null,
  ///   );
  /// }
  /// ```
  final TabbedRoute Function(
    BuildContext context,
    WebEntry webEntry,
    Map<T, SRouteInterface<NonSPushable>?> tabsRoute,
  ) tabsRouteToSTabbedRoute;

  /// Returns the web entry to return web the associated [STabbedRoute] is
  /// pushed into [SRouter]
  ///
  ///
  /// [route] is this incoming [STabbedRoute]
  ///
  /// [tabsWebEntry] are the web entries returned by each tab's translators
  ///
  ///
  /// Defaults to [_defaultTabsMatchToWebEntry] which returns the [WebEntry]
  /// returned by the translators of the [activeTab]
  final WebEntry Function(
    BuildContext context,
    TabbedRoute route,
    Map<T, WebEntry?> tabsWebEntry,
  ) tabsMatchToWebEntry;

  /// Map the tab index to the tab [STranslatorHandler]
  final Map<T, STranslatorsHandler<NonSPushable>> _sTranslatorsHandlers;

  @override
  WebEntry routeToWebEntry(BuildContext context, TabbedRoute route) {
    final sRouteState = STabbedRouteState.from(context: context, sTabbedRoute: route);

    // Get each web entry returned by each tab, if any
    final tabsWebEntry = {
      for (final key in sRouteState.tabsRoute.keys)
        key: _sTranslatorsHandlers[key]
            ?.getWebEntryFromRoute(context, sRouteState.tabsRoute[key]!),
    };

    return tabsMatchToWebEntry(context, route, tabsWebEntry);
  }

  @override
  TabbedRoute? webEntryToRoute(BuildContext context, WebEntry webEntry) {
    // Get each route returned by each tab, if any
    final tabsRoute = {
      for (var key in _sTranslatorsHandlers.keys)
        key: _sTranslatorsHandlers[key]!.getRouteFromWebEntry(context, webEntry),
    };

    return tabsRouteToSTabbedRoute(context, webEntry, tabsRoute);
  }

  /// A default function for [tabsMatchToWebEntry] which returns the [WebEntry]
  /// returned by the [STabbedRoute] activeTab
  ///
  ///
  /// If the translators of the active tab could not translate the given tab,
  /// a, [UnknownSRouteException] is thrown
  static WebEntry _defaultTabsMatchToWebEntry(
    BuildContext context,
    STabbedRoute route,
    Map<Object?, WebEntry?> tabsWebEntry,
  ) {
    if (tabsWebEntry[route.activeTab] == null) {
      throw UnknownSRouteException(sRoute: route);
    }

    return tabsWebEntry[route.activeTab]!;
  }
}
