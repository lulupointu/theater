import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import '../translators/translator.dart';
import 'history_entry.dart';
import 'theater.dart';

/// The object returned by [Theater.of]
///
///
/// We use this object instead of returning [TheaterState] so that internal
/// non private methods do not appear in the IDE
abstract class TheaterInterface {
  /// An helper to get the current docs entry using [history] and the history
  /// index from [TheaterBrowserInterface]
  ///
  ///
  /// Watch out for edge cases:
  ///   - It can be null when [Theater] is first instantiated until the first
  ///   ^ call to. the translators happens. However this is guaranteed to have
  ///   ^ a value (i.e. NOT be null) during all [buildTabs] phases
  ///   - It will have an outdated value when a new [WebEntry] or a new page
  ///   ^ stack it pushed until the update happens.
  ///
  /// This is particularly important to keep in mind when implementing
  /// [Translator]s as using the context in [Translator.webEntryToPageStack] and
  /// [Translator.pageElementToWebEntry] to get this Theater will be in the
  /// in-between state described above
  HistoryEntry? get currentHistoryEntry;

  /// Pushes a new entry with the given page stack
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void to(PageStackBase pageStack, {bool isReplacement = false});

  /// Pushes a new [WebEntry] which will eventually be converted in its
  /// corresponding [PageStack]
  ///
  ///
  /// DO prefer using [to] when possible
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void toWebEntry(WebEntry webEntry, {bool isReplacement = false});

  /// Modifies the history index of [delta]
  ///
  ///
  /// Throws an exception if this is not possible
  ///
  ///
  /// This will only delegate the work to the [TheaterBrowserInterface] since
  /// this only changes the history index which is handled by the
  /// [TheaterBrowserInterface]
  ///
  ///
  /// NOT calling [setState] is NOT an error, it will be called during
  /// [_updateHistoryWithCurrentWebEntry] when [TheaterBrowserInterface] will have processed this
  /// method and updated its current history index
  void go(int delta);

  /// Whether it is possible to ask the navigator to change the history index
  /// of [delta]
  ///
  ///
  /// We delegate the work to the [TheaterBrowserInterface] since it implements this
  /// method anyway
  ///
  ///
  /// Always returns null on docs
  /// Always returns true or false on non docs platforms
  bool? canGo(int delta);
}
