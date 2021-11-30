import 'package:flutter/widgets.dart';

import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// An implementation of [STranslator] which makes it easy determine if a
/// [WebEntry] is matched
class SPathTranslator<Route extends SRouteInterface<P>, P extends MaybeSPushable>
    extends STranslator<Route, P> {
  /// Converts a static [WebEntry] into a [SRoute]
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted but cannot be used to create the [route].
  ///
  /// [route] is the [SRoute] of the associated [Route] type that will be used
  /// in [SRouter] if the path patches the given one
  ///
  ///
  /// # Example
  /// ```dart
  /// SPathTranslator<UserSRoute, SPushable>(
  ///   path: '/user',
  ///   route: UserSRoute(),
  /// )
  /// ```
  ///
  ///
  /// See also:
  ///   - [SPathTranslator.parse] for a way to match dynamic path (e.g. '/user/:id')
  SPathTranslator({
    required String path,
    required Route route,
    String? title,
  })  : _routeToWebEntry = ((_) => WebEntry(path: path, title: title)),
        matchToRoute = ((_) => route),
        _matcher = WebEntryMatcher(path: path),
        routeType = Route;

  /// Converts a [WebEntry] to a [SRoute] and vise versa, by parsing dynamic
  /// element of the [WebEntry] (such as path parameters, query parameters, ...)
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToRoute] is called when the current path matches [path], and must
  /// return a [SRoute] of the associated [Route] type.
  /// Use the given match object to access the different parameters of the
  /// matched path. See example bellow.
  ///
  /// [routeToWebEntry] converts the [SRoute] of the associated [Route] type to
  /// a [WebEntry] (i.e. a representation of the url)
  ///
  ///
  /// # Example:
  /// ```dart
  /// SPathTranslator<UserSRoute, SPushable>.parse(
  ///   path: '/user/:id',
  ///   matchToRoute: (match) => UserSRoute(id: match.pathParams['id']),
  ///   routeToWebEntry: (route) => WebEntry(pathSegments: ['user', route.id]),
  /// )
  /// ```
  ///
  ///
  /// [validatePathParams], [validateQueryParams], [validateFragment] and
  /// [validateHistoryState] are optional parameters and can be used to further
  /// precise which [WebEntry] to match
  ///
  ///
  /// See also:
  ///   - [WebEntry] for the different parameters which can be used to form a url
  ///   - [WebEntryMatcher.path] for a precise description of how [path] can be used
  SPathTranslator.parse({
    required String path,
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

  /// A callback used to convert a [WebEntryMatch] (which is basically
  /// a [WebEntry] with the parsed path parameters) to a [SRoute]
  final Route Function(WebEntryMatch match) matchToRoute;

  @override
  Route? webEntryToSRoute(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    return matchToRoute(match);
  }

  @override
  final Type routeType;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  /// Converts the associated [SRoute] into a string representing
  /// the url
  final WebEntry Function(Route route) _routeToWebEntry;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, Route route) => _routeToWebEntry(route);
}
