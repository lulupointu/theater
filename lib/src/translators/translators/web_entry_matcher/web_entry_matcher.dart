import '../../../browser/web_entry.dart';
import 'path_to_regexp/path_to_regexp.dart';
import 'web_entry_match.dart';

/// Describes which [WebEntry] are match
///
///
/// See [path], [validatePathParams], [validateQueryParams], [validateHistoryState]
/// and [validateFragment] for how the different attributes try to match a given
/// [WebEntry]
class WebEntryMatcher {
  /// Tries to match [WebEntry.path]
  ///
  ///
  /// Path parameters and wildcards can be used
  /// |     pattern 	  |           matched path            | [Matcher.pathParams]
  /// | /user           | /user                             | {}
  /// | /user/:username | /user/evan                        | { username: 'evan' }
  /// | *               | every path                        | { *: yourPath }
  /// | /user/*         | every path starting with '/user/' | { *: yourPathAfter/user/ }
  ///
  ///
  /// If null, every [WebEntry.path] will be considered valid
  final String? path;

  /// Validate the path parameters gathered from the [path]
  ///
  ///
  /// If null, every path parameters will be considered valid
  final bool Function(Map<String, String> pathParams)? validatePathParams;

  /// A callback which, given [WebEntry.queryParams], should return true
  /// if they are considered valid, false otherwise
  ///
  ///
  /// If null, every [WebEntry.queryParams] will be considered valid
  final bool Function(Map<String, String> queryParams)? validateQueryParams;

  /// A callback which, given [WebEntry.historyState], should return true if
  /// it is considered valid, false otherwise
  ///
  ///
  /// If null, every [WebEntry.historyState] will be considered valid
  final bool Function(Map<String, String> historyState)? validateHistoryState;

  /// A callback which, given [WebEntry.fragment], should return true if it is
  /// considered valid, false otherwise
  ///
  ///
  /// If null, every [WebEntry.fragment] will be considered valid
  final bool Function(String fragment)? validateFragment;

  /// [path] should always start with '/'. If not, it will be added
  /// automatically
  WebEntryMatcher({
    String path = '*',
    this.validatePathParams,
    this.validateQueryParams,
    this.validateHistoryState,
    this.validateFragment,
  }) : path = path.startsWith('/')
            ? path
            : '/$path'; // If the path does not start with a '/', add it

  /// A regexp representation of [path] which makes it easy to match urls and
  /// extract path parameters
  late final RegExp pathRegExp = pathToRegExp(
    replaceWildcards(path ?? '*'),
    pathParamsNames,
  );

  /// The names of the path parameters, extracted from [path] using [pathToRegExp]
  final List<String> pathParamsNames = [];

  /// Check if the given [WebEntry] is matched based on the attributes of this
  /// [WebEntryMatcher]
  ///
  ///
  /// Returns the associated [WebEntryMatch] is there is a match, which as been
  /// populated with the path parameters if any
  ///
  /// Returns [null] is there is no match
  ///
  ///
  /// See [path], [validatePathParams], [validateQueryParams], [validateHistoryState]
  /// and [validateFragment] for how the different attributes try to match a given
  /// [WebEntry]
  WebEntryMatch? match(WebEntry webEntry) {
    final pathMatch = pathRegExp.firstMatch(webEntry.path);

    // If no exact match (or no match at all), this does not match the
    // given [WebEntry]
    if (pathMatch == null) {
      return null;
    }

    final pathParams = extract(pathParamsNames, pathMatch);

    // If any of the parameter is not valid, return null
    if (!(validatePathParams?.call(pathParams) ?? true) ||
        !(validateQueryParams?.call(webEntry.queryParams) ?? true) ||
        !(validateFragment?.call(webEntry.fragment) ?? true) ||
        !(validateHistoryState?.call(webEntry.historyState) ?? true)) {
      return null;
    }

    return WebEntryMatch(webEntry: webEntry, pathParams: pathParams);
  }
}
