import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../browser/web_entry.dart';
import '../../../page_stack/framework.dart';
import '../../../page_stack/nested_stack.dart';
import '../../../page_stack/multi_tab_page_stack/multi_2_tabs_page_stack.dart';
import '../../../s_router/s_router.dart';
import '../../translator.dart';
import '../../translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';


/// PageStackBase
/// PageStack
/// MultiTabPageStack -> MultiTabState
/// 2TabsPageStack -> 2TabsState
///
/// MaybeNestedStack
/// NestedStack
/// NonNestedStack
///
/// Translator
/// PathTranslator
/// MultiTabTranslator

/// A translator which should be used with a [STabbedRoute]
class Multi2TabsTranslator<Route extends Multi2TabsPageStack<N>, N extends MaybeNestedStack>
    extends MultiTabTranslator<Route, Multi2TabsState, N> {
  /// {@template srouter.multi_tab_translators.constructor}
  ///
  /// [route] builds the associated [MultiTabPageStack] from a [StateBuilder],
  /// Use MySTabsRoute.new
  ///
  /// There are also one list of [STranslator] per tab, which you should use to
  /// map the different possible [PageStack]s of each tab to a url
  ///
  ///
  /// ### Example with 2 tabs
  /// ```dart
  /// Multi2TabsTranslator<MyTabsRoute, NotSNested>(
  ///   route: MyTabsRoute.new,
  ///   tab1Translators: [...],
  ///   tab2Translators: [...],
  /// )
  /// ```
  ///
  ///
  /// If a [MultiTabPageStack] of the associated type [Route] is given to [SRouter]
  /// but the active tab could not be converted to a [WebEntry], an
  /// [UnknownPageStackError] will be thrown
  ///
  /// {@endtemplate}
  ///
  /// See also:
  ///   - [Multi2TabsTranslator.parse] for a way to match the path dynamically
  Multi2TabsTranslator({
    required Route Function(StateBuilder<Multi2TabsState> stateBuilder) route,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] page_stack)
    required List<STranslator<SElement<NestedStack>, PageStackBase<NestedStack>, NestedStack>>
        tab1Translators,
    required List<STranslator<SElement<NestedStack>, PageStackBase<NestedStack>, NestedStack>>
        tab2Translators,
  })  : matchToPageStack =
            ((_, stateBuilder) => stateBuilder == null ? null : route(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        translatorsHandlers = [
          TranslatorsHandler(translators: tab1Translators),
          TranslatorsHandler(translators: tab2Translators),
        ],
        pageStackToWebEntry = _defaultRouteToWebEntry;

  /// {@template srouter.multi_tab_translators.parse}
  ///
  /// Allows you to parse the incoming [WebEntry]
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToPageStack] is called when the current path matches [path], and must
  /// return a [MultiTabPageStack] of the associated [Route] type.
  /// Use the given match object to access the different parameters of the
  /// matched path.
  /// The given stateBuilder value depends on whether a [tabXTranslators]
  /// converted the [WebEntry] to a [SRouteBase]:
  ///   - If a [tabXTranslators] converted the [WebEntry] to tabSRoute then the
  ///     stateBuilder is:
  ///     `((state) => state.copyWith(activeIndex: x, tabXRoute: tabSRoute)`
  ///   - If no [tabXTranslators] matched, stateBuilder is null
  ///
  /// [pageStackToWebEntry] converts the [PageStack] of the associated [Route] type to
  /// a [WebEntry] (i.e. a representation of the url)
  /// The [state] tab is the [MultiTabPageStack] state
  /// The [activeTabWebEntry] variable gives you access to the [WebEntry]
  /// returned by the active tab is also given. If the active  tab could not be
  /// converted to a [WebEntry], this variable is null
  ///
  /// [validatePathParams], [validateQueryParams], [validateFragment] and
  /// [validateHistoryState] are optional parameters and can be used to further
  /// precise which [WebEntry] to match
  ///
  /// There are also one list of [STranslator] per tab, which you should use to
  /// map the different possible [PageStack]s of each tab to a url
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
  Multi2TabsTranslator.parse({
    required String path,
    required this.matchToPageStack,
    required this.pageStackToWebEntry,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] page_stack)
    required List<STranslator<SElement<NestedStack>, PageStackBase<NestedStack>, NestedStack>>
        tab1Translators,
    required List<STranslator<SElement<NestedStack>, PageStackBase<NestedStack>, NestedStack>>
        tab2Translators,
  })  : matcher = WebEntryMatcher(
          path: path,
          validatePathParams: validatePathParams,
          validateQueryParams: validateQueryParams,
          validateFragment: validateFragment,
          validateHistoryState: validateHistoryState,
        ),
        translatorsHandlers = [
          TranslatorsHandler(translators: tab1Translators),
          TranslatorsHandler(translators: tab2Translators),
        ];

  @override
  final Route? Function(WebEntryMatch match, StateBuilder<Multi2TabsState>? stateBuilder)
      matchToPageStack;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
    Route route,
    Multi2TabsState state,
    WebEntry? activeTabWebEntry,
  ) pageStackToWebEntry;

  @override
  final List<TranslatorsHandler<NestedStack>> translatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
    Multi2TabsPageStack route,
    Multi2TabsState state,
    WebEntry? activeTabWebEntry,
  ) {
    if (activeTabWebEntry == null) {
      throw UnknownPageStackError(pageStack: route);
    }

    return activeTabWebEntry;
  }

  @override
  Multi2TabsState buildFromMultiTabState(int activeIndex, IList<PageStackBase<NestedStack>> sRoutes) {
    return Multi2TabsState(
      activeIndex: activeIndex,
      tab1SRoute: sRoutes[0],
      tab2SRoute: sRoutes[1],
    );
  }
}
