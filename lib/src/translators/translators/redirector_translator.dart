import 'package:flutter/widgets.dart';

import '../../browser/web_entry.dart';
import '../../page_stack/framework.dart';
import '../../s_router/s_router.dart';
import '../page_stack_translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// A translator which can be used to redirect from a [path] to a [PageStack]
class RedirectorTranslator extends PageStackTranslator<PageStackBase> {
  /// Redirect a static [WebEntry] to a [PageStack]
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted but cannot be used to create the [route].
  ///
  /// [route] is the [PageStack] of the associated [PageStack] type that will be used
  /// in [SRouter] if the path patches the given one
  ///
  ///
  /// # Example
  /// ```dart
  /// SRedirectorTranslator(path: '*', pageStack: HomeSPageStack())
  /// ```
  ///
  ///
  /// See also:
  ///   - [SRedirectorTranslator.parse] for a way to match dynamic path (e.g. '/user/:id')
  RedirectorTranslator({
    required String path,
    required PageStackBase pageStack,
    this.replace = true,
  })  : _matcher = WebEntryMatcher(path: path),
        matchToPageStack = ((_, __) => pageStack);

  /// Converts a [WebEntry] to a [PageStack] to redirect to, by parsing dynamic
  /// element of the [WebEntry] (such as path parameters, query parameters, ...)
  ///
  ///
  /// [path] describes the path that should be matched. Wildcards and path
  /// parameters are accepted
  ///
  /// [matchToPageStack] is called when the current path matches [path], and must
  /// return a [PageStack] which will then be used to create the new [WebEntry].
  /// Use the given match object to access the different parameters of the
  /// matched path. See example bellow.
  ///
  ///
  /// # Example:
  /// ```dart
  /// SRedirectorTranslator.parse(
  ///   path: '/user/:id',
  ///   matchToPageStack: (match) => UserSPageStack(id: match.pathParams['id']),
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
  RedirectorTranslator.parse({
    required String path,
    required this.matchToPageStack,
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

  /// The [PageStack] to redirect to
  final PageStackBase Function(BuildContext context, WebEntryMatch match)
      matchToPageStack;

  /// Whether the path we navigate to should replace the current history entry
  ///
  ///
  /// Defaults to true
  final bool replace;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  @override
  PageStackBase? webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    // If the web entry does not match, return null
    if (match == null) {
      return null;
    }


    // We can redirect the pageStack even if the url is not right since after
    // [webEntryToSPageStack] [sPageStackToWebEntry] is always called, meaning that
    // [match] will be converted into the right url
    return matchToPageStack(context, match);
  }

  /// We must override the [pageStackType] so that this translator is never matched
  /// when trying to convert a [PageStack] to a [WebEntry]
  @override
  Type get pageStackType => Null;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, PageStackBase route) {
    throw 'This should never be called';
  }
}
