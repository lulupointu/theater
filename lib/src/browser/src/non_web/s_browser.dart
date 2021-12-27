import 'dart:ui';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

import '../../s_browser.dart';
import '../../s_url_strategy.dart';
import '../../web_entry.dart';

/// A non web implementation of [SBrowserInterface]
///
///
/// It basically does nothing apart from keeping track of the history
/// length and index since it does not need to interact with the system
class SBrowser extends SBrowserInterface {
  /// Prevent direct instantiation;
  SBrowser._({required SUrlStrategy sUrlStrategy})
      : _webEntries = [
          WebEntry.fromUri(uri: Uri.parse(PlatformDispatcher.instance.defaultRouteName)),
        ].lock,
        super(sUrlStrategy);

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

  /// The list of all the web entries
  IList<WebEntry> _webEntries;

  @override
  void push(WebEntry webEntry) {
    // Increment the [_historyIndex]
    ++_historyIndex;

    // Add the web entry to the web entry and remove any web entry that came
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
      canGo(delta)!, // Can't be true on non-web browser
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

  /// The current (and unique) instance of [SBrowser]
  static SBrowserInterface? _instance;

  /// Gets the current (and unique) instance of [SBrowser]
  ///
  ///
  /// DO make sure that you called [maybeInitialize] before
  static SBrowserInterface get instance {
    if (_instance == null) {
      throw AssertionError('''
Tried to get [SBrowser.instance] but [SBrowser] has never been initialized. 
You must call [SBrowser.initialize] before using [SBrowser.instance]
''');
    }

    return _instance!;
  }

  /// Creates the unique instance of this class
  ///
  ///
  /// If an instance has already been created, does nothing
  static void maybeInitialize({required SUrlStrategy sUrlStrategy}) {
    if (_instance == null) {
      _instance = SBrowser._(sUrlStrategy: sUrlStrategy);
    } else {
      assert(
        sUrlStrategy == _instance!.sUrlStrategy,
        '[SBrowser] was first initialized with the [SUrlStrategy] '
        '"${_instance!.sUrlStrategy}" and is now trying to be initialized with '
        '"$sUrlStrategy".\n'
        'You must always use the same [SUrlStrategy]',
      );
    }
  }

  /// Reset this singleton instance
  ///
  ///
  /// Only useful when testing
  @visibleForTesting
  static void reset() {
    if (_instance != null) {
      _instance = SBrowser._(sUrlStrategy: _instance!.sUrlStrategy);
    }
  }
}
