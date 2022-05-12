import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theater.dart';
import '../navigator/theater_navigator.dart';
import '../translators/translators/web_entry_matcher/web_entry_match.dart';
import '../translators/translators/web_entry_matcher/web_entry_matcher.dart';
import '../translators/translators_handler.dart';

/// This is the base objects which constitute Theater.
///
///
/// The logic is loosely inspired by the flutter framework.
/// Flutter: [Widget] -> [Element] -> [RenderObject]
/// Theater: [PageWidget] -> [PageElement] -> [Page]
///
/// However, since the goal of [Theater] is to describe a stack of [Page]s with
/// only one object, we introduce a new class named [PageStackBase] so that:
/// [PageStackBase] -> [PageWidget]s -> [PageElement]s -> [Page]s
///
/// The mutability of the different classes are also inspired by Flutter:
///   - [PageStackBase] is immutable
///   - [PageWidget] is immutable
///   - [PageElement] is mutable
///   - [Page] is immutable (this one differs)
///
///
/// Here is how this system work is more details:
///
/// 1. [PageStackBase] creates multiple [PageWidget]s
///
/// 2. For each [PageWidget], we look at the previous [PageElement]s that the class
/// containing [PageStackBase] has:
///   - If there is a [PageElement] associated with an [PageWidget] of the same
///   ^ [PageWidget.runtimeType] and [PageWidget.key], we call [PageElement.update]
///   - If there is no corresponding [PageElement], we create a new one by calling
///   ^ [PageWidget.createPageElement]
///
/// 3. For each [PageElement], we can obtain the associated [Page] by calling
/// [PageElement.buildPage]

// TODO: write doc
abstract class PageElement<State extends PageState> {
  /// Creates an element that uses the given [PageWidget] as its configuration.
  ///
  /// Typically called by an override of [PageWidget.createPageElement].
  PageElement(this._pageWidget);

  /// The configuration of this [PageElement]
  ///
  /// This is updated in [update]
  PageWidget get pageWidget => _pageWidget;
  PageWidget _pageWidget;

  /// The current state of ths [PageElement]
  ///
  /// This will be set during [mount] and [update]
  State get state => _state!;
  State? _state;

  /// The [Page] created by this [PageElement]
  ///
  /// It will be created in [mount]
  Page get page => _page!;
  Page? _page;

  /// Builds the [Page] associated with this [PageElement]
  ///
  ///
  /// This will be called after this [PageElement] is instantiated and then
  /// one time after each [update] when the [Page] is needed for the
  /// [Navigator]
  /// If the [Page] is not needed (because the corresponding [Navigator] is
  /// not put in the widget tree for example), this will not be called
  @protected
  Page buildPage(BuildContext context);

  /// Creates the first [PageState] for this [PageElement]
  ///
  /// This will be called during [mount], before [buildPage] is called
  State createState(BuildContext context, {required bool isCurrent});

  /// Updates the [PageState] of this [PageElement]
  ///
  /// This will be called during [update], after [pageWidget] is updated
  State updateState(
    BuildContext context, {
    required covariant PageWidget oldPageWidget,
    required bool isCurrent,
  });

  /// This function must be called after this [PageElement] has been instantiated
  ///
  /// It allows to initialize variables which depends on [context]
  @protected
  @mustCallSuper
  void mount(
    BuildContext context, {
    required bool isCurrent,
  }) {
    _state = createState(context, isCurrent: isCurrent);
    _page = buildPage(context);
  }

  /// Changes the [PageWidget] used to configure this [PageElement]
  ///
  ///
  /// This is called each time the parent of this [PageElement] receives a new
  /// [newPageWidget] which can be associated with this [PageElement]
  ///
  ///
  /// Keep in mind that the given [context] is always very high (at the level
  /// of [Theater])
  @protected
  @mustCallSuper
  void update(
    covariant PageWidget newPageWidget,
    BuildContext context, {
    required bool isCurrent,
  }) {
    final _oldPageWidget = _pageWidget;
    _pageWidget = newPageWidget;
    _state = updateState(
      context,
      oldPageWidget: _oldPageWidget,
      isCurrent: isCurrent,
    );
    _page = buildPage(context);
  }

  /// A function which is called by a parent [PageElement] when the android back
  /// button is pressed
  ///
  ///
  /// Return either:
  ///   - [SystemPopResult.done] if the even was handled internally
  ///   - [SystemPopResult.parent] if the even should be handled by the parent
  SystemPopResult onSystemPop(BuildContext context);
}

/// The current state of a [PageElement]
@immutable
class PageState extends Equatable {
  // ignore: public_member_api_docs
  PageState({required this.isCurrent});

  /// Whether the associated [Page] is at the top of the stack of the current
  /// navigator
  final bool isCurrent;

  @override
  List<Object?> get props => [isCurrent];

  /// Returns the [PageState] associated to the closest [Page] oo the given
  /// [context]
  ///
  /// This can be used to known if the page is current
  static PageState of(BuildContext context) {
    final modalRoute = ModalRoute.of(context);

    if (modalRoute == null) {
      throw Exception('Page.of called outside of a PageRoute.');
    }

    // Every [PageRoute] setting is its associated [Page]
    final _pageOfContext = modalRoute.settings;

    if (_pageOfContext is! Page) {
      throw Exception(
          'Page.of called in a ModalRoute with is not a PageRoute.');
    }

    final _pageState = TheaterNavigator.stateOf(context, _pageOfContext);

    if (_pageState == null) {
      throw Exception(
        'Page.of found the page ${_pageOfContext.runtimeType} in the given context but its associated PageElement could not be found.',
      );
    }

    return _pageState;
  }
}

/// A description of the configuration of a [PageElement]
///
///
/// Given a [PageWidget] pageWidget and a [PageElement] pageElement, if
/// [PageWidget.canUpdate(PageElement.pageWidget, pageWidget)] is true we say that pageElement
/// is associated with pageWidget
///
///
/// [PageWidget] will be used to:
///   - Create a new [PageElement]
///   - Update an existing [PageElement]
///
/// ### Create a new [PageElement]
/// If there is no [PageElement] associated with the [PageWidget] in the parent, a
/// new [PageElement] is created by calling [PageWidget.createPageElement]
///
/// ### Update an existing [PageElement]
/// If there is an [PageElement] associated with the [PageWidget] in the parent, the
/// [PageElement] is updated by calling [PageElement.update] with the [PageWidget] as a
/// parameter
@immutable
abstract class PageWidget {
  /// An identifier of the [PageWidget] used in [canUpdate] to know if a [PageElement]
  /// is associated with this [PageWidget] or not
  final Key? key;

  /// The configuration of this widget
  final PageStackBase pageStack;

  /// Initializes [key] for subclasses.
  ///
  /// Typically called by an override of [PageStackBase.createPageWidgets].
  const PageWidget(this.pageStack, {this.key});

  /// Create an [PageElement] which will be associated to this [PageWidget]
  ///
  /// This can be called several time or never depending on whether a new
  /// [PageElement] needs to be instantiated. Read this class description for
  /// more details.
  PageElement createPageElement();

  /// Whether two [PageWidget]s are considered to be the "same" from the point of
  /// view of an [PageElement]
  ///
  /// This is used to know whether an [PageElement] which contains [oldWidget] can
  /// be updated (by calling [PageElement.update]) with [newWidget]
  static bool canUpdate(PageWidget oldWidget, PageWidget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType &&
        oldWidget.key == newWidget.key;
  }
}

/// An [PageElement] which is entirely defined by its [StatelessPageWidget]
/// configuration
class StatelessPageElement extends PageElement {
  /// Creates an element which uses [pageWidget] as its configuration
  StatelessPageElement(StatelessPageWidget pageWidget) : super(pageWidget);

  @override
  StatelessPageWidget get pageWidget => super.pageWidget as StatelessPageWidget;

  @override
  Page buildPage(BuildContext context) => pageWidget.buildPage(context, state);

  @override
  SystemPopResult onSystemPop(BuildContext context) => SystemPopResult.parent();

  // @override
  // PageState updateState(PageState pageState) => pageState;

  @override
  PageState createState(BuildContext context, {required bool isCurrent}) {
    return PageState(isCurrent: isCurrent);
  }

  @override
  PageState updateState(
    BuildContext context, {
    required covariant PageWidget oldPageWidget,
    required bool isCurrent,
  }) {
    return PageState(isCurrent: isCurrent);
  }
}

/// Describes the configuration of a [StatelessPageElement]
///
///
/// [buildPage] will be use when the [PageElement] needs to build its page (in
/// [PageElement.buildPage])
abstract class StatelessPageWidget extends PageWidget {
  /// Gives the [pageStack] and [key] to its superclass
  const StatelessPageWidget(PageStackBase pageStack, {Key? key})
      : super(pageStack, key: key);

  @nonVirtual
  @override
  PageElement createPageElement() => StatelessPageElement(this);

  /// Builds the page corresponding to this [PageWidget]
  Page buildPage(BuildContext context, PageState state);
}

/// Description of a stack of [Page]s
///
///
/// It creates a list of [Page]s by:
///   - Creating a [PageWidget] in [createPageWidget] which describes the top most
///   ^ [Page]
///   - Getting the [PageStack] in [pageStackBellow] which describes the [Page]s
///   ^ which are bellow the one created in [createPageWidget]
@immutable
abstract class PageStackBase {
  /// Defines a const constructor so that subclasses can be const
  const PageStackBase();

  /// Creating a [PageWidget] in [createPageWidget] which describes the top most
  /// [Page]
  ///
  ///
  /// Keep in mind that the given [context] is always very high (at the level
  /// of [Theater])
  PageWidget createPageWidget(BuildContext context);

  /// Creates an [PageStackBase] which describes the [Page]s to display bellow the
  /// page created by the [PageWidget] in [createPageWidget]
  ///
  /// If null, there is no [PageStack] bellow
  PageStackBase? get pageStackBellow;
}

/// An extension which allows us to easily build all the [PageWidget]s generated
/// by a [PageStack] (including the [PageStack] own [PageWidget] and all those generated
/// by the [pageStackBellow])
extension _PageStackBasePageWidgetsBuilder on PageStackBase {
  IList<PageWidget> createPageWidgets(BuildContext context) => <PageWidget>[
        ...(pageStackBellow?.createPageWidgets(context) ?? []),
        createPageWidget(context),
      ].lock;
}

/// Returns the new [PageElement]s for the given [PageStackBase] based on the old
/// [PageElement]s of this [PageStackBase]
///
///
/// It uses the same method that Flutter does, by matching the [PageElement]
/// with the [PageWidget] of same runtimeType and key, else creating new
/// [PageElement] by calling [PageWidget.createPageElement]
///
/// [isLastPageElementCurrent] Whether the last [PageElement] created is current or
/// not. This should be true when the parent is current and the stack is in the
/// current navigator.
IList<PageElement> updatePageStackBasePageElements(
  BuildContext context, {
  required IList<PageElement> oldPageElements,
  required PageStackBase pageStack,
  required bool isLastPageElementCurrent,
}) {
  var _oldPageElements = oldPageElements;
  var _newPageElements = IList<PageElement>();
  final _pageWidgets = pageStack.createPageWidgets(context);
  for (var i = 0; i < _pageWidgets.length; i++) {
    final _pageWidget = _pageWidgets[i];
    final isCurrent =
        isLastPageElementCurrent && _pageWidget == _pageWidgets.last;
    // If we have a hash match, use it without calling update
    final _hasHashMatch = _oldPageElements.any(
      (oldPageElement) => oldPageElement.pageWidget == _pageWidget,
    );
    if (_hasHashMatch) {
      continue;
    }

    // If we have a widget match (i.e. the runtimeType are the same), we
    // update the corresponding element with the new widget
    final _pageElement = _oldPageElements.firstWhereOrNull(
      (oldPageElement) => PageWidget.canUpdate(
        oldPageElement.pageWidget,
        _pageWidget,
      ),
    );
    if (_pageElement != null) {
      // Remove the element from the old list so that it's not matched
      // several times
      _oldPageElements = _oldPageElements.remove(_pageElement);

      // Update the element with the new PageWidget and add it to the new list
      // of PageElements
      _pageElement.update(
        _pageWidget,
        context,
        isCurrent: isCurrent,
      );
      _newPageElements = _newPageElements.add(_pageElement);
    } else {
      // If we don't have a widget match, it means that we currently don't
      // have the corresponding element so we create a new one from the
      // widget
      final _newPageElement = _pageWidget.createPageElement();

      _newPageElements = _newPageElements.add(_newPageElement);

      // Initialize the newly created [PageElement]
      _newPageElement.mount(context, isCurrent: isCurrent);
    }
  }

  // Here we could dispose of the incurrent element by using [_oldPageElements]

  return _newPageElements;
}

/// A [StatelessPageWidget] which uses a [StatelessPageStack] as its configuration
///
///
/// This might seem counter intuitive since a [PageStackBase] is supposed to
/// describe a list of [PageWidget]s and not a single one but it turns out that
/// having both purpose it intuitive and effective. See [StatelessPageStack] to
/// understand why.
class PageStackWidget<PS extends PageStack> extends StatelessPageWidget {
  /// The configuration of this [PageWidget]
  final PS pageStack;

  /// Initialize [pageStack] for subclasses and passes [key] to the super
  /// constructor
  const PageStackWidget(
    this.pageStack, {
    Key? key,
  }) : super(pageStack, key: key);

  @override
  Page buildPage(BuildContext context, PageState state) =>
      pageStack.buildPage(context, state, pageStack.build(context));
}

/// Provides the default page to be used
class DefaultPageBuilder extends InheritedWidget {
  // ignore: public_member_api_docs
  const DefaultPageBuilder({
    Key? key,
    required Widget child,
    required this.builder,
  }) : super(key: key, child: child);

  /// The default builder which will be used if [PageStack] does not implement
  /// buildPage
  final Page Function(
    BuildContext context,
    PageStackWithPage pageStack,
    Widget child,
  ) builder;

  /// Returns the [DefaultPageBuilder] of the given [context]
  static DefaultPageBuilder of(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<DefaultPageBuilder>();
    assert(element != null, 'No DefaultPageBuilder found in context');
    return element!.widget as DefaultPageBuilder;
  }

  @override
  bool updateShouldNotify(DefaultPageBuilder old) => false;
}

/// Builds the default page for a page stack
mixin PageStackWithPage<State extends PageState> on PageStackBase {
  /// A key used (if non-null) in the [Page] built in [buildPage]
  LocalKey? get key => ValueKey(runtimeType);

  /// Builds the page used for the top page of the page stack
  ///
  /// By default, uses the page builder stored in [DefaultPageBuilder]
  Page buildPage(BuildContext context, State state, Widget child) {
    return DefaultPageBuilder.of(context).builder(context, this, child);
  }
}

/// The primary class used in [Theater] to describe the [Page]s of the [Navigator].
///
/// [build] will be the visible widget (the one at the top of the [Navigator]
/// [Page] stack)
///
/// [pageStackBellow] provides a [PageStackBase] which describes the [Page] stack
/// to put bellow the page from [build]
///
///
/// You can override [buildPage] if you want to build a custom [Page].
abstract class PageStack extends PageStackBase with PageStackWithPage<PageState> {
  /// Allow subclasses to be const
  const PageStack();

  /// The widget which will be displayed on the screen when this [PageStack] is
  /// used directly
  ///
  ///
  /// This widget will be put inside the [Page] built in [buildPage]
  Widget build(BuildContext context);

  @override
  @nonVirtual
  PageWidget createPageWidget(BuildContext context) =>
      PageStackWidget(this, key: key ?? ValueKey(runtimeType));

  /// By default, we don't build any [Page] bellow this one
  @override
  PageStackBase? get pageStackBellow => null;
}

/// The [PageState] of a [MultiTabsPageStack] associated with [TabsState]
///
/// This is used in [MultiTabsPageElement]
class MultiTabPageState<TabsState extends MultiTabState> extends PageState {
  // ignore: public_member_api_docs
  MultiTabPageState({
    required bool isCurrent,
    required this.tabs,
    required this.tabsState,
  }) : super(isCurrent: isCurrent);

  /// The tabs as usable [Widget] to put in the widget tree
  ///
  ///
  /// The widgets are created by [Theater] and are [Builder]s so you don't use
  /// this to reason on the state of your tabs, use the tabs [PageStack] instead
  late final List<Widget> tabs;

  /// {@macro theater.framework.MultiTabState.currentIndex}
  int get currentIndex => tabsState.currentIndex;

  /// The state of the tabs
  final TabsState tabsState;

  @override
  List<Object?> get props => [isCurrent, tabs, tabsState];
}

/// A function to build the state [S] based on a previous value of the state
///
/// This works well with immutable states implementing a copyWith method
typedef StateBuilder<S> = S Function(S state);

/// State associated with the [MultiTabsPageStack], which describes the stacks of
/// [Page]s of each tabs. It does that by storing one [PageStackBase] per tab.
///
///
/// This state is immutable, therefore a new instance should be rebuilt from
/// the previous one via a [StateBuilder]. This is what happens each time
/// [MultiTabsPageElement.update] is called
/// Subclasses should implement a copyWith method to makes this easy
@immutable
abstract class MultiTabState extends Equatable {
  /// {@template theater.framework.MultiTabState.constructor}
  ///
  /// Creates a state where:
  ///   - [currentIndex] indicate the tab which is currently shown (this is also
  ///   ^ used to know which tab to pop when onPop is called)
  ///   - [tabXPageStack] describes the [Page] stack of tab X
  ///
  /// {@endtemplate}
  const MultiTabState({
    required this.currentIndex,
    required this.tabsPageStacks,
  }) : assert(
          0 <= currentIndex && currentIndex <= tabsPageStacks.length,
          'The given currentIndex ($currentIndex) is not valid, it must be between 0 and ${tabsPageStacks.length}',
        );

  /// {@template theater.framework.MultiTabState.currentIndex}
  ///
  /// An index indicating which tab is currently current
  ///
  /// This value is used for multiple things like:
  ///   - Popping the currently current tab
  ///   - Translating the currently current tab to a WebEntry
  ///
  /// We always have: 0 <= [currentIndex] <= [tabsPageStacks.length] - 1
  ///
  /// {@endtemplate}
  final int currentIndex;

  /// A list containing one [PageStackBase] per tab
  ///
  ///
  /// Its length determines the number of tabs
  final IList<PageStackBase> tabsPageStacks;

  @override
  List<Object?> get props => [currentIndex, tabsPageStacks];
}

/// The element created by [_MultiTabsPageWidget]
///
/// It manages the [MultiTabState] and all the [PageElement]s it creates
class MultiTabsPageElement<TabsState extends MultiTabState>
    extends PageElement<MultiTabPageState<TabsState>> {
  /// Initialize the [state] with the initial state of the [MultiTabsPageStack]
  MultiTabsPageElement(_MultiTabsPageWidget<TabsState> pageWidget)
      : super(pageWidget);

  @override
  _MultiTabsPageWidget<TabsState> get pageWidget =>
      super.pageWidget as _MultiTabsPageWidget<TabsState>;

  // /// The state of the [MultiTabPageStack]
  // ///
  // /// It will first be [MultiTabPageStack.initialState], then mutate each time
  // /// [update] is called by being assigned the result of
  // /// [MultiTabPageStack._stateBuilder]
  // ///
  // /// This state is then given to [MultiTabPageStack.buildPage] and
  // /// [MultiTabPageStack.onPop]
  // ///
  // ///
  // /// The state contains page stacks which are translated into [PageWidget]s, the
  // /// element associated with this widgets are stored into [_tabsPageElements]
  // /// which is updated each time the state mutates
  // MultiTabPageState<S> get state => _state!;
  //
  // /// The value of [state]
  // ///
  // /// IMPORTANT: only use [_updateState] to change this variable
  // MultiTabPageState<S>? _state;
  //
  // @override
  // MultiTabPageState<S> updateState(PageState pageState) {}

  /// The elements created by the [state]
  ///
  ///
  /// The [state] has different tabs, each tab has a [PageStackBase] which
  /// produces a list of [PageElement]s. The map maps the tab index to the
  /// generated tab [PageElement]s
  ///
  ///
  /// This is updated each time [state] changes, by using the method described
  /// at the top of this file (the same method Flutter uses to update its
  /// widgets and elements)
  IMap<int, IList<PageElement>> get tabsPageElements => _tabsPageElements;
  IMap<int, IList<PageElement>> _tabsPageElements = IMap();

  /// The [GlobalKey] of the navigator of each tab
  ///
  /// The keys of this IMap are the same as the one of [_tabsPageElements]
  IMap<int, GlobalKey<NavigatorState>> _tabsNavigatorKeys = IMap();

  /// Builds the page by calling [MultiTabsPageStack.buildPage]
  ///
  /// This is also responsible for populating [state.tabs] which consist in:
  ///   1. Updating the [PageElement]s associated with each tab
  ///   2. Using each tab [PageElement]s to get the page_transitions to put in the nested
  ///   ^  [Navigator]
  @override
  Page buildPage(BuildContext context) {
    return pageWidget._multiTabPageStack.buildPage(
      context,
      state,
      pageWidget._multiTabPageStack.build(context, state),
    );
  }

  @override
  MultiTabPageState<TabsState> createState(
    BuildContext context, {
    required bool isCurrent,
  }) {
    return _buildState(
      context,
      isCurrent: isCurrent,
      newTabState: pageWidget._multiTabPageStack._stateBuilder(
        pageWidget._multiTabPageStack.initialState,
      ),
    );
  }

  /// If not null, this will be used in the next [updateState] instead of using
  /// [_buildState]
  MultiTabPageState<TabsState>? _nextStateUpdateOverride;

  @override
  MultiTabPageState<TabsState> updateState(
    BuildContext context, {
    required covariant _MultiTabsPageWidget<TabsState> oldPageWidget,
    required bool isCurrent,
  }) {
    final nextStateUpdateOverride = _nextStateUpdateOverride;
    if (nextStateUpdateOverride != null) {
      _nextStateUpdateOverride = null;

      return nextStateUpdateOverride;
    }

    return _buildState(
      context,
      isCurrent: isCurrent,
      newTabState: pageWidget._multiTabPageStack._stateBuilder(
        state.tabsState,
      ),
    );
  }

  /// Creates a new [MultiTabPageState] from the current state and the given
  /// arguments
  ///
  /// This is in charge of setting/updating [_tabsPageElements]
  MultiTabPageState<TabsState> _buildState(
    BuildContext context, {
    required bool isCurrent,
    required TabsState newTabState,
  }) {
    // Update the [PageElement]s of each tabs
    for (var i = 0; i < newTabState.tabsPageStacks.length; i++) {
      _tabsPageElements = _tabsPageElements.add(
        i,
        updatePageStackBasePageElements(
          context,
          oldPageElements: _tabsPageElements[i] ?? IList(),
          pageStack: newTabState.tabsPageStacks[i],
          isLastPageElementCurrent: isCurrent && i == newTabState.currentIndex,
        ),
      );
      _tabsNavigatorKeys =
          _tabsNavigatorKeys.putIfAbsent(i, GlobalKey<NavigatorState>.new);
    }

    final _newTabs = [
      for (var _tabIndex in _tabsPageElements.keys)
        Builder(
          // Use this key so that AnimatedSwitcher can easily be used to animate
          // a transition between tabs
          key: ValueKey('theater_tabIndex_$_tabIndex'),
          builder: (childContext) => TheaterNavigator(
            pageElements: _tabsPageElements[_tabIndex]!,
            navigatorKey: _tabsNavigatorKeys[_tabIndex]!,
            // We don't support nested observers yet
            navigatorObservers: [],
            onPop: () {
              final tabPageElements = _tabsPageElements[_tabIndex]!;

              // Replace the current tab pageStack (which is the last one) by
              // the one bellow
              //
              // It has to exist if didPop is true
              final tabPageStackBellow =
                  tabPageElements[tabPageElements.length - 2]
                      .pageWidget
                      .pageStack;

              _nextStateUpdateOverride = _buildState(
                context,
                isCurrent: isCurrent,
                newTabState:
                    pageWidget._multiTabPageStack._buildFromMultiTabState(
                  newTabState.currentIndex,
                  newTabState.tabsPageStacks.replace(
                    newTabState.currentIndex,
                    tabPageStackBellow,
                  ),
                ),
              );

              // Update Theater
              (Theater.of(context) as TheaterState).update();
            },
          ),
        ),
    ];

    // Update [_state]
    return MultiTabPageState(
      isCurrent: isCurrent,
      tabsState: newTabState,
      tabs: _newTabs,
    );
  }

  /// TODO: add comment
  @override
  SystemPopResult onSystemPop(BuildContext context) {
    final currentTabPageElements = _tabsPageElements[state.currentIndex]!;

    final result = currentTabPageElements.last.onSystemPop(context);

    return result.when(
      parent: () {
        // We don't know if a tab bellow exists, so use getOrNull
        final tabPageStackBellow = currentTabPageElements
            .getOrNull(currentTabPageElements.length - 2)
            ?.pageWidget
            .pageStack;

        if (tabPageStackBellow == null) {
          // If there is no [PageStack] bellow, delegate the system pop to the
          // parent
          return SystemPopResult.parent();
        }

        // If there is a [PageStack] bellow, update the state with the new tab
        // PageStack during the next update
        _nextStateUpdateOverride = _buildState(
          context,
          isCurrent: state.isCurrent,
          newTabState: pageWidget._multiTabPageStack._buildFromMultiTabState(
            state.currentIndex,
            state.tabsState.tabsPageStacks.replace(
              state.currentIndex,
              tabPageStackBellow,
            ),
          ),
        );

        // No need to update Theater as it already does when systemPop is called

        return SystemPopResult.done();
      },
      done: SystemPopResult.done,
    );
  }
}

/// The [PageWidget] creating the [MultiTabsPageElement]
///
/// It uses [MultiTabsPageStack] as its configuration
class _MultiTabsPageWidget<TabsState extends MultiTabState> extends PageWidget {
  /// Passes the [key] to the super constructor and initializes [_multiTabPageStack]
  const _MultiTabsPageWidget(this._multiTabPageStack, {Key? key})
      : super(_multiTabPageStack, key: key);

  /// The configuration of this widget
  final MultiTabsPageStack<TabsState> _multiTabPageStack;

  @override
  PageElement createPageElement() => MultiTabsPageElement<TabsState>(this);
}

/// {@template theater.framework.STabsRoute}
///
/// An [PageStackBase] used to build a screen which has different tabs
///
///
/// Each tab is represented by an [PageStack] in the state. Each tab is therefore
/// a stack of [Page]s.
///
/// An index (named [currentIndex]) is also stored in the state, and is useful
/// to easily know which [PageStack] to display and is also used when popping to
/// call onPop the current [PageStack]
///
///
/// ### Building a widget with the different tabs
///
/// [MultiTabsPageStack] is focused on providing you an easy way to build a widget
/// with different tabs, the easiest way is to implement [build] and use the
/// given state to access the tabs:
///
/// ```dart
/// build(BuildContext context, S state) {
///   return Scaffold(
///     body: state.tabs[state.currentIndex],
///       bottomNavigationBar: BottomNavigationBar(
///       currentIndex: tabtheater.currentIndex,
///       onTap: (value) => Theater.to(
///         My2TabsPageStack((state) => state.copyWith(currentIndex: value)),
///       ),
///       items: [
///         BottomNavigationBarItem(label: 'Home', ...),
///         BottomNavigationBarItem(label: 'Settings', ...),
///       ],
///     ),
///   );
/// }
/// ```
///
///
/// ### Changing the state
///
/// To change the state, you have to push your [MultiTabsPageStack] into [Theater] and
/// use the [_stateBuilder] to provide the new state
///
/// For example, here is how to change the current index to be 0:
///
/// ```dart
/// Theater.to(
///   My2TabsPageStack((state) => state.copyWith(currentIndex: 0)),
/// )
/// ```
///
///
/// ### Initial state
///
/// Since [MultiTabsPageStack] uses a [_stateBuilder] to build the next state based on
/// the previous one, there has to be a first state to transition from.
///
///
/// Use the [_stateBuilder] is the constructor to go to a [MultiTabsPageStack] with an
/// updated state. For example to change the current index you can use
///
///
/// Use a subclass [Multi2Tabs], [Multi3Tabs], ... which allows you to build
/// a fixed number of tabs
///
/// {@endtemplate}
abstract class MultiTabsPageStack<S extends MultiTabState> extends PageStackBase
    with PageStackWithPage<MultiTabPageState<S>> {
  /// A const constructor initializing different attributes with the given
  /// values
  ///
  /// {@template theater.framework.STabsRoute.constructor}
  ///
  /// [stateBuilder] is used to build a new state based on the previous one.
  /// It is called each time a [MultiTabsPageStack] is given to [Theater]
  ///
  ///
  /// Example of changing the current index:
  /// ```dart
  /// My2TabsPageStack((state) => state.copyWith(currentIndex: 0))
  /// ```
  ///
  /// If you don't want to change the state, you can simply use:
  /// ```dart
  /// My2TabsPageStack((state) => state)
  /// ```
  ///
  /// {@endtemplate}
  const MultiTabsPageStack(
    this._stateBuilder,
    this._buildFromMultiTabState,
  );

  /// The initial state, it will be used the first time [StateBuilder] is
  /// called
  ///
  ///
  /// It is useless to change it, if you need to return a new state independent
  /// of the previous one, use [StateBuilder] and return a new instance:
  /// `(state) => _MultiTabState(currentIndex: ..., ...)`
  S get initialState;

  /// The widget which will be displayed on the screen when this [PageStack] is
  /// used directly
  ///
  ///
  /// This widget will be put inside the [Page] built in [buildPage]
  Widget build(BuildContext context, MultiTabPageState<S> state);

  // /// {@macro theater.framework.defaultBuildPage}
  // Page buildPage(
  //   BuildContext context,
  //   MultiTabPageState<S> state,
  //   Widget child,
  // ) =>
  //     _defaultBuildPage(
  //       context,
  //       (context) => build(context, state),
  //     );

  /// By default, we don't build any [Page] bellow this one
  PageStackBase? get pageStackBellow => null;

  /// Returns a new state based on the previous value of the state
  ///
  /// This is used every time a [MultiTabsPageStack] is given to [Theater]
  ///
  ///
  /// Example of changing the current index:
  /// ```dart
  /// My2TabsPageStack((state) => state.copyWith(currentIndex: 0))
  /// ```
  final StateBuilder<S> _stateBuilder;

  @override
  @nonVirtual
  PageWidget createPageWidget(BuildContext context) =>
      _MultiTabsPageWidget<S>(this, key: key ?? ValueKey(runtimeType));

  /// A function which build the state [S] based on the base state class
  /// [MultiTabState]
  ///
  /// It uses [MultiTabState] attributes rather than the class directly because
  /// the class [tabsPageStacks] attribute is private and we want to be able to
  /// create subclasses in other files
  ///
  ///
  /// This should be provided by [Multi2Tabs], [Multi3Tabs], ... and never
  /// visible to the end user
  final S Function(
    int currentIndex,
    IList<PageStackBase> tabsPageStacks,
  ) _buildFromMultiTabState;
}

/// {@template theater.framework.STabsRouteTranslator}
///
/// A translator which is used to map a [MultiTabsPageStack] to a [WebEntry]
///
///
///
/// DO always specify your class type:
/// ```dart
/// // GOOD
/// MultiTabTranslator<MyTabsRoute, ...>(...)
///
/// // BAD
/// MultiTabTranslator(...)
/// ```
///
/// {@endtemplate}
///
/// DO use [Multi2TabsTranslator], [Multi2TabsTranslator], etc depending on
/// which implementation of [MultiTabsPageStack] you implemented
abstract class MultiTabTranslator<PS extends MultiTabsPageStack<S>,
    S extends MultiTabState> extends Translator<MultiTabsPageElement<S>, PS> {
  /// Returns the [MultiTabsPageStack] associated with the given [WebEntry]
  ///
  ///
  /// [match] is the match of the incoming [WebEntry] based on the
  /// [WebEntryMatcher] which was given
  ///
  /// [tabsPageStacks] are the [PageStackBase]s returned by each tab's translators
  /// if any
  ///
  ///
  /// Return [null] if the [WebEntry] should not be converted to the associated
  /// [MultiTabsPageStack]
  PS? Function(
    WebEntryMatch match,
    StateBuilder<S>? stateBuilder,
  ) get matchToPageStack;

  /// Returns the docs entry to return docs the associated [MultiTabsPageStack]
  /// is pushed into [Theater]
  ///
  ///
  /// [pageStack] is the [MultiTabsPageStack]
  ///
  /// [state] is the current state of [pageStack]
  ///
  /// [currentTabWebEntry] is the docs entry returned by the tab at the current
  /// index. If the current tab could not be converted to a [WebEntry] this
  /// value is null
  WebEntry Function(
    PS pageStack,
    MultiTabPageState<S> state,
    WebEntry? currentTabWebEntry,
  ) get pageStackToWebEntry;

  /// A class which determined whether a given [WebEntry] is valid
  WebEntryMatcher get matcher;

  /// A [TranslatorHandler] for each tab of the state
  List<TranslatorsHandler> get translatorsHandlers;

  /// A function which build the state [S] based on the base state class
  /// [MultiTabState]
  ///
  /// It uses [MultiTabState] attributes rather than the class directly because
  /// the class [tabsPageStacks] attribute is private and we want to be able to
  /// create subclasses in other files
  ///
  ///
  /// This should be provided by [Multi2Tabs], [Multi3Tabs], ... and never
  /// visible to the end user
  S buildFromMultiTabState(
    int currentIndex,
    IList<PageStackBase> tabsPageStacks,
  );

  @override
  WebEntry pageElementToWebEntry(
    BuildContext context,
    MultiTabsPageElement<S> element,
    PS pageStack,
  ) {
    // Get the docs entry returned by the current tab
    final currentIndex = element.state.currentIndex;
    final currentTabWebEntry =
        translatorsHandlers[currentIndex].getWebEntryFromPageElement(
      context,
      element.tabsPageElements[currentIndex]!.last,
    );

    return pageStackToWebEntry(
      pageStack,
      element.state,
      currentTabWebEntry,
    );
  }

  @override
  PS? webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final match = matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    // Get the pageStack and its associated index returned from the [webEntry]
    MapEntry<int, PageStackBase>? maybeNewCurrentTabPageStack;
    for (var i = 0; i < translatorsHandlers.length; i++) {
      final translatorsHandler = translatorsHandlers[i];

      final pageStack =
          translatorsHandler.getPageStackFromWebEntry(context, webEntry);
      if (pageStack != null) {
        maybeNewCurrentTabPageStack = MapEntry(i, pageStack);
        break;
      }
    }

    return matchToPageStack(
      match,
      maybeNewCurrentTabPageStack == null
          ? null
          : (state) => buildFromMultiTabState(
                maybeNewCurrentTabPageStack!.key,
                state.tabsPageStacks.replace(
                  maybeNewCurrentTabPageStack.key,
                  maybeNewCurrentTabPageStack.value,
                ),
              ),
    );
  }
}
