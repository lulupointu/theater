import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../../s_browser.dart';
import '../../s_url_strategy.dart';
import '../../web_entry.dart';

/// A web implementation of [SBrowserInterface]
///
///
/// It report new web entries to the browser and update itself if the browser
/// reports a new route
class SBrowser extends SBrowserInterface {
  /// Prevent direct instantiation;
  SBrowser._({required this.sUrlStrategy}) {
    _onBrowserUpdateListener = html.window.onPopState.listen((_) {
      notifyListeners();
    });

    final _webEntry = webEntry;
    if (!_webEntry.path.startsWith('/')) {
      _pushOrReplaceToBrowser(
        isReplacement: true,
        webEntry: WebEntry(
          path: '/${_webEntry.path}',
          queryParams: _webEntry.queryParams,
          fragment: _webEntry.fragment,
          historyState: _webEntry.historyState,
        ),
      );
    }
  }

  /// Whether a fragment should be displayed at the beginning of the application
  /// url or not
  ///
  ///
  /// See [SUrlStrategy] for more details
  final SUrlStrategy sUrlStrategy;

  /// This information is impossible to have on the web platform due for
  /// security reasons
  @override
  bool? canGo(int delta) => null;

  @override
  void go(int delta) => html.window.history.go(delta);

  @override
  int get historyIndex => html.window.history.state?['historyIndex'] ?? 0;

  @override
  void push(WebEntry webEntry) => _pushOrReplaceToBrowser(
        webEntry: webEntry,
        isReplacement: false,
      );

  @override
  void replace(WebEntry webEntry) => _pushOrReplaceToBrowser(
        webEntry: webEntry,
        isReplacement: true,
      );

  /// Pushes or replaces an history entry in the browser
  void _pushOrReplaceToBrowser({
    required bool isReplacement,
    required WebEntry webEntry,
  }) {
    // Either push or replace depending on [isReplacement]
    final historyMethod =
        isReplacement ? html.window.history.replaceState : html.window.history.pushState;

    final url = Uri(
      path: webEntry.path,
      queryParameters: webEntry.queryParams.isEmpty ? null : webEntry.queryParams,
      fragment: webEntry.fragment.isEmpty ? null : webEntry.fragment,
    ).toString();

    historyMethod(
      _wrapHistoryState(historyState: webEntry.historyState, title: webEntry.title),
      webEntry.title, // This is not actually used by browsers apart from Safari
      _getBasePath() +
          ((sUrlStrategy == SUrlStrategy.hash) ? '#/' : '') +
          (url.startsWith('/') ? url.substring(1) : url),
    );

    // Not sure this will always work because [window.history.replaceState] and
    // [window.history.pushState] are asynchronous (this is why we have 2 calls)
    //
    // However, this is has good as we can do since [html.window.onPopState] is
    // only called when interacting directly with the browser (so NOT when
    // calling [window.history.replaceState] or [window.history.pushState])
    //
    // [webNavigation.onHistoryStateUpdated] seems promising but:
    //   1. Safari does not implement it
    //   2. Dart does not make it accessible through the dart:html package
    //
    // Using [_setTabTitle] mitigate the issue by using the title that has
    // previously been stored in the history state (see [_wrapHistoryState]).
    // This means that even if this is called before the browser updates, at
    // least the title will not be incoherent
    _setTabTitle();
    Future.delayed(Duration(milliseconds: 100), _setTabTitle);
  }

  @override
  WebEntry get webEntry => _getCurrentWebEntry(sUrlStrategy: sUrlStrategy);

  @override
  WebEntry get initialWebEntry => WebEntry(path: '/');

  /// Wraps the history state in a Map which should be used in [push] and
  /// [replace]
  ///
  ///
  /// Do NOT set the historyState without wrapping it !
  ///
  ///
  /// We need to set the title in the history state because we cannot push it
  /// at the same time time as the history entry and instead push it when the
  /// browser tab is changed (on [html.window.onPopState])
  Map<String, dynamic> _wrapHistoryState({
    required Map<String, String> historyState,
    required String title,
  }) {
    return {
      'historyIndex': historyIndex,
      'title': title,
      'historyState': historyState,
    };
  }

  /// Get the current web entry by takings the url and the history state from
  /// the browser
  static WebEntry _getCurrentWebEntry({required SUrlStrategy sUrlStrategy}) {
    final uri = Uri.parse(_getAppUrl(sUrlStrategy: sUrlStrategy));

    final historyState = _getHistoryState();

    return WebEntry.fromUri(uri: uri, historyState: historyState, title: _getTabTitle());
  }

  /// Get the history state
  static Map<String, String> _getHistoryState() {
    return (html.window.history.state?['historyState'] as Map?)?.cast<String, String>() ?? {};
  }

  /// Returns the title of the current browser tab
  static String? _getTabTitle() => html.window.history.state?['title'];

  /// Sets the title of the current browser tab based on the value put in the
  /// history state during the push. See [_wrapHistoryState]
  static void _setTabTitle() {
    final title = _getTabTitle();
    if (title != null) html.document.title = title;
  }

  /// Gets the url specific to the app:
  /// protocol + '//' + host + "uri from the first <base> tag" + appUrl
  ///                                                              ^
  ///                                                    This is what we fetch
  static String _getAppUrl({required SUrlStrategy sUrlStrategy}) {
    // If the mode is fragment, it's easy we just take whatever is after the fragment
    if (sUrlStrategy == SUrlStrategy.hash) {
      return html.window.location.hash.isEmpty ? '' : html.window.location.hash.substring(1);
    }

    // else, we have to be careful with the basePath

    // Get the entire url (http...)
    final entireUrl = _getEntireUrl();

    // Remove the basePath
    final basePath = _getBasePath();
    final pathAndQuery =
        (basePath.length < entireUrl.length) // This might happen during first app startup
            ? entireUrl.substring(basePath.length)
            : '';

    return pathAndQuery.startsWith('/') ? pathAndQuery : '/$pathAndQuery';
  }

  /// Returns the base path (ending with a '/')
  ///
  /// The base path is:
  ///   protocol + '//' + host + "uri from the first <base> tag"
  static String _getBasePath() {
    final baseTags = html.document.getElementsByTagName('base');

    return baseTags.isEmpty ? '/' : (baseTags[0].baseUri ?? '/');
  }

  /// Returns the entire url
  static String _getEntireUrl() => html.window.location.href;

  /// A subscription to the browser updates
  ///
  ///
  /// We keep a reference so that we can cancel the subscription in [dispose]
  late final StreamSubscription<html.PopStateEvent> _onBrowserUpdateListener;

  @override
  void dispose() {
    _onBrowserUpdateListener.cancel();
    super.dispose();
  }

  /// The current (and unique) instance of [SBrowser]
  static SBrowserInterface? _instance;

  /// Gets the current (and unique) instance of [SBrowser]
  ///
  ///
  /// DO make sure that you called [initialize] before
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
  /// This must only be called once
  static void initialize({required SUrlStrategy sUrlStrategy}) {
    if (_instance != null) {
      throw 'initialize can only be called once';
    }

    // Remote url handling from flutter
    setUrlStrategy(null);

    _instance = SBrowser._(sUrlStrategy: sUrlStrategy);
  }
}
