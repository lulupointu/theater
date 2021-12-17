import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../browser/web_entry.dart';
import '../../../routes/framework.dart';
import '../../../routes/s_nested.dart';
import '../../../routes/s_tabs_route/s_2_tabs_route.dart';
import '../../../s_router/s_router.dart';
import '../../s_translator.dart';
import '../../s_translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class S2TabsRouteTranslator<Route extends S2TabsRoute<N>, N extends MaybeSNested>
    extends STabsRouteTranslator<Route, S2TabsState, N> {
  /// {@template srouter.s_tabs_route_translators.constructor}
  ///
  /// [route] builds the associated [STabsRoute] from a [StateBuilder],
  /// Use MySTabsRoute.new
  ///
  /// There are also one list of [STranslator] per tab, which you should use to
  /// map the different possible [SRoute]s of each tab to a url
  ///
  ///
  /// ### Example with 2 tabs
  /// ```dart
  /// S2TabsRouteTranslator<MyTabsRoute, NotSNested>(
  ///   route: MyTabsRoute.new,
  ///   tab1Translators: [...],
  ///   tab2Translators: [...],
  /// )
  /// ```
  ///
  ///
  /// If a [STabsRoute] of the associated type [Route] is given to [SRouter]
  /// but the active tab could not be converted to a [WebEntry], an
  /// [UnknownSRouteError] will be thrown
  ///
  /// {@endtemplate}
  ///
  /// See also:
  ///   - [S2TabsRouteTranslator.parse] for a way to match the path dynamically
  S2TabsRouteTranslator({
    required Route Function(StateBuilder<S2TabsState> stateBuilder) route,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] routes)
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
        tab1Translators,
    required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
        tab2Translators,
  })  : matchToRoute =
            ((_, stateBuilder) => stateBuilder == null ? null : route(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        sTranslatorsHandlers = [
          STranslatorsHandler(translators: tab1Translators),
          STranslatorsHandler(translators: tab2Translators),
        ],
        routeToWebEntry = _defaultRouteToWebEntry;

  /// {@template srouter.s_tabs_route_translators.parse}
  ///
  /// Allows you to parse the incoming [WebEntry]
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToRoute] is called when the current path matches [path], and must
  /// return a [STabsRoute] of the associated [Route] type.
  /// Use the given match object to access the different parameters of the
  /// matched path.
  /// The given stateBuilder value depends on whether a [tabXTranslators]
  /// converted the [WebEntry] to a [SRouteBase]:
  ///   - If a [tabXTranslators] converted the [WebEntry] to tabSRoute then the
  ///     stateBuilder is:
  ///     `((state) => state.copyWith(activeIndex: x, tabXRoute: tabSRoute)`
  ///   - If no [tabXTranslators] matched, stateBuilder is null
  ///
  /// [routeToWebEntry] converts the [SRoute] of the associated [Route] type to
  /// a [WebEntry] (i.e. a representation of the url)
  /// The [state] tab is the [STabsRoute] state
  /// The [activeTabWebEntry] variable gives you access to the [WebEntry]
  /// returned by the active tab is also given. If the active  tab could not be
  /// converted to a [WebEntry], this variable is null
  ///
  /// [validatePathParams], [validateQueryParams], [validateFragment] and
  /// [validateHistoryState] are optional parameters and can be used to further
  /// precise which [WebEntry] to match
  ///
  /// There are also one list of [STranslator] per tab, which you should use to
  /// map the different possible [SRoute]s of each tab to a url
  ///
  ///
  /// IMPORTANT: The [path] given as argument does not influence the [WebEntry]
  /// that the [tabXTranslators] receives
  ///
  ///
  /// See also:
  ///   - [WebEntry] for the different parameters which can be used to form a url
  ///   - [WebEntryMatcher.path] for a precise description of how [path] can be used
  ///
  /// {@endtemplate}
  S2TabsRouteTranslator.parse({
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
        ];

  @override
  final Route? Function(WebEntryMatch match, StateBuilder<S2TabsState>? stateBuilder)
      matchToRoute;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
    Route route,
    S2TabsState state,
    WebEntry? activeTabWebEntry,
  ) routeToWebEntry;

  @override
  final List<STranslatorsHandler<SNested>> sTranslatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
    S2TabsRoute route,
    S2TabsState state,
    WebEntry? activeTabWebEntry,
  ) {
    if (activeTabWebEntry == null) {
      throw UnknownSRouteError(sRoute: route);
    }

    return activeTabWebEntry;
  }

  @override
  S2TabsState buildFromSTabsState(int activeIndex, IList<SRouteBase<SNested>> sRoutes) {
    return S2TabsState(
      activeIndex: activeIndex,
      tab1SRoute: sRoutes[0],
      tab2SRoute: sRoutes[1],
    );
  }
}
