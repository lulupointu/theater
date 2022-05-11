import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

import '../../../browser/web_entry.dart';
import '../../../page_stack/framework.dart';
import '../../../page_stack/multi_tab_page_stack/multi_5_tabs_page_stack.dart';
import '../../../page_stack/multi_tab_page_stack/tab_x_in.dart';
import '../../../theater/theater.dart';
import '../../translator.dart';
import '../../translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class Multi5TabsTranslator<PS extends Multi5TabsPageStack>
    extends MultiTabTranslator<PS, Multi5TabsState> {
  /// {@macro theater.multi_tab_translators.constructor}
  ///
  /// See also:
  ///   - [Multi5TabsTranslator.parse] for a way to match the path dynamically
  Multi5TabsTranslator({
    required PS Function(StateBuilder<Multi5TabsState> stateBuilder) pageStack,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [Translator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] page_stack)
    required List<Translator<PageElement, Tab1In<Multi5TabsPageStack>>>
    tab1Translators,
    required List<Translator<PageElement, Tab2In<Multi5TabsPageStack>>>
    tab2Translators,
    required List<Translator<PageElement, Tab3In<Multi5TabsPageStack>>>
    tab3Translators,
    required List<Translator<PageElement, Tab4In<Multi5TabsPageStack>>>
    tab4Translators,
    required List<Translator<PageElement, Tab5In<Multi5TabsPageStack>>>
    tab5Translators,
  })  : matchToPageStack =
  ((_, stateBuilder) => stateBuilder == null ? null : pageStack(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        translatorsHandlers = [
          TranslatorsHandler(translators: tab1Translators),
          TranslatorsHandler(translators: tab2Translators),
          TranslatorsHandler(translators: tab3Translators),
          TranslatorsHandler(translators: tab4Translators),
          TranslatorsHandler(translators: tab5Translators),
        ],
        pageStackToWebEntry = _defaultRouteToWebEntry;

  /// {@macro theater.multi_tab_translators.parse}
  Multi5TabsTranslator.parse({
    required String path,
    required this.matchToPageStack,
    required this.pageStackToWebEntry,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [Translator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] page_stack)
    required List<Translator<PageElement, Tab1In<Multi5TabsPageStack>>>
    tab1Translators,
    required List<Translator<PageElement, Tab2In<Multi5TabsPageStack>>>
    tab2Translators,
    required List<Translator<PageElement, Tab3In<Multi5TabsPageStack>>>
    tab3Translators,
    required List<Translator<PageElement, Tab4In<Multi5TabsPageStack>>>
    tab4Translators,
    required List<Translator<PageElement, Tab5In<Multi5TabsPageStack>>>
    tab5Translators,
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
          TranslatorsHandler(translators: tab3Translators),
          TranslatorsHandler(translators: tab4Translators),
          TranslatorsHandler(translators: tab5Translators),
        ];

  @override
  final PS? Function(WebEntryMatch match, StateBuilder<Multi5TabsState>? stateBuilder)
  matchToPageStack;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
      PS pageStack,
      MultiTabPageState<Multi5TabsState> state,
      WebEntry? currentTabWebEntry,
      ) pageStackToWebEntry;

  @override
  final List<TranslatorsHandler> translatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
      Multi5TabsPageStack pageStack,
      MultiTabPageState<Multi5TabsState> state,
      WebEntry? currentTabWebEntry,
      ) {
    if (currentTabWebEntry == null) {
      throw UnknownPageStackError(pageStack: pageStack);
    }

    return currentTabWebEntry;
  }

  @override
  @nonVirtual
  Multi5TabsState buildFromMultiTabState(
      int currentIndex,
      IList<PageStackBase> pageStacks,
      ) {
    return Multi5TabsState(
      currentIndex: currentIndex,
      tab1PageStack: pageStacks[0] as Tab1In<Multi5TabsPageStack>,
      tab2PageStack: pageStacks[1] as Tab2In<Multi5TabsPageStack>,
      tab3PageStack: pageStacks[2] as Tab3In<Multi5TabsPageStack>,
      tab4PageStack: pageStacks[3] as Tab4In<Multi5TabsPageStack>,
      tab5PageStack: pageStacks[4] as Tab5In<Multi5TabsPageStack>,
    );
  }
}
