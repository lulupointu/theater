import 'package:flutter/foundation.dart';

import '../web_entry/web_entry.dart';

export 'implementations/non_web/s_browser.dart' if (dart.library.html) 'implementations/web/s_browser.dart' show SBrowser;

/// A class which interacts with the browser i.e.:
///   - Passes information to update the browser
///   - Changes its state to reflect the state of the browser
///   - Notify its listeners when the browser causes a change to its state
///
///
/// The implementation is different on the web than on other platform, see:
///   - [WebSBrowser] for the web implementation
///   - [NonWebSBrowser] for the non web implementation
abstract class SBrowserInterface extends ChangeNotifier {
  /// The current index on which we are in the browser history
  int get historyIndex;

  /// The web entry corresponding to the current [historyIndex]
  WebEntry get webEntry;

  /// The first web entry which will be reported by the browser if the
  /// application is NOT deep-linking
  WebEntry get initialWebEntry;

  /// Pushes a new history entry
  void push(WebEntry webEntry);

  /// Replaces the current history entry
  void replace(WebEntry webEntry);

  /// Modifies the history index of [delta]
  ///
  ///
  /// Throws an exception if this is not possible
  void go(int delta);

  /// Whether it is possible to ask the browser to change the history index
  /// of [delta]
  ///
  ///
  /// Always returns null on web
  /// Always returns true or false on non web platforms
  bool? canGo(int delta);
}
