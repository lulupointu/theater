import 'package:flutter/widgets.dart';

import '../../browser/web_entry.dart';
import '../../routes/framework.dart';
import '../../routes/s_nested.dart';
import '../../s_router/s_router.dart';
import '../s_route_translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// A translator which can be used to redirect from a [path] to a [SRoute]
class SRedirectorTranslator<N extends MaybeSNested> extends SRouteTranslator<SRouteBase<N>, N> {
  /// Redirect a static [WebEntry] to a [SRoute]
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
  /// SRedirectorTranslator(path: '*', route: HomeSRoute())
  /// ```
  ///
  ///
  /// See also:
  ///   - [SRedirectorTranslator.parse] for a way to match dynamic path (e.g. '/user/:id')
  SRedirectorTranslator({
    required String path,
    required SRouteBase<N> route,
    this.replace = true,
  })  : _matcher = WebEntryMatcher(path: path),
        matchToRoute = ((_, __) => route);

  /// Converts a [WebEntry] to a [SRoute] to redirect to, by parsing dynamic
  /// element of the [WebEntry] (such as path parameters, query parameters, ...)
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToRoute] is called when the current path matches [path], and must
  /// return a [SRoute] which will then be used to create the new [WebEntry].
  /// Use the given match object to access the different parameters of the
  /// matched path. See example bellow.
  ///
  ///
  /// # Example:
  /// ```dart
  /// SRedirectorTranslator.parse(
  ///   path: '/user/:id',
  ///   matchToRoute: (match) => UserSRoute(id: match.pathParams['id']),
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
  SRedirectorTranslator.parse({
    required String path,
    required this.matchToRoute,
    this.replace = true,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,
  }) : _matcher = WebEntryMatcher(
          path: path,
          validatePathParams: validatePathParams,
          validateQueryParams: validateQueryParams,
          validateFragment: validateFragment,
          validateHistoryState: validateHistoryState,
        );

  /// The [SRoute] to redirect to
  final SRouteBase<N> Function(BuildContext context, WebEntryMatch match)
      matchToRoute;

  /// Whether the path we navigate to should replace the current history entry
  ///
  ///
  /// Defaults to true
  final bool replace;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  @override
  SRouteBase<N>? webEntryToSRoute(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    // If the web entry does not match, return null
    if (match == null) {
      return null;
    }


    // We can redirect the route even if the url is not right since after
    // [webEntryToSRoute] [sRouteToWebEntry] is always called, meaning that
    // [match] will be converted into the right url
    return matchToRoute(context, match);
  }

  /// We must override the [routeType] so that this translator is never matched
  /// when trying to convert a [SRoute] to a [WebEntry]
  @override
  Type get routeType => Null;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, SRouteBase route) {
    throw 'This should never be called';
  }
}
