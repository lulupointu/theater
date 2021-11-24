import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A class representing what is contained in a history
/// entry
///
///
/// TODO: Add easy copyWith
@immutable
class WebEntry extends Equatable {
  /// The path component
  ///
  /// The path is the actual substring of the URI representing the path,
  /// and should be encoded. To get direct access to the decoded path use
  /// [pathSegments].
  ///
  /// The path value is the empty string if there is no path component.
  String get path => _uri.path;

  /// The URI path split into its segments.
  ///
  /// Each of the segments in the list have been decoded.
  /// If the path is empty the empty list will
  /// be returned. A leading slash `/` does not affect the segments returned.
  ///
  /// The list is unmodifiable and will throw [UnsupportedError] on any
  /// calls that would mutate it.
  List<String> get pathSegments => _uri.pathSegments;

  /// The fragment identifier component.
  ///
  /// The value is the empty string if there is no fragment identifier
  /// component.
  String get fragment => _uri.fragment;

  /// The URI query split into a map according to the rules
  /// specified for FORM post in the [HTML 4.01 specification section
  /// 17.13.4](http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4 "HTML 4.01 section 17.13.4").
  ///
  /// Each key and value in the resulting map has been decoded.
  /// If there is no query the empty map is returned.
  ///
  /// Keys in the query string that have no value are mapped to the
  /// empty string.
  /// If a key occurs more than once in the query string, it is mapped to
  /// an arbitrary choice of possible value.
  /// The [queryParamsAll] getter can provide a map
  /// that maps keys to all of their values.
  ///
  /// The map is unmodifiable.
  Map<String, String> get queryParams => _uri.queryParameters;

  /// The history state
  final Map<String, String> historyState;

  /// The title of the history entry
  ///
  ///
  /// In a browser, this will change the tab title (except if this is null, in
  /// which case the url will be left the browser's defaults)
  ///
  ///
  /// Defaults to the [path]
  late final String title;

  /// [path] should always start with '/'. If not, it will be added
  /// automatically
  ///
  /// The [historyState] is optional and will default to an empty map
  ///
  /// [title] is optional and will default to the path
  WebEntry({
    String? path,
    List<String>? pathSegments,
    Map<String, String>? queryParams,
    String? fragment,
    this.historyState = const {},
    String? title,
  }) : _uri = Uri(
          path: (path?.startsWith('/') ?? true)
              ? path
              : '/$path', // If the path does not start with a '/', add it
          pathSegments: pathSegments,
          queryParameters: queryParams,
          fragment: fragment,
        ) {
    this.title = title ?? (this.path.startsWith('/') ? this.path : '/${this.path}');
  }

  /// The uri represents the url
  ///
  /// The historyState is not mandatory and will default to
  /// an empty map
  WebEntry.fromUri({
    required Uri uri,
    this.historyState = const {},
    String? title,
  }) : _uri = uri {
    this.title = title ?? (path.startsWith('/') ? path : '/$path');
  }

  /// An Uri representing the different components of the url
  ///
  ///
  /// This is used to easily validate the given parameters
  final Uri _uri;

  @override
  List<Object?> get props => [
        path,
        pathSegments,
        queryParams,
        fragment,
        historyState,
      ];

  @override
  String toString() {
    return 'WebEntry(path: $path, queryParams: $queryParams, fragment: $fragment, historyState: $historyState)';
  }
}
