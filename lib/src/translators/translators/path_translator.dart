import 'package:flutter/widgets.dart';

import '../../browser/web_entry.dart';
import '../../page_stack/framework.dart';
import '../page_stack_translator.dart';
import '../translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// An implementation of [STranslator] which makes it easy determine if a
/// [WebEntry] is matched
class PathTranslator<PS extends PageStackBase> extends PageStackTranslator<PS> {
  /// Converts a static [WebEntry] into a [PageStack]
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted but cannot be used to create the [pageStack].
  ///
  /// [pageStack] is the [PageStack] of the associated [PS] type that will be used
  /// in [SRouter] if the path patches the given one
  ///
  ///
  /// ### Example
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
  PathTranslator({
    required String path,
    required PS pageStack,
    String? title,
  })  : pageStackToWebEntry = ((_) => WebEntry(path: path, title: title)),
        matchToPageStack = ((_) => pageStack),
        _matcher = WebEntryMatcher(path: path);

  /// Converts a [WebEntry] to a [PageStack] and vise versa, by parsing dynamic
  /// element of the [WebEntry] (such as path parameters, query parameters, ...)
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToPageStack] is called when the current path matches [path], and must
  /// return a [PageStack] of the associated [PS] type.
  /// Use the given match object to access the different parameters of the
  /// matched path. See example bellow.
  ///
  /// [pageStackToWebEntry] converts the [PageStack] of the associated [PS] type to
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
  PathTranslator.parse({
    required String path,
    required this.matchToPageStack,
    required this.pageStackToWebEntry,

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

  /// A callback used to convert a [WebEntryMatch] (which is basically
  /// a [WebEntry] with the parsed path parameters) to a [PageStack]
  final PS Function(WebEntryMatch match) matchToPageStack;

  @override
  PS? webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    return matchToPageStack(match);
  }

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  /// Converts the associated [PageStack] into a string representing
  /// the url
  final WebEntry Function(PS pageStack) pageStackToWebEntry;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, PS route) => pageStackToWebEntry(route);
}
