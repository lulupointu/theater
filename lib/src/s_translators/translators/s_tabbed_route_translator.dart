import 'package:flutter/widgets.dart';

import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../route/s_tabbed_route/s_tabbed_route.dart';
import '../../s_router/s_router.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';
import '../s_translators_handler.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class STabbedRouteTranslator<TabbedRoute extends STabbedRoute<T, P>, T,
    P extends MaybeSPushable> extends STranslator<TabbedRoute, P> {

  STabbedRouteTranslator({
    String path = '*',
    required TabbedRoute? Function(Map<T, SRouteInterface<NonSPushable>?> newTabsRoute)
        routeBuilder,
    this.routeToWebEntry = _defaultTabsMatchToWebEntry,
    required this.tabTranslators,
  })  : matchToRoute = ((_, tabsRoute) => routeBuilder(tabsRoute)),
        _matcher = WebEntryMatcher(path: path),
        _sTranslatorsHandlers = {
          for (var key in tabTranslators.keys)
            key: STranslatorsHandler(translators: tabTranslators[key]!)
        };

  STabbedRouteTranslator.parse({
    required String path,
    required this.matchToRoute,
    required this.routeToWebEntry,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,
    required this.tabTranslators,
  })  : _matcher = WebEntryMatcher(
          path: path,
          validatePathParams: validatePathParams,
          validateQueryParams: validateQueryParams,
          validateFragment: validateFragment,
          validateHistoryState: validateHistoryState,
        ),
        _sTranslatorsHandlers = {
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
  /// Return [null] if the [WebEntry] should not be converted to the associated
  /// [STabbedRoute]
  ///
  ///
  /// For example, for a 3 tabbed route, a common way to implement this function
  /// would be the following:
  /// ```dart
  /// tabsRouteToWebEntry: (_, __, tabsRoute) {
  ///   if (!tabsRoute.entries.any((e) => e.value != null)) return null;
  ///
  ///   final activeTabRoute = tabsRoute.entries.firstWhere((e) => e.value != null);
  ///
  ///   return MySTabbedRoute.toTab(
  ///     activeTab: activeTabRoute.key,
  ///     newTabRoute: activeTabRoute.value!,
  ///   );
  /// }
  /// ```
  final TabbedRoute? Function(
    WebEntryMatch match,
    Map<T, SRouteInterface<NonSPushable>?> tabsRoute,
  ) matchToRoute;

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
  ) routeToWebEntry;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  /// Map the tab index to the tab [STranslatorHandler]
  final Map<T, STranslatorsHandler<NonSPushable>> _sTranslatorsHandlers;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, TabbedRoute route) {
    final sRouteState = STabbedRouteState.from(context: context, sTabbedRoute: route);

    // Get each web entry returned by each tab, if any
    final tabsWebEntry = {
      for (final key in sRouteState.tabsRoute.keys)
        key: _sTranslatorsHandlers[key]
            ?.getWebEntryFromRoute(context, sRouteState.tabsRoute[key]!),
    };

    return routeToWebEntry(context, route, tabsWebEntry);
  }

  @override
  TabbedRoute? webEntryToSRoute(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    // Get each route returned by each tab, if any
    final tabsRoute = {
      for (var key in _sTranslatorsHandlers.keys)
        key: _sTranslatorsHandlers[key]!.getRouteFromWebEntry(context, webEntry),
    };

    return matchToRoute(match, tabsRoute);
  }

  /// A default function for [sRouteToWebEntry] which returns the [WebEntry]
  /// returned by the [STabbedRoute] activeTab
  ///
  ///
  /// If the translators of the active tab could not translate the given tab,
  /// a, [UnknownSRouteError] is thrown
  static WebEntry _defaultTabsMatchToWebEntry(
    BuildContext context,
    STabbedRoute route,
    Map<Object?, WebEntry?> tabsWebEntry,
  ) {
    if (tabsWebEntry[route.activeTab] == null) {
      throw UnknownSRouteError(sRoute: route);
    }

    return tabsWebEntry[route.activeTab]!;
  }
}
