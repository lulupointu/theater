import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../../browser/s_browser.dart';
import '../../browser/web_entry.dart';
import '../../page_stack/framework.dart';
import '../../page_stack/nested_stack.dart';
import '../../s_router/history_entry.dart';
import '../../s_router/s_router.dart';
import '../page_stack_translator.dart';
import '../translator.dart';

/// This [STranslator] will
///   - match any [WebEntry] and make it correspond to the current
///   ^ [PageStack]
///   - match any [PageStack] and make it correspond to the current
///   ^ [WebEntry]
///
///
/// This should be used on mobile at the bottom of the [translator] so that if
/// a [SRouter] navigates somewhere, the response of other [SRouter]s will be
/// to re-render the same route
class UniversalNonWebTranslator extends PageStackTranslator<PageStackBase<NonNestedStack>, NonNestedStack> {
  /// This is a trick to please our assert which checks that the generic type
  /// of [STranslator] is available at runtime
  ///
  /// You should never have to do this
  @override
  Type get routeType => dynamic;

  /// The initial [PageStack] to display when the [SRouter] is initialized
  final PageStackBase<NonNestedStack> initialPageStack;

  /// The history of the [SRouterState] associating history indexes to
  /// [HistoryEntry]
  final IMap<int, HistoryEntry> history;

  // ignore: public_member_api_docs
  UniversalNonWebTranslator({required this.initialPageStack, required this.history});

  @override
  WebEntry sRouteToWebEntry(BuildContext context, PageStackBase<NonNestedStack> route) {
    // Use SBrowser directly because the currentWebEntry may not be
    // set at this point
    return SBrowser.instance.webEntry;
  }

  @override
  PageStackBase<NonNestedStack> webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final currentHistoryIndex = SBrowser.instance.historyIndex;

    // Try to return the current route
    final currentRoute = history[currentHistoryIndex]?.pageStack;
    if (currentRoute != null) return currentRoute;

    // If the current route is null, try to return the previous route
    // This is needed because if nested SRouter push a route, this
    // will be triggered but won't have had the chance to populate
    // its route as it would it it had itself been called
    final previousRoute = history[currentHistoryIndex - 1]?.pageStack;
    if (previousRoute != null) return previousRoute;

    // Else return the initial route since if both previous value
    // are null, this means that this SRouter has just been inserted
    // in the widget tree
    return initialPageStack;
  }
}
