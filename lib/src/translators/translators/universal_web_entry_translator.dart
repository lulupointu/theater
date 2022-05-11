import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../../browser/theater_browser.dart';
import '../../browser/web_entry.dart';
import '../../page_stack/framework.dart';
import '../../theater/history_entry.dart';
import '../../theater/theater.dart';
import '../page_stack_translator.dart';
import '../translator.dart';

/// This [Translator] will
///   - match any [WebEntry] and make it correspond to the current
///   ^ [PageStack]
///   - match any [PageStack] and make it correspond to the current
///   ^ [WebEntry]
///
///
/// This should be used on mobile at the bottom of the [translator] so that if
/// a [Theater] navigates somewhere, the response of other [Theater]s will be
/// to re-render the same route
class UniversalNonWebTranslator extends PageStackTranslator<PageStackBase> {
  /// This is a trick to please our assert which checks that the generic type
  /// of [Translator] is available at runtime
  ///
  /// You should never have to do this
  @override
  Type get pageStackType => dynamic;

  /// The initial [PageStack] to display when the [Theater] is initialized
  final PageStackBase initialPageStack;

  /// The history of the [TheaterState] associating history indexes to
  /// [HistoryEntry]
  final IMap<int, HistoryEntry> history;

  // ignore: public_member_api_docs
  UniversalNonWebTranslator({required this.initialPageStack, required this.history});

  @override
  WebEntry sRouteToWebEntry(BuildContext context, PageStackBase route) {
    // Use TheaterBrowser directly because the currentWebEntry may not be
    // set at this point
    return TheaterBrowser.instance.webEntry;
  }

  @override
  PageStackBase webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final currentHistoryIndex = TheaterBrowser.instance.historyIndex;

    // Try to return the current route
    final currentRoute = history[currentHistoryIndex]?.pageStack;
    if (currentRoute != null) return currentRoute;

    // If the current route is null, try to return the previous route
    // This is needed because if nested Theater push a route, this
    // will be triggered but won't have had the chance to populate
    // its route as it would it it had itself been called
    final previousRoute = history[currentHistoryIndex - 1]?.pageStack;
    if (previousRoute != null) return previousRoute;

    // Else return the initial route since if both previous value
    // are null, this means that this Theater has just been inserted
    // in the widget tree
    return initialPageStack;
  }
}
