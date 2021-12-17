// import 'package:fast_immutable_collections/fast_immutable_collections.dart';
//
// import '../../../browser/web_entry.dart';
// import '../../../page_stack/framework.dart';
// import '../../../page_stack/nested_stack.dart';
// import '../../../page_stack/multi_tab_page_stack/multi_5_tabs_page_stack.dart';
// import '../../../s_router/s_router.dart';
// import '../../translator.dart';
// import '../../translators_handler.dart';
// import '../web_entry_matcher/web_entry_match.dart';
// import '../web_entry_matcher/web_entry_matcher.dart';
//
// /// A translator which should be used with a [STabbedRoute]
// class Multi5TabsTranslator<Route extends Multi5Tabs<N>, N extends MaybeSNested>
//     extends STabsRouteTranslator<Route, Multi5TabsState, N> {
//   /// {@macro srouter.multi_tab_translators.constructor}
//   ///
//   /// See also:
//   ///   - [Multi5TabsTranslator.parse] for a way to match the path dynamically
//   Multi5TabsTranslator({
//     required Route Function(StateBuilder<Multi5TabsState> stateBuilder) route,
//
//     // Translators for each tabs
//     // The type seem quite complex but what it means is that the [STranslator]
//     // used in the lists must translated [SNested] sRoutes (since sRoutes
//     // inside a STabsRoute are [SNested] page_stack)
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab1Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab2Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab3Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab4Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab5Translators,
//   })  : matchToRoute =
//   ((_, stateBuilder) => stateBuilder == null ? null : route(stateBuilder)),
//         matcher = WebEntryMatcher(path: '*'),
//         sTranslatorsHandlers = [
//           STranslatorsHandler(translators: tab1Translators),
//           STranslatorsHandler(translators: tab2Translators),
//           STranslatorsHandler(translators: tab3Translators),
//           STranslatorsHandler(translators: tab4Translators),
//           STranslatorsHandler(translators: tab5Translators),
//         ],
//         routeToWebEntry = _defaultRouteToWebEntry;
//
//   /// {@macro srouter.multi_tab_translators.parse}
//   Multi5TabsTranslator.parse({
//     required String path,
//     required this.matchToRoute,
//     required this.routeToWebEntry,
//
//     // Functions used to validate the different components of the url
//     final bool Function(Map<String, String> pathParams)? validatePathParams,
//     final bool Function(Map<String, String> queryParams)? validateQueryParams,
//     final bool Function(String fragment)? validateFragment,
//     final bool Function(Map<String, String> historyState)? validateHistoryState,
//
//     // Translators for each tabs
//     // The type seem quite complex but what it means is that the [STranslator]
//     // used in the lists must translated [SNested] sRoutes (since sRoutes
//     // inside a STabsRoute are [SNested] page_stack)
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab1Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab2Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab3Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab4Translators,
//     required List<STranslator<SElement<SNested>, SRouteBase<SNested>, SNested>>
//     tab5Translators,
//   })  : matcher = WebEntryMatcher(
//     path: path,
//     validatePathParams: validatePathParams,
//     validateQueryParams: validateQueryParams,
//     validateFragment: validateFragment,
//     validateHistoryState: validateHistoryState,
//   ),
//         sTranslatorsHandlers = [
//           STranslatorsHandler(translators: tab1Translators),
//           STranslatorsHandler(translators: tab2Translators),
//           STranslatorsHandler(translators: tab3Translators),
//           STranslatorsHandler(translators: tab4Translators),
//           STranslatorsHandler(translators: tab5Translators),
//         ];
//
//   @override
//   final Route? Function(WebEntryMatch match, StateBuilder<Multi5TabsState>? stateBuilder)
//   matchToRoute;
//
//   @override
//   final WebEntryMatcher matcher;
//
//   @override
//   final WebEntry Function(
//       Route route,
//       Multi5TabsState state,
//       WebEntry? activeTabWebEntry,
//       ) routeToWebEntry;
//
//   @override
//   final List<STranslatorsHandler<SNested>> sTranslatorsHandlers;
//
//   static WebEntry _defaultRouteToWebEntry(
//       Multi5Tabs route,
//       Multi5TabsState state,
//       WebEntry? activeTabWebEntry,
//       ) {
//     if (activeTabWebEntry == null) {
//       throw UnknownSRouteError(sRoute: route);
//     }
//
//     return activeTabWebEntry;
//   }
//
//   @override
//   Multi5TabsState buildFromSTabsState(int activeIndex, IList<SRouteBase<SNested>> sRoutes) {
//     return Multi5TabsState(
//       activeIndex: activeIndex,
//       tab1SRoute: sRoutes[0],
//       tab2SRoute: sRoutes[1],
//       tab3SRoute: sRoutes[2],
//       tab4SRoute: sRoutes[3],
//       tab5SRoute: sRoutes[4],
//     );
//   }
// }
