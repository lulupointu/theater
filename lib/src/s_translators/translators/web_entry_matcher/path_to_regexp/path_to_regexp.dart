/// Functions which imitate the path_to_regexp package
/// (https://pub.dev/packages/path_to_regexp) by which
/// the following is heavily inspired
///
///
/// The reason we implement this rather than depending on path_to_regexp
/// in to enable wildcards (*), which path_to_regexp does not

/// The pattern as defined by VRouter
final _inputPattern =
/* :anything or :* */ RegExp(r':(\w+|\*(?=\())'
/* RegExp in (), optional */ r'(\((?:\\.|[^\\()])+\))?');

/// The real regexp to replace a path parameter which does not specify
/// its path parameter
final _defaultOutputPattern = r'([^/]+?)'; // everything except "/"

/// [pathParams] will be populated with the path parameters
/// of the given [path]
RegExp pathToRegExp(
  String path,
  List<String> pathParams,
) {
  final matches = _inputPattern.allMatches(path);

  // A list of the names of the path parameters
  pathParams.clear();
  pathParams.addAll([for (var match in matches) match.group(1)!]);

  var newPath = StringBuffer(r'^');
  RegExpMatch? previousMatch;
  for (var match in matches) {
    newPath.write(
      RegExp.escape(
        path.substring(previousMatch?.end ?? 0, match.start),
      ),
    );
    final regExpPattern = match.group(2);
    newPath.write(regExpPattern != null
        ? escapeGroup(regExpPattern)
        : _defaultOutputPattern);
    previousMatch = match;
  }
  newPath.write(path.substring(previousMatch?.end ?? 0));
  newPath.write(r'(?=$)');

  return RegExp(newPath.toString());
}

/// Extract the [parameters] from the [match]
///
/// [parameters] can be obtained in place using [pathToRegExp]
Map<String, String> extract(List<String> parameters, Match match) => {
      for (var i = 0; i < parameters.length; ++i)
        parameters[i]: match.group(i + 1)!,
      // Offset by 1 since 0 is the entire match
    };

/// Replaces wildcards by value that are understood by [pathToRegExp]
String replaceWildcards(String path) {
  // A wildcard contained in the path
  final inPathWildcardRegexp = RegExp(r'\*(?![^\(]*\))(?=.)');

  // A wildcard contained at the end of the path
  final trailingWildcardRegexp = RegExp(r'\*(?![^\(]*\))$');

  return path
      .replaceAll(inPathWildcardRegexp, r':*([^\/]*)')
      .replaceAll(trailingWildcardRegexp, r':*(.*)');
}

/// Matches any characters that could prevent a group from capturing.
final _groupRegExp = RegExp(r'[:=!]');

/// Escapes a single character [match].
String _escape(Match match) => '\\${match[0]}';

/// Escapes a [group] to ensure it remains a capturing group.
///
/// This prevents turning the group into a non-capturing group `(?:...)`, a
/// lookahead `(?=...)`, or a negative lookahead `(?!...)`. Allowing these
/// patterns would break the assumption used to map parameter names to match
/// groups.
String escapeGroup(String group) =>
    group.replaceFirstMapped(_groupRegExp, _escape);
