import 'package:flutter/widgets.dart';

import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// An implementation of [STranslator] which makes
/// it easy determine if a [WebEntry] matches
class SPathTranslator<Route extends SRouteInterface<P>, P extends MaybeSPushable>
    extends STranslator<Route, P> {
  // TODO: add doc
  SPathTranslator({
    required String? path,
    required this.matchToRoute,
    required WebEntry Function(Route route) routeToWebEntry,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,
  })  : _routeToWebEntry = routeToWebEntry,
        _matcher = WebEntryMatcher(
          path: path,
          validatePathParams: validatePathParams,
          validateQueryParams: validateQueryParams,
          validateFragment: validateFragment,
          validateHistoryState: validateHistoryState,
        ),
        routeType = Route;

  // TODO: add doc
  SPathTranslator.static({
    required String path,
    required Route route,
    String? title,
  })  : _routeToWebEntry = ((_) => WebEntry(path: path, title: title)),
        matchToRoute = ((_) => route),
        _matcher = WebEntryMatcher(path: path),
        routeType = Route;

  @override
  final Type routeType;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  /// A callback used to convert a [WebEntryMatch] (which is basically
  /// a [WebEntry] with the parsed path parameters) to a [SRoute]
  final Route Function(WebEntryMatch match) matchToRoute;

  @override
  Route? webEntryToRoute(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    return matchToRoute(match);
  }

  /// Converts the associated [SRoute] into a string representing
  /// the url
  final WebEntry Function(Route route) _routeToWebEntry;

  @override
  WebEntry routeToWebEntry(BuildContext context, Route route) => _routeToWebEntry(route);
}
