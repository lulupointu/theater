import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:move_to_background/move_to_background.dart';

import '../back_button_listener_scope/back_button_listener_scope.dart';
import '../browser/s_browser.dart';
import '../browser/web_entry.dart';
import '../flutter_navigator_builder/root_flutter_navigator_builder.dart';
import '../routes/framework.dart';
import '../routes/s_nested.dart';
import '../s_translators/s_translator.dart';
import '../s_translators/s_translators_handler.dart';
import '../s_translators/translators/universal_web_entry_translator.dart';
import 's_history_entry.dart';
import 's_router_interface.dart';

/// A widget which assembles the different part of the package to
/// create the greatest routing experience of your life
///
/// This class is an interface between [Navigator] and [SBrowserInterface].
/// [SBrowserInterface] must never be handled directly, always use [SRouter]
///
/// The responsibility of this class is to exposed the current [SHistoryEntry]
/// which should be displayed
///
///
/// The state of this class (using for push and Co) can be accessed using
/// [SRouter.of] or [content.sRouter]
class SRouter extends StatefulWidget {
  /// The [initialRoute] is required but can be null on the web since it won't
  /// be used. It has to be non-null on other platform.
  ///
  /// [translatorsBuilder] are optional but must be given to support the web platform,
  /// otherwise [SRouter] can't turn the url into [SRoute]s
  ///
  /// [key] can be useful if you need to use [to] and friends without
  /// a [BuildContext]. In which case you would create
  /// [routerKey = GlobalKey<SRouterState>] and use it to access the [SRouter]
  /// methods using [routerKey.currentState.push]
  ///
  /// [navigatorKey] is often only useful if you need the overlay associated
  /// with the created navigator.
  SRouter({
    Key? key,
    required this.initialRoute,
    this.translatorsBuilder,
    this.builder,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.disableSendAppToBackground = false,
    this.disableUniversalTranslator = false,
  })  : assert(!kIsWeb || translatorsBuilder != null, '''
You must define [translators] when you are on the web, otherwise SRouter can't know which [SRoute] correspond to which url
'''),
        super(key: key) {
    _debugCheckSRouteInitialized();
  }

  /// Checks that [initializeSRouter] has been called
  static void _debugCheckSRouteInitialized() {
    assert(
      () {
        try {
          SBrowser.instance;
          // ignore: avoid_catching_errors, we catch it to display a better error message so it's ok
        } on AssertionError catch (_) {
          print('''\x1B[31m
[initializeSRouter] was not called, please call it in app.dart:

```
main() {
  initializeSRouter();

  runApp(MyApp());
}
```
```
\x1B[0m''');
          return false;
        }

        return true;
      }(),
      '''
[initializeSRouter] was not called, please call it in app.dart:

```
main() {
  initializeSRouter();

  runApp(MyApp());
}
```
''',
    );
  }

  /// The list of [STranslator]s which will be used to convert a web
  /// to a [SRoute] and vise versa
  ///
  ///
  /// WARNING: In the given context, [SRouter.of(context).currentHistoryEntry]
  /// might be null since the conversion from route to web entry or vise versa
  /// is not done
  final List<STranslator<SElement<NotSNested>, SRouteBase<NotSNested>, NotSNested>> Function(
      BuildContext context)? translatorsBuilder;

  /// The initial [SRoute] to display
  ///
  ///
  /// This will be ignored if we are deep-linking
  final SRouteBase<NotSNested> initialRoute;

  /// A callback to build a widget around the [Navigator] created by this
  /// widget
  ///
  ///
  /// [SRouter] will be accessible in the given context
  final Widget Function(BuildContext context, Widget child)? builder;

  /// The key of the navigator
  ///
  ///
  /// We force it to be global since using a regular key would not be of any
  /// use to external users
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  /// When the current route [onPop] or [onBack] is called and their return
  /// value indicate that the event should be handled by the router, the router
  /// will send the app to the background.
  /// You can set [disableUniversalTranslator] to true to disable this behavior
  ///
  /// By default, such an event occurs when the current route doesn't have an
  /// sRouteBellow
  ///
  ///
  /// In a nested [SRouter], we never tries to put the app in the background so
  /// this attribute is useless
  ///
  ///
  /// This is only used on iOS and Android
  ///
  ///
  /// Defaults to false
  final bool disableSendAppToBackground;

  /// Whether [UniversalNonWebTranslator] should be used as a translator when
  /// the app is run on a different platform than the web
  ///
  /// You may only want to turn this to [false] if your application supports
  /// both web and non web platform. This is not compulsory but makes it easier
  /// to debug missing [translatorsBuilder].
  ///
  ///
  /// On the web, this has no effect
  ///
  /// Defaults to false
  final bool disableUniversalTranslator;

  @override
  State<SRouter> createState() => SRouterState();

  /// A method to access the [SRouter] of the given [context]
  ///
  ///
  /// If [SRouter] is not present is the given [context], throw an
  /// exception
  ///
  ///
  /// If [listen] is true, any change to [SRouterState] will cause a
  /// rebuild of the context which used this method
  ///
  /// If [ignoreSelf] is true, it won't return try to look at the
  /// [StatefulElement] associated with the [context] and only look at its
  /// parents
  ///
  /// If [findRoot] is true, it will try to find the root [SRouterState]
  /// (i.e. the one which is the highest in the widget tree, considering the
  /// current context)
  static SRouterInterface of(
    BuildContext context, {
    bool listen = false,
    bool ignoreSelf = false,
    bool findRoot = false,
  }) {
    final result = SRouter.maybeOf(
      context,
      listen: listen,
      ignoreSelf: ignoreSelf,
      findRoot: findRoot,
    );
    assert(result != null, 'No SRouter found in the given context');
    return result!;
  }

  /// A method to access the [SRouter] of the given [context]
  ///
  ///
  /// If [SRouter] is not present is the given [context], null is
  /// returned
  ///
  ///
  /// If [listen] is true, any change to [SRouterState] will cause a
  /// rebuild of the context which used this method
  ///
  /// If [ignoreSelf], it won't return try to look at the [StatefulElement] associated
  /// with the [context] and only look at its parents
  ///
  /// If [findRoot] is true, it will try to find the root [SRouterState]
  /// (i.e. the one which is the highest in the widget tree, considering the
  /// current context)
  static SRouterInterface? maybeOf(
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

    late final SRouterState? result;
    if (!ignoreSelf && context is StatefulElement && context.state is SRouterState) {
      result = context.state as SRouterState;
    } else if (listen) {
      result = context.dependOnInheritedWidgetOfExactType<_SRouterProvider>()?.state;
    } else {
      result = (context.getElementForInheritedWidgetOfExactType<_SRouterProvider>()?.widget
              as _SRouterProvider?)
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
  static SRouterState? _rootMaybeOf(
    BuildContext context, {
    required bool listen,
  }) {
    final maybeCurrentElement = maybeOf(context, listen: false) as SRouterState?;

    // If there are no element in the given context, return null
    if (maybeCurrentElement == null) {
      return null;
    }

    var currentElement = maybeCurrentElement;
    var aboveElement = maybeOf(
      currentElement.context,
      listen: false,
      ignoreSelf: true,
    ) as SRouterState?;

    // Continue to go up the tree until there is no element in the context
    while (aboveElement != null) {
      currentElement = aboveElement;
      aboveElement = maybeOf(
        currentElement.context,
        listen: false,
        ignoreSelf: true,
      ) as SRouterState?;
    }

    // At this point, the [currentElement] contains the root element

    // We need to listen manually since we did not listen before
    if (listen) {
      final maybeInheritedElement =
          currentElement.context.getElementForInheritedWidgetOfExactType<_SRouterProvider>();

      // This can happen if the context used is the one of the root element, in
      // which can listening is not needed anyway
      if (maybeInheritedElement != null) {
        context.dependOnInheritedElement(maybeInheritedElement);
      }
    }

    return currentElement;
  }
}

/// The state for a [SRouter] widget.
///
/// A reference to this class can be obtained by calling [SRouter.of] or
/// [context.sRouter]
class SRouterState extends State<SRouter> implements SRouterInterface {
  /// The translator associated with the [SRouter] with is used to
  /// convert a [WebEntry] to a [SRoute] and vise versa
  ///
  ///
  /// WARNING: In the given context, [SRouter.of(context).currentHistoryEntry]
  /// might be null since the conversion from route to web entry or vise versa
  /// is not done
  STranslatorsHandler<NotSNested> get _translatorsHandler => STranslatorsHandler(
        translators: [
          ...widget.translatorsBuilder?.call(context) ?? [],

          // If on non-web platform and [widget.disableUniversalTranslator] is
          // not true, add [UniversalNonWebTranslator] as the magic translator
          //
          // We add it last so that it does not interfere with other potential
          // translators (since it matches all [WebEntry]s and all [SRoute]s)
          if (!kIsWeb && !widget.disableUniversalTranslator)
            UniversalNonWebTranslator(
              initialRoute: widget.initialRoute,
              history: history,
            ),
        ],
      );

  /// The interface representing the browser in which this application run
  final SBrowserInterface _sBrowser = SBrowser.instance;

  /// Whether this [SRouter] is nested in another one
  ///
  ///
  /// If this is the case, we will NOT listen to browser updates and instead
  /// get the [SRoute] associated with a new [WebEntry] only during
  /// [build]
  ///
  ///
  /// This is needed because a nested [SRouter] might not be placed in
  /// the widget tree during the next build call. In which case it should NOT
  /// try to find the [SRoute] corresponding to the current [WebEntry]
  /// (which likely does NOT exists for this [SRouter])
  ///
  /// However this is only possible in nested [SRouter] because
  /// [SBrowser] updates do NOT cause widget rebuild by itself, therefore if
  /// no parent [SRouter] exist, this [SRouter] will NOT be
  /// rebuilt upon [SBrowser] updates
  late final bool _isNested =
      SRouter.maybeOf(context, listen: false, ignoreSelf: true) != null;

  /// The history is a map between an history index and a
  /// [SHistoryEntry]
  ///
  ///
  /// This is empty but the first value will be available as soon as the first
  /// [build] method
  IMap<int, SHistoryEntry> _history = IMap();

  /// A getter of the [_history]
  IMap<int, SHistoryEntry> get history => _history;

  /// An helper to get the current web entry using [history] and the history
  /// index from [SBrowserInterface]
  ///
  ///
  /// Watch out for edge cases:
  ///   - It can be null when [SRouter] is first instantiated until the first
  ///   ^ call to. the translators happens. However this is guaranteed to have
  ///   ^ a value (i.e. NOT be null) during all [build] phases
  ///   - It will have an outdated value when a new [WebEntry] or a new route
  ///   ^ it pushed until the update happens.
  ///
  /// This is particularly important to keep in mind when implementing
  /// [STranslator]s as using the context in [STranslator.webEntryToSRoute] and
  /// [STranslator.sRouteToWebEntry] to get this SRouter will be in the
  /// in-between state described above
  SHistoryEntry? _currentHistoryEntry;

  /// The getter of [_currentHistoryEntry]
  SHistoryEntry? get currentHistoryEntry => _currentHistoryEntry;

  /// Whether the first [WebEntry] coming from the browser has been handled
  ///
  ///
  /// This is needed because the first url is handled differently since we have
  /// to use the [widget.initialRoute] (if we are not deep-linking)
  bool _initialUrlHandled = false;

  /// The [SElement]s used to create the [Page]s
  ///
  ///
  /// It will be updated each time [to] is called
  IList<SElement<NotSNested>> _sElements = IList();

  /// Pushes a new entry with the given route
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void to(SRouteBase<NotSNested> route, {bool isReplacement = false}) {
    _sElements = updateSRouteBaseSElements(
      context,
      oldSElements: _sElements,
      sRouteBase: route,
    );

    final _toCallback = isReplacement ? _replaceSHistoryEntry : _pushSHistoryEntry;

    return _toCallback(
      SHistoryEntry(
        webEntry: _translatorsHandler.getWebEntryFromSElement(context, _sElements.last) ??
            (throw UnknownSRouteError(sRoute: route)),
        route: route,
      ),
    );
  }

  /// Pushes a new [WebEntry] which will eventually be converted in its
  /// corresponding [SRoute]
  ///
  ///
  /// DO prefer using [to] when possible
  ///
  ///
  /// Set [isReplacement] to true if you want the current history entry to
  /// be replaced by the newly created one
  void toWebEntry(WebEntry webEntry, {bool isReplacement = false}) {
    final _toCallback = isReplacement ? _replaceSHistoryEntry : _pushSHistoryEntry;

    // We must call [_toCallback] instead of just calling [_sBrowser.push]
    // because calling [_sBrowser.replace] will not cause
    // [_updateHistoryWithCurrentWebEntry] to be triggered since
    // [_sBrowser.push] only notify its listener when the browser changes its
    // state (contrary to when itself changes the state of the browser)
    return _toCallback(
      SHistoryEntry(
        webEntry: webEntry,
        route: _translatorsHandler.getRouteFromWebEntry(context, webEntry) ??
            (throw UnknownWebEntryError(webEntry: webEntry)),
      ),
    );
  }

  /// Pushes a new entry
  ///
  ///
  /// This will also push in the browser
  void _pushSHistoryEntry(SHistoryEntry sHistoryEntry) {
    final newHistoryIndex = _sBrowser.historyIndex + 1;
    // Update the history by:
    //  - Adding the given [sHistoryEntry] with a key corresponding to the next
    //    history index
    //  - Remote all key associated with [sHistoryEntries] which are after the
    //    next history index
    setState(() {
      _currentHistoryEntry = sHistoryEntry;
      _history = history
          .add(newHistoryIndex, sHistoryEntry)
          .removeWhere((key, value) => key > newHistoryIndex);
    });

    _sBrowser.push(sHistoryEntry.webEntry);
  }

  /// Replaces the current entry
  ///
  ///
  /// This will also replace in the browser
  ///
  ///
  /// See "Optimization Remarks" to learn why we update [history] while we
  /// could simply react to [SBrowserInterface] notifications
  void _replaceSHistoryEntry(SHistoryEntry sHistoryEntry) {
    setState(() {
      _currentHistoryEntry = sHistoryEntry;
      _history = history.add(_sBrowser.historyIndex, sHistoryEntry);
    });

    _sBrowser.replace(sHistoryEntry.webEntry);
  }

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
  /// [_updateHistoryWithCurrentWebEntry] when [SBrowserInterface] will have
  /// processed this method and updated its current history index
  void go(int delta) => _sBrowser.go(delta);

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
  bool? canGo(int delta) => _sBrowser.canGo(delta);

  /// Converts the current [WebEntry] from [_sBrowser] to a [SRoute]
  ///
  ///
  /// This must be called when [_sBrowser] notify its listeners
  _updateHistoryWithCurrentWebEntry() {
    // Grab the current webEntry using [SBrowserInterface]
    final webEntry = _sBrowser.webEntry;

    // Grab the current history index
    final historyIndex = _sBrowser.historyIndex;

    // If [initialUrlHandled] is false and we are NOT deep-linking, report
    // the url with [widget.initialRoute]
    if (!_initialUrlHandled) {
      _initialUrlHandled = true;

      if (webEntry == _sBrowser.initialWebEntry && historyIndex == 0) {
        return to(widget.initialRoute, isReplacement: true);
      }
    }
    // Get the route from the translators
    final route = _translatorsHandler.getRouteFromWebEntry(context, webEntry) ??
        (throw UnknownWebEntryError(webEntry: webEntry));

    // Call replace with the route instead of directly storing the corresponding
    // [SHistoryEntry] because the title might need to be set and this is only
    // accessible by converting the route to a [WebEntry]
    to(route, isReplacement: true);
  }

  /// This function must end up removing the last page in the list of pages
  /// given to [RootSFlutterNavigatorBuilder]
  void _onPop() {
    // At this point, we already know that there is a page bellow because
    // [RootSFlutterNavigatorBuilder] checked route.didPop
    final newSRoute = _sElements[_sElements.length - 2].sWidget.sRoute;

    to(newSRoute);
  }

  /// This function handles a system pop by first passing the event to the top
  /// [SElement]
  ///
  /// If the top [SElement] did NOT handle the event, we handle it by:
  ///   - Either popping on the SRoute bellow if any
  ///   - Or putting the app in the background
  void _onSystemPop() {
    final result = _sElements.last.onSystemPop(context);

    result.when(
      parent: () {
        // We don't know if a tab bellow exists, so use getOrNull
        final sRouteBellow = _sElements.getOrNull(_sElements.length - 2)?.sWidget.sRoute;

        if (sRouteBellow == null) {
          // If there is no [SRoute] bellow, move the app to the background
          if (!widget.disableSendAppToBackground) {
            MoveToBackground.moveTaskToBack();
          }
          return;
        }

        to(sRouteBellow);
      },
      done: () {
        // We navigate to the same [sRoute] since the changes where internal
        _pushSHistoryEntry(
          SHistoryEntry(
            webEntry: _translatorsHandler.getWebEntryFromSElement(context, _sElements.last) ??
                (throw UnknownSRouteError(sRoute: currentHistoryEntry!.route)),
            route: currentHistoryEntry!.route,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // If we are nested, the update should only happen during the [build] phase
    // i.e. NOT during browser call
    //
    // We avoid the initialization as well since this would just be a duplicate
    // of the first build call
    if (!_isNested) {
      // Initialize [_history] by syncing it with [SBrowserInterface]
      _updateHistoryWithCurrentWebEntry();

      _sBrowser.addListener(_updateHistoryWithCurrentWebEntry);
    }
  }

  @override
  void didUpdateWidget(covariant SRouter oldWidget) {
    // If we are nested, the update should only happen during the [build] phase
    if (!_isNested) {
      _sBrowser.removeListener(_updateHistoryWithCurrentWebEntry);
      _sBrowser.addListener(_updateHistoryWithCurrentWebEntry);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (!_isNested) {
      _sBrowser.removeListener(_updateHistoryWithCurrentWebEntry);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No need to update if we are NOT nested since this will be done on browser
    // update anyway
    if (_isNested) _updateHistoryWithCurrentWebEntry();

    return _SRouterProvider(
      state: this,
      currentHistoryEntry: currentHistoryEntry!,
      isNested: _isNested,
      child: BackButtonListenerScope(
        child: Builder(
          builder: (context) {
            final navigatorBuilder = RootSFlutterNavigatorBuilder(
              pages: _sElements.map((element) => element.buildPage(context)).toList(),
              navigatorKey: widget.navigatorKey,
              navigatorObservers: widget.navigatorObservers,
              onPop: _onPop,
              onSystemPop: _onSystemPop,
            );

            return widget.builder?.call(context, navigatorBuilder) ?? navigatorBuilder;
          },
        ),
      ),
    );
  }
}

/// A provider which given efficient access to the nearest [SRouter]
///
///
/// This will also cause the subscribed [BuildContext] to rebuild if [isNested]
/// of [currentHistoryEntry] are updated
class _SRouterProvider extends InheritedWidget {
  /// The current [SHistoryEntry]
  final SHistoryEntry currentHistoryEntry;

  /// Whether the associated [SRouter] is nested in another one
  final bool isNested;

  /// The [SRouterState] that this [InheritedWidget] provides
  ///
  ///
  /// Do NOT use this in [updateShouldNotify] since this object will mutate
  /// (therefore its reference will be the same)
  final SRouterState state;

  const _SRouterProvider({
    Key? key,
    required Widget child,
    required this.state,
    required this.currentHistoryEntry,
    required this.isNested,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_SRouterProvider old) {
    return old.currentHistoryEntry != currentHistoryEntry || old.isNested != isNested;
  }
}

/// An exception thrown when the given web entry in
/// [STranslatorsHandler.getRouteFromWebEntry] could not be matched by any
/// translator
class UnknownWebEntryError implements Exception {
  /// The web entry which could not be converted to an SRoute
  final WebEntry webEntry;

  // ignore: public_member_api_docs
  UnknownWebEntryError({required this.webEntry});

  @override
  String toString() => '''
The web entry $webEntry could not be translated to a route.

If you are on the web, did you forget to add the translator corresponding to the web entry $webEntry ?

If you are NOT on the web, this should never happen, please fill an issue.
''';
}

/// An exception thrown when the given [SRouteBase] in
/// [STranslatorsHandler.getRouteFromWebEntry] could not be matched by any
/// translator
class UnknownSRouteError implements Exception {
  /// The [SRouteBase] which could not be converted to an [WebEntry]
  final SRouteBase sRoute;

  // ignore: public_member_api_docs
  UnknownSRouteError({required this.sRoute});

  @override
  String toString() => '''
The route of type ${sRoute.runtimeType} could not be translated to a web entry.

If you are on the web, did you forget to add the translator corresponding to the route of type ${sRoute.runtimeType} ?

If you are NOT on the web, this should never happen, please fill an issue.
''';
}
