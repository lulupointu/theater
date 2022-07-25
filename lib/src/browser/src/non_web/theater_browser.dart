import 'dart:ui';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

import '../../theater_browser.dart';
import '../../theater_url_strategy.dart';
import '../../web_entry.dart';

/// A non docs implementation of [TheaterBrowserInterface]
///
///
/// It basically does nothing apart from keeping track of the history
/// length and index since it does not need to interact with the system
class TheaterBrowser extends TheaterBrowserInterface {
  /// Prevent direct instantiation;
  TheaterBrowser._({required TheaterUrlStrategy theaterUrlStrategy})
      : _webEntries = [
        // TODO: use WidgetObserver to listen to pushRoutes while the app is running
          WebEntry.fromUri(uri: Uri.parse(PlatformDispatcher.instance.defaultRouteName)),
        ].lock,
        super(theaterUrlStrategy);

  @override
  int get historyIndex => _historyIndex;

  @override
  WebEntry get webEntry => _webEntries[historyIndex];

  @override
  WebEntry get initialWebEntry => WebEntry(path: '/');

  /// The current index of the history
  ///
  ///
  /// The first index is 0
  int _historyIndex = 0;

  /// The list of all the docs entries
  IList<WebEntry> _webEntries;

  @override
  void push(WebEntry webEntry) {
    // Increment the [_historyIndex]
    ++_historyIndex;

    // Add the docs entry to the docs entry and remove any docs entry that came
    // after it
    _webEntries = _webEntries.sublist(0, _historyIndex).add(webEntry);
  }

  @override
  void replace(WebEntry webEntry) {
    _webEntries = _webEntries.replace(_historyIndex, webEntry);
  }

  @override
  void go(int delta) {
    assert(
      canGo(delta)!, // Can't be null on non-docs browser
      '''
[go] was called with delta=$delta but this is not possible considering the current browser state.

Use [canGo($delta)] to check if it is actually possible to change the history index of $delta.
''',
    );

    _historyIndex += delta;

    notifyListeners();
  }

  @override
  bool? canGo(int delta) {
    final newHistoryIndex = _historyIndex + delta;

    return 0 <= newHistoryIndex && newHistoryIndex < _webEntries.length;
  }

  /// The current (and unique) instance of [TheaterBrowser]
  static TheaterBrowserInterface? _instance;

  /// Gets the current (and unique) instance of [TheaterBrowser]
  ///
  ///
  /// DO make sure that you called [maybeInitialize] before
  static TheaterBrowserInterface get instance {
    if (_instance == null) {
      throw AssertionError('''
Tried to get [TheaterBrowser.instance] but [TheaterBrowser] has never been initialized. 
You must call [TheaterBrowser.initialize] before using [TheaterBrowser.instance]
''');
    }

    return _instance!;
  }

  /// Creates the unique instance of this class
  ///
  ///
  /// If an instance has already been created, does nothing
  static void maybeInitialize({required TheaterUrlStrategy theaterUrlStrategy}) {
    if (_instance == null) {
      _instance = TheaterBrowser._(theaterUrlStrategy: theaterUrlStrategy);
    }
  }

  /// Reset this singleton instance
  ///
  ///
  /// Only useful when testing
  @visibleForTesting
  static void reset() {
    if (_instance != null) {
      _instance = TheaterBrowser._(theaterUrlStrategy: _instance!.theaterUrlStrategy);
    }
  }
}
