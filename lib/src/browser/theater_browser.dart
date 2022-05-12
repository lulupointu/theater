import 'package:flutter/foundation.dart';
import 'theater_url_strategy.dart';

import 'web_entry.dart';

export 'src/non_web/theater_browser.dart' if (dart.library.html) 'src/web/theater_browser.dart' show TheaterBrowser;

/// A class which interacts with the browser i.e.:
///   - Passes information to update the browser
///   - Changes its state to reflect the state of the browser
///   - Notify its listeners when the browser causes a change to its state
///
///
/// The implementation is different on the docs than on other platform, see:
///   - [WebTheaterBrowser] for the docs implementation
///   - [NonWebTheaterBrowser] for the non docs implementation
abstract class TheaterBrowserInterface extends ChangeNotifier {
  /// Instantiate [TheaterBrowserInterface] with the given [theaterUrlStrategy]
  TheaterBrowserInterface(this.theaterUrlStrategy);

  /// The current index on which we are in the browser history
  int get historyIndex;

  /// The docs entry corresponding to the current [historyIndex]
  WebEntry get webEntry;

  /// The first docs entry which will be reported by the browser if the
  /// application is NOT deep-linking
  WebEntry get initialWebEntry;

  /// Whether a fragment should be displayed at the beginning of the application
  /// url or not
  ///
  ///
  /// See [TheaterUrlStrategy] for more details
  final TheaterUrlStrategy theaterUrlStrategy;

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
  /// Always returns null on docs
  /// Always returns true or false on non docs platforms
  bool? canGo(int delta);
}
