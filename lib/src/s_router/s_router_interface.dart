import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import '../page_stack/nested_stack.dart';
import '../translators/translator.dart';
import 'history_entry.dart';
import 's_router.dart';

/// The object returned by [SRouter.of]
///
///
/// We use this object instead of returning [SRouterState] so that internal
/// non private methods do not appear in the IDE
abstract class SRouterInterface {
  /// An helper to get the current web entry using [history] and the history
  /// index from [SBrowserInterface]
  ///
  ///
  /// Watch out for edge cases:
  ///   - It can be null when [SRouter] is first instantiated until the first
  ///   ^ call to. the translators happens. However this is guaranteed to have
  ///   ^ a value (i.e. NOT be null) during all [buildTabs] phases
  ///   - It will have an outdated value when a new [WebEntry] or a new page
  ///   ^ stack it pushed until the update happens.
  ///
  /// This is particularly important to keep in mind when implementing
  /// [STranslator]s as using the context in [STranslator.webEntryToPageStack] and
  /// [STranslator.sElementToWebEntry] to get this SRouter will be in the
  /// in-between state described above
  HistoryEntry? get currentHistoryEntry;

  /// Pushes a new entry with the given page stack
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void to(PageStackBase<NonNestedStack> pageStack, {bool isReplacement = false});

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
  /// This will only delegate the work to the [SBrowserInterface] since
  /// this only changes the history index which is handled by the
  /// [SBrowserInterface]
  ///
  ///
  /// NOT calling [setState] is NOT an error, it will be called during
  /// [_updateHistoryWithCurrentWebEntry] when [SBrowserInterface] will have processed this
  /// method and updated its current history index
  void go(int delta);

  /// Whether it is possible to ask the navigator to change the history index
  /// of [delta]
  ///
  ///
  /// We delegate the work to the [SBrowserInterface] since it implements this
  /// method anyway
  ///
  ///
  /// Always returns null on web
  /// Always returns true or false on non web platforms
  bool? canGo(int delta);
}
