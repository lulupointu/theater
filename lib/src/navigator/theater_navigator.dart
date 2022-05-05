import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../page_stack/framework.dart';
import '../theater/theater.dart';

/// The widget which creates the [Navigator] and map the current
/// [PageStack] to a list of page_transitions to display in [Navigator.page_transitions]
///
///
/// This also handles onPop and onBack
///
///
/// "Root" refers to the fact that this is the one created by [Theater] directly,
/// event if it might not be the "root navigator" per say.
class TheaterNavigator extends StatefulWidget {
  // ignore: public_member_api_docs
  const TheaterNavigator({
    Key? key,
    required this.pageElements,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.onPop,
  })  : onSystemPop = null,
        super(key: key);

  /// A constructor to use to create the root theater navigator
  const TheaterNavigator.root({
    Key? key,
    required this.pageElements,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.onPop,
    required this.onSystemPop,
  }) : super(key: key);

  /// The page_transitions to display in the [Navigator]
  final IList<PageElement> pageElements;

  /// Called when a pop event happened in the created [Navigator]
  ///
  ///
  /// This callback should end up removing the last page of [page_transitions]
  final VoidCallback onPop;

  /// Called when a system pop (android back button press) occurred
  ///
  /// If null, the system pop will not be handled
  final VoidCallback? onSystemPop;

  /// The key of the navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the navigator
  final List<NavigatorObserver> navigatorObservers;

  /// Returns the [PageState] of the given [page]
  static PageState? stateOf(
    BuildContext context,
    Page page, {
    bool listen = true,
  }) {
    final _theaterNavigatorProvider = context
        .getElementForInheritedWidgetOfExactType<_TheaterNavigatorProvider>()
        ?.widget as _TheaterNavigatorProvider?;

    assert(
      _theaterNavigatorProvider != null,
      'No _TheaterNavigatorProvider found in context',
    );

    final _pageElement = _theaterNavigatorProvider?.pageElementOf(page);

    if (listen && _pageElement != null) {
          context.dependOnInheritedWidgetOfExactType<_TheaterNavigatorProvider>(
        aspect: _pageElement,
      );
    }

    return _pageElement?.state;
  }

  @override
  _TheaterNavigatorState createState() => _TheaterNavigatorState();
}

class _TheaterNavigatorState extends State<TheaterNavigator> {
  /// The key of the navigator created in [build]
  ///
  /// Used to call pop
  late final GlobalKey<NavigatorState> _navigatorKey =
      widget.navigatorKey ?? GlobalKey<NavigatorState>();

  /// The hero controller of the navigator
  ///
  /// This must be set because the [Navigator] is nested, using the same
  /// [HeroController] as the parent will throw
  final _heroController = HeroController();

  /// Call when [Navigator.onPopPage] is called
  bool _onPopPage(Route<dynamic> route, Object? data) {
    // First check if the route did pop
    final didPop = route.didPop(data);

    if (didPop) {
      // If the page did pop, call [onPop] so that the last [Page] of
      // [widget.page_transitions] gets removed
      widget.onPop();
    }

    return didPop;
  }

  /// Called when the android back button is pressed
  Future<bool> _onBackButtonPressed() async {
    final _onSystemPop = widget.onSystemPop;

    // If [onSystemPop] is null, the back button pop is not be handled
    if (_onSystemPop == null) {
      return false;
    }

    // If the root navigator (certainly the one created by WidgetApp) can pop,
    // it means that a ModalRoute (Dialog, BottomSheet, ...) has been pushed on
    // top of everything so pop it
    if (Navigator.maybeOf(context, rootNavigator: true)?.canPop() ?? false) {
      Navigator.of(context, rootNavigator: true).pop();
      return true;
    }

    // If the navigator created here has something which is not associated with
    // a page (therefore not associated with an Theater) at the of its page_stack,
    // pop it
    final _currentRoute = _getTopNavigatorRoute();
    if (_currentRoute?.settings is! Page) {
      _navigatorKey.currentState!.pop();
      return true;
    }

    _onSystemPop();

    // If onSystemPop, we always handles the android back button press
    return true;
  }

  /// Returns the [Route] (NOT [PageStack]) which is at the top of the [Navigator]
  /// created in [build]
  ///
  /// Returns null if [build] has not yet been called
  Route? _getTopNavigatorRoute() {
    Route? topNavigatorRoute;
    _navigatorKey.currentState?.popUntil((route) {
      topNavigatorRoute = route;
      return true;
    });
    return topNavigatorRoute;
  }

  @override
  void didChangeDependencies() {
    _dependOnParent();
    super.didChangeDependencies();
  }

  /// Makes this theater navigator depend on the parent theater navigator
  ///
  /// This is needed because if he parent theater navigator rebuild, the
  /// [_TheaterNavigatorProvider] created here might need to notify its children
  void _dependOnParent() {
    context.dependOnInheritedWidgetOfExactType<_TheaterNavigatorProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return _TheaterNavigatorProvider(
      pageElements: widget.pageElements,
      child: HeroControllerScope(
        controller: _heroController,
        child: BackButtonListener(
          onBackButtonPressed: _onBackButtonPressed,
          child: Navigator(
            key: _navigatorKey,
            observers: widget.navigatorObservers,
            pages: widget.pageElements
                .map((pageElement) => pageElement.page)
                .toList(),
            onPopPage: _onPopPage,
          ),
        ),
      ),
    );
  }
}

// TODO: describe what is happening here
class _TheaterNavigatorProvider extends InheritedModel<PageElement> {
  _TheaterNavigatorProvider({
    Key? key,
    required IList<PageElement> pageElements,
    required Widget child,
  })  : _pageStates = IMap.fromEntries(
          pageElements.map(
            (pageElement) => MapEntry(pageElement, pageElement.state),
          ),
        ),
        super(key: key, child: child);

  /// State of each page element
  ///
  /// This is needed in [updateShouldNotify] because [PageElement] is mutable
  final IMap<PageElement, PageState> _pageStates;

  /// Returns the [PageState] associated with the given [page]
  PageElement? pageElementOf(Page page) {
    return _pageStates.keys.firstWhereOrNull((entry) => entry.page == page);
  }

  @override
  bool updateShouldNotify(_TheaterNavigatorProvider old) {
    return old._pageStates != _pageStates;
  }

  @override
  bool updateShouldNotifyDependent(
    _TheaterNavigatorProvider oldWidget,
    Set<PageElement> dependencies,
  ) {
    return dependencies.any(
      (pageElement) =>
          oldWidget._pageStates[pageElement] != _pageStates[pageElement],
    );
  }
}
