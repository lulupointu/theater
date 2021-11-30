import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../../browser/s_browser.dart';
import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../s_router/s_history_entry.dart';
import '../../s_router/s_router.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';

/// This [STranslator] will
///   - match any [WebEntry] and make it correspond to the current
///   ^ [SRoute]
///   - match any [SRoute] and make it correspond to the current
///   ^ [WebEntry]
///
///
/// This should be used on mobile at the bottom of the [translator] so that if
/// a [SRouter] navigates somewhere, the response of other [SRouter]s will be
/// to re-render the same route
class UniversalNonWebTranslator extends STranslator<SRouteInterface<SPushable>, SPushable> {
  /// This is a trick to please our assert which checks that the generic type
  /// of [STranslator] is available at runtime
  ///
  /// You should never have to do this
  @override
  Type get routeType => dynamic;

  /// The initial [SRoute] to display when the [SRouter] is initialized
  final SRouteInterface<SPushable> initialRoute;

  /// The history of the [SRouterState] associating history indexes to
  /// [SHistoryEntry]
  final IMap<int, SHistoryEntry> history;

  // ignore: public_member_api_docs
  UniversalNonWebTranslator({required this.initialRoute, required this.history});

  @override
  WebEntry sRouteToWebEntry(BuildContext context, SRouteInterface<SPushable> route) {
    // Use SBrowser directly because the currentWebEntry may not be
    // set at this point
    return SBrowser.instance.webEntry;
  }

  @override
  SRouteInterface<SPushable> webEntryToSRoute(BuildContext context, WebEntry webEntry) {
    final currentHistoryIndex = SBrowser.instance.historyIndex;

    // Try to return the current route
    final currentRoute = history[currentHistoryIndex]?.route;
    if (currentRoute != null) return currentRoute;

    // If the current route is null, try to return the previous route
    // This is needed because if nested SRouter push a route, this
    // will be triggered but won't have had the chance to populate
    // its route as it would it it had itself been called
    final previousRoute = history[currentHistoryIndex - 1]?.route;
    if (previousRoute != null) return previousRoute;

    // Else return the initial route since if both previous value
    // are null, this means that this SRouter has just been inserted
    // in the widget tree
    return initialRoute;
  }
}
