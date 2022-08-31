import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';

import '../back_button_listener_scope/back_button_listener_scope.dart';
import '../browser/theater_browser.dart';
import '../browser/theater_url_strategy.dart';
import '../browser/web_entry.dart';
import '../navigator/theater_navigator.dart';
import '../page_stack/framework.dart';
import '../page_transitions/no_transition_page.dart';
import '../translators/translator.dart';
import '../translators/translators/universal_web_entry_translator.dart';
import '../translators/translators_handler.dart';
import 'history_entry.dart';
import 'theater_interface.dart';

/// A widget which assembles the different part of the package to
/// create the greatest routing experience of your life ;)
///
/// This class is an interface between [Navigator] and [TheaterBrowserInterface].
/// [TheaterBrowserInterface] must never be handled directly, always use [Theater]
///
/// The responsibility of this class is to exposed the current [HistoryEntry]
/// which should be displayed
///
///
/// The state of this class (used to navigate) can be accessed using
/// [Theater.of] or [content.theater]
class Theater extends StatelessWidget {
  /// {@template theater.theater.constructor}
  ///
  /// The [initialPageStack] describes the first [PageStack] to be shown before
  /// any navigation has taken place
  ///
  /// [translatorsBuilder] are optional but must be given to support the docs
  /// platform, otherwise [Theater] can't turn the url into [PageStack]s
  ///
  /// [key] can be useful if you need to use [to] and friends without
  /// a [BuildContext]. In which case you would create
  /// [routerKey = GlobalKey<TheaterState>] and use it to access the [Theater]
  /// methods using [routerKey.currentState.to]
  ///
  /// [navigatorKey] is often useful if you need the overlay associated with
  /// the created navigator.
  /// You could get it using [navigatorKey.currentState.overlay]
  ///
  /// {@endtemplate}
  ///
  ///
  /// PREFER using [Theater.build]
  const Theater({
    Key? key,
    required this.initialPageStack,
    this.translatorsBuilder,
    this.defaultPageBuilder = _defaultPageBuilder,
    this.builder,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.disableSendAppToBackground = false,
    this.disableUniversalTranslator = false,
  })  : assert(!kIsWeb || translatorsBuilder != null, '''
You must define [translators] when you are on the docs, otherwise Theater can't know which [PageStack] correspond to which url
'''),
        _theaterKey = key is GlobalKey<TheaterState> ? key : null,
        // Don't set the key if it is a GlobalKey<TheaterState> since it will be
        // pass to the child _Theater widget
        super(key: key is GlobalKey<TheaterState> ? null : key);

  /// The initial [PageStack] to display
  ///
  ///
  /// This will be ignored if we are deep-linking
  final PageStackBase initialPageStack;

  /// The list of [Translator]s which will be used to convert a docs
  /// to a [PageStack] and vise versa
  ///
  ///
  /// WARNING: In the given context, [Theater.of(context).currentHistoryEntry]
  /// might be null since the conversion from page stack to docs entry or vise
  /// versa is not done
  final List<Translator<PageElement, PageStackBase>> Function(
    BuildContext context,
  )? translatorsBuilder;

  /// The default builder which will be used if [PageStack] does not implement
  /// buildPage. Use it to create default page transition for every page at
  /// the same time.
  ///
  /// You should use [pageStack.key] as your page key instead you have a good
  /// reason not to
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   home: Theater(
  ///     initialPageStack: LogInPageStack(),
  ///     defaultPageBuilder: (context, pageStack, child) {
  ///       return PageBuilder(
  ///         child: child,
  ///         transitionsBuilder: (context, animation, _, child) {
  ///           // Create a fade transition when switching between pages
  ///           return FadeTransition(opacity: animation, child: child),
  ///         },
  ///       );
  ///     },
  ///   ),
  /// );
  /// ```
  ///
  ///
  /// Defaults to [_defaultPageBuilder]
  final Page Function(
    BuildContext context,
    PageStackWithPage pageStack,
    Widget child,
  ) defaultPageBuilder;

  /// A callback to build a widget around the [Navigator] created by this
  /// widget
  ///
  ///
  /// [Theater] will be accessible in the given context
  final Widget Function(BuildContext context, Widget child)? builder;

  /// The key of the navigator created by [Theater]
  ///
  ///
  /// We force it to be global since using a regular key would not be of any
  /// use to external users
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  /// When trying to pop the current [PageStack] and the [PageStack] does not
  /// have a [PageStack] bellow, the router will send the app to the background.
  /// You can set [disableUniversalTranslator] to true to disable this behavior
  ///
  ///
  /// In a nested [Theater], we never tries to put the app in the background so
  /// this attribute is useless
  ///
  ///
  /// This is only used on iOS and Android
  ///
  ///
  /// Defaults to false
  final bool disableSendAppToBackground;

  /// Whether [UniversalNonWebTranslator] should be used as a translator when
  /// the app is run on a different platform than the docs
  ///
  /// You may only want to turn this to [false] if your application supports
  /// both docs and non docs platform. This is not compulsory but makes it easier
  /// to debug missing [translatorsBuilder].
  ///
  ///
  /// On the docs, this has no effect
  ///
  /// Defaults to false
  final bool disableUniversalTranslator;

  /// A key to access the [Theater] state from anywhere
  ///
  /// This will be registered if the given [key] is of [GlobalKey<TheaterState>]
  /// type
  final GlobalKey<TheaterState>? _theaterKey;

  /// A method to access the [Theater] of the given [context]
  ///
  ///
  /// If [Theater] is not present is the given [context], throw an
  /// exception
  ///
  ///
  /// If [listen] is true, any change to [TheaterState] will cause a
  /// rebuild of the context which used this method
  ///
  /// If [ignoreSelf] is true, it won't return try to look at the
  /// [StatefulElement] associated with the [context] and only look at its
  /// parents
  ///
  /// If [findRoot] is true, it will try to find the root [TheaterState]
  /// (i.e. the one which is the highest in the widget tree, considering the
  /// current context)
  static TheaterInterface of(
    BuildContext context, {
    bool listen = false,
    bool ignoreSelf = false,
    bool findRoot = false,
  }) {
    final result = Theater.maybeOf(
      context,
      listen: listen,
      ignoreSelf: ignoreSelf,
      findRoot: findRoot,
    );
    assert(result != null, 'No Theater found in the given context');
    return result!;
  }

  /// A method to access the [Theater] of the given [context]
  ///
  ///
  /// If [Theater] is not present is the given [context], null is
  /// returned
  ///
  ///
  /// If [listen] is true, any change to [TheaterState] will cause a
  /// rebuild of the context which used this method
  ///
  /// If [ignoreSelf], it won't return try to look at the [StatefulElement] associated
  /// with the [context] and only look at its parents
  ///
  /// If [findRoot] is true, it will try to find the root [TheaterState]
  /// (i.e. the one which is the highest in the widget tree, considering the
  /// current context)
  static TheaterInterface? maybeOf(
    BuildContext context, {
    bool listen = false,
    bool ignoreSelf = false,
    bool findRoot = false,
  }) {
    assert(
      !(findRoot && ignoreSelf),
      'If your are trying to find the root element ([findRoot] is true), you'
      'cannot ignore this element ([ignoreSelf] is true) as this element might'
      'be the root element',
    );

    if (findRoot) {
      return _rootMaybeOf(context, listen: listen);
    }

    late final TheaterState? result;
    if (!ignoreSelf &&
        context is StatefulElement &&
        context.state is TheaterState) {
      result = context.state as TheaterState;
    } else if (listen) {
      result =
          context.dependOnInheritedWidgetOfExactType<_TheaterProvider>()?.state;
    } else {
      result = (context
              .getElementForInheritedWidgetOfExactType<_TheaterProvider>()
              ?.widget as _TheaterProvider?)
          ?.state;
    }
    return result;
  }

  /// A recurring function used to find the root element
  ///
  ///
  /// [ignoreSelf] should always be left to [false] when calling from an
  /// external method.
  /// It is used internally to ignore the state of the context during recursive
  /// calls
  static TheaterState? _rootMaybeOf(
    BuildContext context, {
    required bool listen,
  }) {
    final maybeCurrentElement =
        maybeOf(context, listen: false) as TheaterState?;

    // If there are no element in the given context, return null
    if (maybeCurrentElement == null) {
      return null;
    }

    var currentElement = maybeCurrentElement;
    var aboveElement = maybeOf(
      currentElement.context,
      listen: false,
      ignoreSelf: true,
    ) as TheaterState?;

    // Continue to go up the tree until there is no element in the context
    while (aboveElement != null) {
      currentElement = aboveElement;
      aboveElement = maybeOf(
        currentElement.context,
        listen: false,
        ignoreSelf: true,
      ) as TheaterState?;
    }

    // At this point, the [currentElement] contains the root element

    // We need to listen manually since we did not listen before
    if (listen) {
      final maybeInheritedElement = currentElement.context
          .getElementForInheritedWidgetOfExactType<_TheaterProvider>();

      // This can happen if the context used is the one of the root element, in
      // which can listening is not needed anyway
      if (maybeInheritedElement != null) {
        context.dependOnInheritedElement(maybeInheritedElement);
      }
    }

    return currentElement;
  }

  /// Resets the singleton used to internally represent the docs browser
  ///
  /// Only use this method for testing, usually in [setUp]
  /// ```dart
  /// setUp(() {
  ///   Theater.reset();
  /// })
  /// ```
  @visibleForTesting
  // ignore: invalid_use_of_visible_for_testing_member
  static void reset() => TheaterBrowser.reset();

  /// Initializes Theater
  ///
  /// IMPORTANT: On Flutter docs, this must be called before the url strategy is
  /// set by Flutter. Which means that you either need to put Theater in
  /// MaterialApp.build or use [Theater.ensureInitialized] in [runApp]
  ///
  /// [theaterUrlStrategy] is only used in Flutter docs to describe whether a
  /// hash (#) should be used at the beginning of your url path.
  /// Read the [TheaterUrlStrategy] class documentation for more details.
  static void ensureInitialized({
    TheaterUrlStrategy theaterUrlStrategy = TheaterUrlStrategy.hash,
  }) {
    TheaterBrowser.maybeInitialize(theaterUrlStrategy: theaterUrlStrategy);
  }

  /// {@template theater.framework.defaultPageBuilder}
  ///
  /// A default implementation of [buildPage] which returns a [Page]
  /// corresponding to the current platform:
  ///   - On iOS [CupertinoPage]
  ///   - On desktop [NoTransitionPage]
  ///   - On android [MaterialPage]
  ///
  /// If a non-null [key] has been given to the constructor, it will be used as
  /// the [Page]'s key
  /// If no [key] where given, the [runtimeType] will be used as the [Page]
  /// identifier instead
  ///
  ///
  /// You can override this implementation if you want to build a custom [Page].
  /// In which case [build] will not be used and a dummy implementation will
  /// suffice:
  /// `Widget build(BuildContext context) => Container();`
  ///
  /// {@endtemplate}
  static Page _defaultPageBuilder(
    BuildContext context,
    PageStackWithPage pageStack,
    Widget child,
  ) {
    final defaultKey = ValueKey(pageStack.key);

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return CupertinoPage(
          key: defaultKey,
          child: child,
        );
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
      case TargetPlatform.windows:
        return NoTransitionPage(
          key: defaultKey,
          child: child,
        );
      case TargetPlatform.android:
        return MaterialPage(
          key: defaultKey,
          child: child,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageBuilder(
      builder: defaultPageBuilder,
      child: _Theater(
        key: _theaterKey,
        initialPageStack: initialPageStack,
        translatorsBuilder: translatorsBuilder,
        builder: builder,
        navigatorKey: navigatorKey,
        navigatorObservers: navigatorObservers,
        disableSendAppToBackground: disableSendAppToBackground,
        disableUniversalTranslator: disableUniversalTranslator,
      ),
    );
  }
}

/// An intermediary widget needed so that [Theater] can inject widgets above
/// [TheaterState] context
class _Theater extends StatefulWidget {
  const _Theater({
    Key? key,
    required this.initialPageStack,
    required this.translatorsBuilder,
    required this.builder,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.disableSendAppToBackground,
    required this.disableUniversalTranslator,
  }) : super(key: key);

  /// See [Theater.initialPageStack]
  final PageStackBase initialPageStack;

  /// See [Theater.translatorsBuilder]
  final List<Translator<PageElement, PageStackBase>> Function(
      BuildContext context)? translatorsBuilder;

  /// See [Theater.builder]
  final Widget Function(BuildContext context, Widget child)? builder;

  /// See [Theater.navigatorKey]
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [Theater.navigatorObservers]
  final List<NavigatorObserver> navigatorObservers;

  /// See [Theater.disableSendAppToBackground]
  final bool disableSendAppToBackground;

  /// See [Theater.disableUniversalTranslator]
  final bool disableUniversalTranslator;

  @override
  State<_Theater> createState() => TheaterState();
}

/// The state for a [Theater] widget.
///
/// A reference to this class can be obtained by calling [Theater.of] or
/// [context.theater]
class TheaterState extends State<_Theater> implements TheaterInterface {
  /// The translator associated with the [Theater] with is used to
  /// convert a [WebEntry] to a [PageStack] and vise versa
  ///
  ///
  /// WARNING: In the given context, [Theater.of(context).currentHistoryEntry]
  /// might be null since the conversion from page stack to docs entry or vise
  /// versa is not done
  TranslatorsHandler get _translatorsHandler => TranslatorsHandler(
        translators: [
          ...widget.translatorsBuilder?.call(context) ?? [],

          // If on non-web platform and [widget.disableUniversalTranslator] is
          // not true, add [UniversalNonWebTranslator] as the magic translator
          //
          // We add it last so that it does not interfere with other potential
          // translators (since it matches all [WebEntry]s and all [PageStack]s)
          if (!kIsWeb && !widget.disableUniversalTranslator)
            UniversalNonWebTranslator(
              initialPageStack: widget.initialPageStack,
              history: history,
            ),
        ],
      );

  /// The interface representing the browser in which this application run
  late final TheaterBrowserInterface _theaterBrowser = TheaterBrowser.instance;

  /// Whether this [Theater] is nested in another one
  ///
  ///
  /// If this is the case, we will NOT listen to browser updates and instead
  /// get the [PageStack] associated with a new [WebEntry] only during
  /// [build]
  ///
  ///
  /// This is needed because a nested [Theater] might not be placed in
  /// the widget tree during the next build call. In which case it should NOT
  /// try to find the [PageStack] corresponding to the current [WebEntry]
  /// (which likely does NOT exists for this [Theater])
  ///
  /// However this is only possible in nested [Theater] because
  /// [TheaterBrowser] updates do NOT cause widget rebuild by itself, therefore if
  /// no parent [Theater] exist, this [Theater] will NOT be
  /// rebuilt upon [TheaterBrowser] updates
  late final bool _isNested =
      Theater.maybeOf(context, listen: false, ignoreSelf: true) != null;

  /// The history is a map between an history index and a
  /// [HistoryEntry]
  ///
  ///
  /// This is empty but the first value will be available as soon as the first
  /// [build] method
  IMap<int, HistoryEntry> _history = IMap();

  /// A getter of the [_history]
  IMap<int, HistoryEntry> get history => _history;

  /// An helper to get the current docs entry using [history] and the history
  /// index from [TheaterBrowserInterface]
  ///
  ///
  /// Watch out for edge cases:
  ///   - It can be null when [Theater] is first instantiated until the first
  ///   ^ call to. the translators happens. However this is guaranteed to have
  ///   ^ a value (i.e. NOT be null) during all [build] phases
  ///   - It will have an outdated value when a new [WebEntry] or a new page
  ///   ^ stack it pushed until the update happens.
  ///
  /// This is particularly important to keep in mind when implementing
  /// [Translator]s as using the context in [Translator.webEntryToPageStack] and
  /// [Translator.pageElementToWebEntry] to get this Theater will be in the
  /// in-between state described above
  HistoryEntry? _currentHistoryEntry;

  /// The getter of [_currentHistoryEntry]
  HistoryEntry? get currentHistoryEntry => _currentHistoryEntry;

  /// Whether the first [WebEntry] coming from the browser has been handled
  ///
  ///
  /// This is needed because the first url is handled differently since we have
  /// to use the [Theater.initialPageStack] (if we are not deep-linking)
  bool _initialUrlHandled = false;

  /// The [PageElement]s used to create the [Page]s
  ///
  ///
  /// It will be updated each time [to] is called
  IList<PageElement> _pageElements = IList();

  /// The [Page]s created from [_pageElements]
  ///
  /// This is updated during [build]
  IList<Page> pages = IList();

  /// Pushes a new entry with the given page stack
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void to(PageStackBase pageStack, {bool isReplacement = false}) {
    _pageElements = updatePageStackBasePageElements(
      context,
      oldPageElements: _pageElements,
      pageStack: pageStack,
      // Always true since this will be placed in the root [TheaterNavigator]
      isLastPageElementCurrent: true,
    );

    return _toPageElements(_pageElements, isReplacement: isReplacement);
  }

  /// Calls [to] on the current [PageStackBase]
  ///
  /// This should be called when a [PageElement] updates its state internally
  void update() {
    final _currentPageStack = currentHistoryEntry?.pageStack;
    assert(_currentPageStack != null,
        'Tried to update while no PageStack was ever created');

    to(_currentPageStack!);
  }

  /// Pushes a new entry with the given [pageElements]
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void _toPageElements(
    IList<PageElement> pageElements, {
    bool isReplacement = false,
  }) {
    final _toCallback =
        isReplacement ? _replaceHistoryEntry : _pushHistoryEntry;

    return _toCallback(
      HistoryEntry(
        webEntry: _translatorsHandler.getWebEntryFromPageElement(
                context, pageElements.last) ??
            (throw UnknownPageStackError(
              pageStack: pageElements.last.pageWidget.pageStack,
            )),
        pageStack: pageElements.last.pageWidget.pageStack,
      ),
    );
  }

  /// Pushes a new [WebEntry] which will eventually be converted in its
  /// corresponding [PageStack]
  ///
  ///
  /// DO prefer using [to] when possible
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void toWebEntry(WebEntry webEntry, {bool isReplacement = false}) {
    // We must call [to] instead of just calling [_theaterBrowser.push/replace]
    // because calling [_theaterBrowser.push/replace] will not cause
    // [_updateHistoryWithCurrentWebEntry] to be triggered since
    // [_theaterBrowser] only notify its listener when the browser changes its
    // state (contrary to when itself changes the state of the browser)
    return to(
      _translatorsHandler.getPageStackFromWebEntry(context, webEntry) ??
          (throw UnknownWebEntryError(webEntry: webEntry)),
      isReplacement: isReplacement,
    );
  }

  /// Pushes a new entry
  ///
  ///
  /// This will also push in the browser
  void _pushHistoryEntry(HistoryEntry historyEntry) {
    final newHistoryIndex = _theaterBrowser.historyIndex + 1;
    // Update the history by:
    //  - Adding the given [historyEntry] with a key corresponding to the next
    //    history index
    //  - Remote all key associated with [sHistoryEntries] which are after the
    //    next history index
    setState(() {
      _currentHistoryEntry = historyEntry;
      _history = history
          .add(newHistoryIndex, historyEntry)
          .removeWhere((key, value) => key > newHistoryIndex);
    });

    _theaterBrowser.push(historyEntry.webEntry);
  }

  /// Replaces the current entry
  ///
  ///
  /// This will also replace in the browser
  ///
  ///
  /// See "Optimization Remarks" to learn why we update [history] while we
  /// could simply react to [TheaterBrowserInterface] notifications
  void _replaceHistoryEntry(HistoryEntry historyEntry) {
    setState(() {
      _currentHistoryEntry = historyEntry;
      _history = history.add(_theaterBrowser.historyIndex, historyEntry);
    });

    _theaterBrowser.replace(historyEntry.webEntry);
  }

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
  /// [_updateHistoryWithCurrentWebEntry] when [TheaterBrowserInterface] will have
  /// processed this method and updated its current history index
  void go(int delta) => _theaterBrowser.go(delta);

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
  bool? canGo(int delta) => _theaterBrowser.canGo(delta);

  /// Converts the current [WebEntry] from [_theaterBrowser] to a [PageStack]
  ///
  ///
  /// This must be called when [_theaterBrowser] notify its listeners
  void _updateHistoryWithCurrentWebEntry() {
    // Grab the current webEntry using [TheaterBrowserInterface]
    final webEntry = _theaterBrowser.webEntry;

    // Grab the current history index
    final historyIndex = _theaterBrowser.historyIndex;

    // If [initialUrlHandled] is false and we are NOT deep-linking, report
    // the url with [widget.initialPageStack]
    if (!_initialUrlHandled) {
      _initialUrlHandled = true;

      if (webEntry == _theaterBrowser.initialWebEntry && historyIndex == 0) {
        return to(widget.initialPageStack, isReplacement: true);
      }
    }

    // Call replace with the webEntry instead of directly storing the
    // corresponding [HistoryEntry] because the title might need to be set and
    // this is only accessible by converting the page stack to a [WebEntry]
    toWebEntry(webEntry, isReplacement: true);
  }

  /// This function must end up removing the last page in the list of page_transitions
  /// given to [TheaterNavigator]
  void _onPop() {
    // At this point, we already know that there is a page bellow because
    // [TheaterNavigator] checked route.didPop
    final newPageStack =
        _pageElements[_pageElements.length - 2].pageWidget.pageStack;

    to(newPageStack);
  }

  /// This function handles a system pop by first passing the event to the top
  /// [PageElement]
  ///
  /// If the top [PageElement] did NOT handle the event, we handle it by:
  ///   - Either popping on the [PageStack] bellow if any
  ///   - Or putting the app in the background
  void _onSystemPop() {
    final result = _pageElements.last.onSystemPop(context);

    result.when(
      parent: () {
        // We don't know if a tab bellow exists, so use getOrNull
        final pageStackBellow = _pageElements
            .getOrNull(_pageElements.length - 2)
            ?.pageWidget
            .pageStack;

        if (pageStackBellow == null) {
          // If there is no [PageStack] bellow, move the app to the background
          if (!widget.disableSendAppToBackground) {
            MoveToBackground.moveTaskToBack();
          }
          return;
        }

        to(pageStackBellow);
      },
      done: () {
        // We navigate to the current [PageStack] since the changes where internal
        _pushHistoryEntry(
          HistoryEntry(
            webEntry: _translatorsHandler.getWebEntryFromPageElement(
                    context, _pageElements.last) ??
                (throw UnknownPageStackError(
                    pageStack: currentHistoryEntry!.pageStack)),
            pageStack: currentHistoryEntry!.pageStack,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // If we have not nested, initialize with the given [TheaterUrlStrategy]
    if (!_isNested) {
      try {
        // This fails when Flutter already called setUrlStrategy
        Theater.ensureInitialized();

        // ignore: avoid_catching_errors
      } on AssertionError {
        throw '''
On Flutter docs, you must either:
  - Use [Theater.ensureInitialized] in [runApp] 
  - Or put Theater in MaterialApp.build (or WidgetsApp.build)
''';
      }
    }

    // If we are nested, the update should only happen during the [build] phase
    // i.e. NOT during browser call
    //
    // We avoid the initialization as well since this would just be a duplicate
    // of the first build call
    if (!_isNested) {
      // Initialize [_history] by syncing it with [TheaterBrowserInterface]
      _updateHistoryWithCurrentWebEntry();

      _theaterBrowser.addListener(_updateHistoryWithCurrentWebEntry);
    }
  }

  @override
  void didUpdateWidget(covariant _Theater oldWidget) {
    // If we are nested, the update should only happen during the [build] phase
    if (!_isNested) {
      _theaterBrowser.removeListener(_updateHistoryWithCurrentWebEntry);
      _theaterBrowser.addListener(_updateHistoryWithCurrentWebEntry);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (!_isNested) {
      _theaterBrowser.removeListener(_updateHistoryWithCurrentWebEntry);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No need to update if we are NOT nested since this will be done on browser
    // update anyway
    if (_isNested) _updateHistoryWithCurrentWebEntry();

    return _TheaterProvider(
      state: this,
      currentHistoryEntry: currentHistoryEntry!,
      isNested: _isNested,
      child: BackButtonListenerScope(
        child: Builder(
          builder: (context) {
            final navigatorBuilder = TheaterNavigator.root(
              pageElements: _pageElements,
              navigatorKey: widget.navigatorKey,
              navigatorObservers: widget.navigatorObservers,
              onPop: _onPop,
              onSystemPop: _onSystemPop,
            );

            return widget.builder?.call(context, navigatorBuilder) ??
                navigatorBuilder;
          },
        ),
      ),
    );
  }
}

/// A provider which given efficient access to the nearest [Theater]
///
///
/// This will also cause the subscribed [BuildContext] to rebuild if [isNested]
/// of [currentHistoryEntry] are updated
class _TheaterProvider extends InheritedWidget {
  /// The current [HistoryEntry]
  final HistoryEntry currentHistoryEntry;

  /// Whether the associated [Theater] is nested in another one
  final bool isNested;

  /// The [TheaterState] that this [InheritedWidget] provides
  ///
  ///
  /// Do NOT use this in [updateShouldNotify] since this object will mutate
  /// (therefore its reference will be the same)
  final TheaterState state;

  const _TheaterProvider({
    Key? key,
    required Widget child,
    required this.state,
    required this.currentHistoryEntry,
    required this.isNested,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_TheaterProvider old) {
    return old.currentHistoryEntry != currentHistoryEntry ||
        old.isNested != isNested;
  }
}

/// An exception thrown when the given docs entry in
/// [TranslatorsHandler.getPageStackFromWebEntry] could not be matched by any
/// translator
class UnknownWebEntryError extends Error {
  /// The docs entry which could not be converted to a [PageStack]
  final WebEntry webEntry;

  // ignore: public_member_api_docs
  UnknownWebEntryError({required this.webEntry});

  @override
  String toString() => '''
The docs entry $webEntry could not be translated to a page stack.

If you are on the docs, did you forget to add the translator corresponding to the docs entry $webEntry ?

If you are NOT on the docs, this should never happen, please fill an issue.
''';
}

/// An exception thrown when the given [PageStackBase] in
/// [TranslatorsHandler.getPageStackFromWebEntry] could not be matched by any
/// translator
class UnknownPageStackError extends Error {
  /// The [PageStackBase] which could not be converted to an [WebEntry]
  final PageStackBase pageStack;

  // ignore: public_member_api_docs
  UnknownPageStackError({required this.pageStack});

  @override
  String toString() => '''
The [PageStack] of type "${pageStack.runtimeType}" could not be translated to a docs entry:
  - If you are on the docs, did you forget to add the translator corresponding to the [PageStack] of type "${pageStack.runtimeType}" ?
  - If you are NOT on the docs, this should never happen, please fill an issue.
''';
}
