import 'package:flutter/foundation.dart';

import '../../../browser/web_entry.dart';
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
  String get path => webEntry.path;

  /// See [WebEntry.pathSegments]
  List<String> get pathSegments => webEntry.pathSegments;

  /// See [WebEntry.fragment]
  String get fragment => webEntry.fragment;

  /// See [WebEntry.queryParams]
  Map<String, String> get queryParams => webEntry.queryParams;

  /// See [WebEntry.historyState]
  Map<String, String> get historyState => webEntry.historyState;

  /// The uri represents the url
  ///
  /// The historyState is not mandatory and will default to
  /// an empty map
  const WebEntryMatch({
    required this. webEntry,
    required this.pathParams,
  });

  /// The [WebEntry] that was given to [WebEntryMatcher.match] when this
  /// [WebEntryMatch] was returned
  final WebEntry webEntry;
}
