import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../browser/web_entry.dart';
import '../../../routes/framework.dart';
import '../../../routes/s_nested.dart';
import '../../../routes/s_tabs_route/s_3_tabs_route.dart';
import '../../../s_router/s_router.dart';
import '../../s_translator.dart';
import '../../s_translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class S3TabsRouteTranslator<Route extends S3TabsRoute<N>, N extends MaybeSNested>
    extends STabsRouteTranslator<Route, S3TabsState, N> {
  /// {@macro srouter.s_tabs_route_translators.constructor}
  ///
  /// See also:
  ///   - [S3TabsRouteTranslator.parse] for a way to match the path dynamically
  S3TabsRouteTranslator({
    required Route Function(StateBuilder<S3TabsState> stateBuilder) route,

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
  })  : matchToRoute =
  ((_, stateBuilder) => stateBuilder == null ? null : route(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        sTranslatorsHandlers = [
          STranslatorsHandler(translators: tab1Translators),
          STranslatorsHandler(translators: tab2Translators),
          STranslatorsHandler(translators: tab3Translators),
        ],
        routeToWebEntry = _defaultRouteToWebEntry;

  /// {@macro srouter.s_tabs_route_translators.parse}
  S3TabsRouteTranslator.parse({
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
        ];

  @override
  final Route? Function(WebEntryMatch match, StateBuilder<S3TabsState>? stateBuilder)
  matchToRoute;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
      Route route,
      S3TabsState state,
      WebEntry? activeTabWebEntry,
      ) routeToWebEntry;

  @override
  final List<STranslatorsHandler<SNested>> sTranslatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
      S3TabsRoute route,
      S3TabsState state,
      WebEntry? activeTabWebEntry,
      ) {
    if (activeTabWebEntry == null) {
      throw UnknownSRouteError(sRoute: route);
    }

    return activeTabWebEntry;
  }

  @override
  S3TabsState buildFromSTabsState(int activeIndex, IList<SRouteBase<SNested>> sRoutes) {
    return S3TabsState(
      activeIndex: activeIndex,
      tab1SRoute: sRoutes[0],
      tab2SRoute: sRoutes[1],
      tab3SRoute: sRoutes[2],
    );
  }
}
