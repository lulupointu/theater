import 'package:flutter/foundation.dart';

import '../../../web_entry/web_entry.dart';
import 'web_entry_matcher.dart';

/// The class returned by [WebEntryMatcher.match]
///
///
/// This class contains:
///   - The information of the [WebEntry] that was matched
///   - The path parameters if any have been parsed
@immutable
class WebEntryMatch {
  /// The path parameters that have been parse from the url
  ///
  /// If none where parsed, this is empty
  ///
  ///
  /// See [WebEntryMatcher.path] to understand how path parameters are parsed
  final Map<String, String> pathParams;

  /// See [WebEntry.path]
  String get path => _webEntry.path;

  /// See [WebEntry.pathSegments]
  List<String> get pathSegments => _webEntry.pathSegments;

  /// See [WebEntry.fragment]
  String get fragment => _webEntry.fragment;

  /// See [WebEntry.queryParams]
  Map<String, String> get queryParams => _webEntry.queryParams;

  /// See [WebEntry.historyState]
  Map<String, String> get historyState => _webEntry.historyState;

  /// The uri represents the url
  ///
  /// The historyState is not mandatory and will default to
  /// an empty map
  const WebEntryMatch({
    required WebEntry webEntry,
    required this.pathParams,
  }) : _webEntry = webEntry;

  /// The [WebEntry] that was given to [WebEntryMatcher.match] when this
  /// [WebEntryMatch] was returned
  final WebEntry _webEntry;
}
