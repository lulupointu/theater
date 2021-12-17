import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../browser/web_entry.dart';
import '../../../routes/framework.dart';
import '../../../routes/s_nested.dart';
import '../../../routes/s_tabs_route/s_6_tabs_route.dart';
import '../../../s_router/s_router.dart';
import '../../s_translator.dart';
import '../../s_translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class S6TabsRouteTranslator<Route extends S6TabsRoute<N>, N extends MaybeSNested>
    extends STabsRouteTranslator<Route, S6TabsState, N> {
  /// {@macro srouter.s_tabs_route_translators.constructor}
  ///
  /// See also:
  ///   - [S6TabsRouteTranslator.parse] for a way to match the path dynamically
  S6TabsRouteTranslator({
    required Route Function(StateBuilder<S6TabsState> stateBuilder) route,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] routes)
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab1Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab2Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab3Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab4Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab5Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab6Translators,
  })  : matchToRoute =
  ((_, stateBuilder) => stateBuilder == null ? null : route(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        sTranslatorsHandlers = [
          STranslatorsHandler(translators: tab1Translators),
          STranslatorsHandler(translators: tab2Translators),
          STranslatorsHandler(translators: tab3Translators),
          STranslatorsHandler(translators: tab4Translators),
          STranslatorsHandler(translators: tab5Translators),
          STranslatorsHandler(translators: tab6Translators),
        ],
        routeToWebEntry = _defaultRouteToWebEntry;

  /// {@macro srouter.s_tabs_route_translators.parse}
  S6TabsRouteTranslator.parse({
    required String path,
    required this.matchToRoute,
    required this.routeToWebEntry,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] routes)
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab1Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab2Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab3Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab4Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab5Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
    tab6Translators,
  })  : matcher = WebEntryMatcher(
    path: path,
    validatePathParams: validatePathParams,
    validateQueryParams: validateQueryParams,
    validateFragment: validateFragment,
    validateHistoryState: validateHistoryState,
  ),
        sTranslatorsHandlers = [
          STranslatorsHandler(translators: tab1Translators),
          STranslatorsHandler(translators: tab2Translators),
          STranslatorsHandler(translators: tab3Translators),
          STranslatorsHandler(translators: tab4Translators),
          STranslatorsHandler(translators: tab5Translators),
          STranslatorsHandler(translators: tab6Translators),
        ];

  @override
  final Route? Function(WebEntryMatch match, StateBuilder<S6TabsState>? stateBuilder)
  matchToRoute;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
      Route route,
      S6TabsState state,
      WebEntry? activeTabWebEntry,
      ) routeToWebEntry;

  @override
  final List<STranslatorsHandler<SNested>> sTranslatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
      S6TabsRoute route,
      S6TabsState state,
      WebEntry? activeTabWebEntry,
      ) {
    if (activeTabWebEntry == null) {
      throw UnknownSRouteError(sRoute: route);
    }

    return activeTabWebEntry;
  }

  @override
  S6TabsState buildFromSTabsState(int activeIndex, IList<SRouteBase<SNested>> sRoutes) {
    return S6TabsState(
      activeIndex: activeIndex,
      tab1SRoute: sRoutes[0],
      tab2SRoute: sRoutes[1],
      tab3SRoute: sRoutes[2],
      tab4SRoute: sRoutes[3],
      tab5SRoute: sRoutes[4],
      tab6SRoute: sRoutes[5],
    );
  }
}
