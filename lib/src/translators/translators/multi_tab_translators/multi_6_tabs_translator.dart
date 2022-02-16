import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

import '../../../browser/web_entry.dart';
import '../../../page_stack/framework.dart';
import '../../../page_stack/multi_tab_page_stack/multi_6_tabs_page_stack.dart';
import '../../../page_stack/multi_tab_page_stack/tabXIn.dart';
import '../../../s_router/s_router.dart';
import '../../translator.dart';
import '../../translators_handler.dart';
import '../web_entry_matcher/web_entry_match.dart';
import '../web_entry_matcher/web_entry_matcher.dart';

/// A translator which should be used with a [STabbedRoute]
class Multi6TabsTranslator<PS extends Multi6TabsPageStack>
    extends MultiTabTranslator<PS, Multi6TabsState> {
  /// {@macro srouter.multi_tab_translators.constructor}
  ///
  /// See also:
  ///   - [Multi6TabsTranslator.parse] for a way to match the path dynamically
  Multi6TabsTranslator({
    required PS Function(StateBuilder<Multi6TabsState> stateBuilder) pageStack,

    // Translators for each tabs
    // The type seem quite complex but what it means is that the [STranslator]
    // used in the lists must translated [SNested] sRoutes (since sRoutes
    // inside a STabsRoute are [SNested] page_stack)
    required List<STranslator<SElement, Tab1In<Multi6TabsPageStack>>> tab1Translators,
    required List<STranslator<SElement, Tab2In<Multi6TabsPageStack>>> tab2Translators,
    required List<STranslator<SElement, Tab3In<Multi6TabsPageStack>>> tab3Translators,
    required List<STranslator<SElement, Tab4In<Multi6TabsPageStack>>> tab4Translators,
    required List<STranslator<SElement, Tab5In<Multi6TabsPageStack>>> tab5Translators,
    required List<STranslator<SElement, Tab6In<Multi6TabsPageStack>>> tab6Translators,
  })  : matchToPageStack =
            ((_, stateBuilder) => stateBuilder == null ? null : pageStack(stateBuilder)),
        matcher = WebEntryMatcher(path: '*'),
        translatorsHandlers = [
          TranslatorsHandler(translators: tab1Translators),
          TranslatorsHandler(translators: tab2Translators),
          TranslatorsHandler(translators: tab3Translators),
          TranslatorsHandler(translators: tab4Translators),
          TranslatorsHandler(translators: tab5Translators),
          TranslatorsHandler(translators: tab6Translators),
        ],
        pageStackToWebEntry = _defaultRouteToWebEntry;

  /// {@macro srouter.multi_tab_translators.parse}
  Multi6TabsTranslator.parse({
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
    required List<STranslator<SElement, Tab1In<Multi6TabsPageStack>>> tab1Translators,
    required List<STranslator<SElement, Tab2In<Multi6TabsPageStack>>> tab2Translators,
    required List<STranslator<SElement, Tab3In<Multi6TabsPageStack>>> tab3Translators,
    required List<STranslator<SElement, Tab4In<Multi6TabsPageStack>>> tab4Translators,
    required List<STranslator<SElement, Tab5In<Multi6TabsPageStack>>> tab5Translators,
    required List<STranslator<SElement, Tab6In<Multi6TabsPageStack>>> tab6Translators,
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
          TranslatorsHandler(translators: tab6Translators),
        ];

  @override
  final PS? Function(WebEntryMatch match, StateBuilder<Multi6TabsState>? stateBuilder)
      matchToPageStack;

  @override
  final WebEntryMatcher matcher;

  @override
  final WebEntry Function(
    PS pageStack,
    Multi6TabsState state,
    WebEntry? activeTabWebEntry,
  ) pageStackToWebEntry;

  @override
  final List<TranslatorsHandler> translatorsHandlers;

  static WebEntry _defaultRouteToWebEntry(
    Multi6TabsPageStack pageStack,
    Multi6TabsState state,
    WebEntry? activeTabWebEntry,
  ) {
    if (activeTabWebEntry == null) {
      throw UnknownPageStackError(pageStack: pageStack);
    }

    return activeTabWebEntry;
  }

  @override
  @nonVirtual
  Multi6TabsState buildFromMultiTabState(
    int activeIndex,
    IList<PageStackBase> pageStacks,
  ) {
    return Multi6TabsState(
      activeIndex: activeIndex,
      tab1PageStack: pageStacks[0] as Tab1In<Multi6TabsPageStack>,
      tab2PageStack: pageStacks[1] as Tab2In<Multi6TabsPageStack>,
      tab3PageStack: pageStacks[2] as Tab3In<Multi6TabsPageStack>,
      tab4PageStack: pageStacks[3] as Tab4In<Multi6TabsPageStack>,
      tab5PageStack: pageStacks[4] as Tab5In<Multi6TabsPageStack>,
      tab6PageStack: pageStacks[5] as Tab6In<Multi6TabsPageStack>,
    );
  }
}
