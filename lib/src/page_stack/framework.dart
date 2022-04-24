import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../browser/web_entry.dart';
import '../s_router/s_router.dart';
import '../translators/translator.dart';
import '../translators/translators/web_entry_matcher/web_entry_match.dart';
import '../translators/translators/web_entry_matcher/web_entry_matcher.dart';
import '../translators/translators_handler.dart';
import 'system_pop_result/system_pop_result.dart';

/// This is the base objects which constitute SRouter.
///
///
/// The logic is loosely inspired by the flutter framework.
/// Flutter: [Widget] -> [Element] -> [RenderObject]
/// SRouter: [SWidget] -> [SElement] -> [Page]
///
/// However, since the goal of [SRouter] is to describe a stack of [Page]s with
/// only one object, we introduce a new class named [PageStackBase] so that:
/// [PageStackBase] -> [SWidget]s -> [SElement]s -> [Page]s
///
/// The mutability of the different classes are also inspired by Flutter:
///   - [PageStackBase] is immutable
///   - [SWidget] is immutable
///   - [SElement] is mutable
///   - [Page] is immutable (this one differs)
///
///
/// Here is how this system work is more details:
///
/// 1. [PageStackBase] creates multiple [SWidget]s
///
/// 2. For each [SWidget], we look at the previous [SElement]s that the class
/// containing [PageStackBase] has:
///   - If there is a [SElement] associated with an [SWidget] of the same
///   ^ [SWidget.runtimeType] and [SWidget.key], we call [SElement.update]
///   - If there is no corresponding [SElement], we create a new one by calling
///   ^ [SWidget.createSElement]
///
/// 3. For each [SElement], we can obtain the associated [Page] by calling
/// [SElement.buildPage]

// TODO: write doc
abstract class SElement {
  /// Creates an element that uses the given [SWidget] as its configuration.
  ///
  /// Typically called by an override of [SWidget.createSElement].
  SElement(this._sWidget);

  /// The configuration of this [SElement]
  ///
  /// This is updated in [update]
  SWidget get sWidget => _sWidget;
  SWidget _sWidget;

  /// Builds the [Page] associated with this [SElement]
  ///
  ///
  /// This will be called after this [SElement] is instantiated and then
  /// one time after each [update] when the [Page] is needed for the
  /// [Navigator]
  /// If the [Page] is not needed (because the corresponding [Navigator] is
  /// not put in the widget tree for example), this will not be called
  Page buildPage(BuildContext context);

  /// This function must be called after this [SElement] has been instantiated
  ///
  /// It allows to initialize variables which depends on [context]
  @mustCallSuper
  void initialize(BuildContext context) {}

  /// Changes the [SWidget] used to configure this [SElement]
  ///
  ///
  /// This is called each time the parent of this [SElement] receives a new
  /// [newSWidget] which can be associated with this [SElement]
  ///
  ///
  /// Keep in mind that the given [context] is always very high (at the level
  /// of [SRouter])
  @mustCallSuper
  void update(covariant SWidget newSWidget, BuildContext context) =>
      _sWidget = newSWidget;

  /// A function which is called by a parent [SElement] when the android back
  /// button is pressed
  ///
  ///
  /// Return either:
  ///   - [SystemPopResult.done] if the even was handled internally
  ///   - [SystemPopResult.parent] if the even should be handled by the parent
  SystemPopResult onSystemPop(BuildContext context);
}

/// A description of the configuration of a [SElement]
///
///
/// Given a [SWidget] sWidget and a [SElement] sElement, if
/// [SWidget.canUpdate(SElement.sWidget, sWidget)] is true we say that sElement
/// is associated with sWidget
///
///
/// [SWidget] will be used to:
///   - Create a new [SElement]
///   - Update an existing [SElement]
///
/// ### Create a new [SElement]
/// If there is no [SElement] associated with the [SWidget] in the parent, a
/// new [SElement] is created by calling [SWidget.createSElement]
///
/// ### Update an existing [SElement]
/// If there is an [SElement] associated with the [SWidget] in the parent, the
/// [SElement] is updated by calling [SElement.update] with the [SWidget] as a
/// parameter
@immutable
abstract class SWidget {
  /// An identifier of the [SWidget] used in [canUpdate] to know if a [SElement]
  /// is associated with this [SWidget] or not
  final Key? key;

  /// The configuration of this widget
  final PageStackBase pageStack;

  /// Initializes [key] for subclasses.
  ///
  /// Typically called by an override of [PageStackBase.createSWidgets].
  const SWidget(this.pageStack, {this.key});

  /// Create an [SElement] which will be associated to this [SWidget]
  ///
  /// This can be called several time or never depending on whether a new
  /// [SElement] needs to be instantiated. Read this class description for
  /// more details.
  SElement createSElement();

  /// Whether two [SWidget]s are considered to be the "same" from the point of
  /// view of an [SElement]
  ///
  /// This is used to know whether an [SElement] which contains [oldWidget] can
  /// be updated (by calling [SElement.update]) with [newWidget]
  static bool canUpdate(SWidget oldWidget, SWidget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType &&
        oldWidget.key == newWidget.key;
  }
}

/// An [SElement] which is entirely defined by its [StatelessSWidget]
/// configuration
class StatelessSElement extends SElement {
  /// Creates an element which uses [sWidget] as its configuration
  StatelessSElement(StatelessSWidget sWidget) : super(sWidget);

  @override
  StatelessSWidget get sWidget => super.sWidget as StatelessSWidget;

  @override
  Page buildPage(BuildContext context) => sWidget.buildPage(context);

  @override
  SystemPopResult onSystemPop(BuildContext context) => SystemPopResult.parent();
}

/// Describes the configuration of a [StatelessSElement]
///
///
/// [buildPage] will be use when the [SElement] needs to build its page (in
/// [SElement.buildPage])
abstract class StatelessSWidget extends SWidget {
  /// Gives the [pageStack] and [key] to its superclass
  const StatelessSWidget(PageStackBase pageStack, {Key? key})
      : super(pageStack, key: key);

  @nonVirtual
  @override
  SElement createSElement() => StatelessSElement(this);

  /// Builds the page corresponding to this [SWidget]
  Page buildPage(BuildContext context);
}

/// Description of a stack of [Page]s
///
///
/// It creates a list of [Page]s by:
///   - Creating a [SWidget] in [createSWidget] which describes the top most
///   ^ [Page]
///   - Getting the [PageStack] in [pageStackBellow] which describes the [Page]s
///   ^ which are bellow the one created in [createSWidget]
@immutable
abstract class PageStackBase {
  /// Defines a const constructor so that subclasses can be const
  const PageStackBase();

  /// Creating a [SWidget] in [createSWidget] which describes the top most
  /// [Page]
  ///
  ///
  /// Keep in mind that the given [context] is always very high (at the level
  /// of [SRouter])
  SWidget createSWidget(BuildContext context);

  /// Creates an [PageStackBase] which describes the [Page]s to display bellow the
  /// page created by the [SWidget] in [createSWidget]
  ///
  /// If null, there is no [PageStack] bellow
  PageStackBase? get pageStackBellow;
}

/// An extension which allows us to easily build all the [SWidget]s generated
/// by a [PageStack] (including the [PageStack] own [SWidget] and all those generated
/// by the [pageStackBellow])
extension _PageStackBaseSWidgetsBuilder on PageStackBase {
  IList<SWidget> createSWidgets(BuildContext context) => <SWidget>[
        ...(pageStackBellow?.createSWidgets(context) ?? []),
        createSWidget(context),
      ].lock;
}

/// Returns the new [SElement]s for the given [PageStackBase] based on the old
/// [SElement]s of this [PageStackBase]
///
///
/// It uses the same method that Flutter does, by matching the [SElement]
/// with the [SWidget] of same runtimeType and key, else creating new
/// [SElement] by calling [SWidget.createSElement]
IList<SElement> updatePageStackBaseSElements(
  BuildContext context, {
  required IList<SElement> oldSElements,
  required PageStackBase pageStack,
}) {
  var _oldSElements = oldSElements;
  var _newSElements = IList<SElement>();
  for (final _sWidget in pageStack.createSWidgets(context)) {
    // If we have a widget match (i.e. the runtimeType are the same), we
    // update the corresponding element with the new widget
    if (_oldSElements.any((e) => SWidget.canUpdate(e.sWidget, _sWidget))) {
      final _sElement = _oldSElements
          .firstWhere((e) => SWidget.canUpdate(e.sWidget, _sWidget));

      // Remove the element from the old list so that it's not matched
      // several times
      _oldSElements = _oldSElements.remove(_sElement);

      // Update the element with the new SWidget and add it to the new list
      // of SElements
      _sElement.update(_sWidget, context);
      _newSElements = _newSElements.add(_sElement);
    } else {
      // If we don't have a widget match, it means that we currently don't
      // have the corresponding element so we create a new one from the
      // widget
      final _newSElement = _sWidget.createSElement();

      _newSElements = _newSElements.add(_newSElement);

      // Initialize the newly created [SElement]
      _newSElement.initialize(context);
    }
  }

  // Here we could dispose of the inactive element by using [_oldSElements]

  return _newSElements;
}

/// A [StatelessSWidget] which uses a [StatelessPageStack] as its configuration
///
///
/// This might seem counter intuitive since a [PageStackBase] is supposed to
/// describe a list of [SWidget]s and not a single one but it turns out that
/// having both purpose it intuitive and effective. See [StatelessPageStack] to
/// understand why.
class StatelessPageStackSWidget<PS extends StatelessPageStack>
    extends StatelessSWidget {
  /// The configuration of this [SWidget]
  final PS pageStack;

  /// Initialize [pageStack] for subclasses and passes [key] to the super
  /// constructor
  const StatelessPageStackSWidget(
    this.pageStack, {
    Key? key,
  }) : super(pageStack, key: key);

  @override
  Page buildPage(BuildContext context) => pageStack.buildPage(context);
}

/// This [PageStackBase] serves 2 purpose:
///   1. Overrides [PageStackBase.createSWidget] by returning the [SWidget] from
///   ^ the [PageStack] in [pageStackBellow] AND a
///   ^ [StatelessPageStackSWidget]
///   2. Is the configuration of the [StatelessPageStackSWidget]
abstract class StatelessPageStack extends PageStackBase {
  /// Instantiate the [key] for subclasses
  const StatelessPageStack({this.key});

  /// This key will be attached to the [SWidget] that this [StatelessPageStack]
  /// describes
  ///
  /// See [SWidget.key] for more info
  final Key? key;

  @override
  @nonVirtual
  SWidget createSWidget(BuildContext context) =>
      StatelessPageStackSWidget(this, key: key ?? ValueKey(runtimeType));

  /// The page that will be build by the associated [StatelessPageStackSWidget]
  ///
  /// Since the [StatelessPageStackSWidget] is placed as the last element of
  /// [createSWidgets], if this [StatelessPageStack] is used directly in [SRouter],
  /// this will be the visible [Page]
  Page buildPage(BuildContext context);
}

mixin _DefaultBuildPage on PageStackBase {
  /// A key used (if non-null) in the [Page] built in [buildPage]
  Key? get key;

  /// {@template srouter.framework.defaultBuildPage}
  ///
  /// A default implementation of [buildPage] which returns a [Page]
  /// corresponding to the current platform:
  ///   - On iOS or macOS [CupertinoPage]
  ///   - Else [MaterialPage]
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
  Page _defaultBuildPage(
      BuildContext context, Widget build(BuildContext context)) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPage(
          key: ValueKey(key ?? runtimeType),
          child: Builder(builder: build),
        );
      default:
        return MaterialPage(
          key: ValueKey(key ?? runtimeType),
          child: Builder(builder: build),
        );
    }
  }
}

/// A superclass of [StatelessPageStack] which provides an implementation of
/// [buildPage], [pageStackBellow] and [onPop]
///
///
/// This is the primary class used in [SRouter] to describe the [Page] stack of
/// the [Navigator].
///
/// [build] will be the visible widget (the one at the top of the [Page] stack)
///
/// [pageStackBellow] provides an [PageStackBase] which describes the
/// [Page] stack to put bellow the page containing the widget from [build]
///
///
/// You can override [buildPage] if you want to build a custom [Page]. In which
/// case [build] will not be used and a dummy implementation will suffice:
/// `Widget build(BuildContext context) => Container();`
///
///
/// You an also override [onPop] to change the behavior of when pop is called
/// on this [PageStack]
abstract class PageStack extends StatelessPageStack with _DefaultBuildPage {
  /// Passes the given key to the super constructor.
  ///
  /// If non-null, this key will also be used in [buildPage] to identify the
  /// [Page] that this [PageStack] builds.
  const PageStack({Key? key}) : super(key: key);

  /// The widget which will be displayed on the screen when this [PageStack] is
  /// used directly
  ///
  ///
  /// This widget will be put inside the [Page] built in [buildPage]
  Widget build(BuildContext context);

  /// {@macro srouter.framework.defaultBuildPage}
  @override
  Page buildPage(BuildContext context) => _defaultBuildPage(context, build);

  /// By default, we don't build any [Page] bellow this one
  @override
  PageStackBase? get pageStackBellow => null;
}

/// A function to build the state [S] based on a previous value of the state
///
/// This works well with immutable states implementing a copyWith method
typedef StateBuilder<S> = S Function(S state);

/// State associated with the [MultiTabPageStack], which describes the stacks of
/// [Page]s of each tabs. It does that by storing one [PageStackBase] per tab.
///
///
/// This state is immutable, therefore a new instance should be rebuilt from
/// the previous one via a [StateBuilder]. This is what happens each time
/// [STabsSElement.update] is called
/// Subclasses should implement a copyWith method to makes this easy
@immutable
class MultiTabState extends Equatable {
  /// {@template srouter.framework.STabsState.constructor}
  ///
  /// Creates a state where:
  ///   - [activeIndex] indicate the tab which is currently shown (this is also
  ///   ^ used to know which tab to pop when onPop is called)
  ///   - [tabXPageStack] describes the [Page] stack of tab X
  ///
  /// {@endtemplate}
  MultiTabState({
    required this.activeIndex,
    required IList<PageStackBase> tabsPageStacks,
  })  : assert(
          0 <= activeIndex && activeIndex <= tabsPageStacks.length,
          'The given activeIndex ($activeIndex) is not valid, it must be between 0 and ${tabsPageStacks.length}',
        ),
        _pageStacks = tabsPageStacks;

  /// An index indicating which tab is currently active
  ///
  /// This value is used for multiple things like:
  ///   - Popping the currently active tab
  ///   - Translating the currently active tab to a WebEntry
  ///
  /// We always have: 0 <= [activeIndex] <= [_pageStacks.length] - 1
  final int activeIndex;

  /// A list containing one [PageStackBase] per tab
  ///
  ///
  /// Its length determines the number of tabs
  final IList<PageStackBase> _pageStacks;

  /// The tabs as usable [Widget] to put in the widget tree
  ///
  ///
  /// The widgets are created by [SRouter] and are [Builder]s so you don't use
  /// this to reason on the state of your tabs, use the tabs [PageStack] instead
  late final List<Widget> tabs;

  @override
  List<Object?> get props => [activeIndex, _pageStacks];
}

class MultiTabStateProvider extends InheritedWidget {
  const MultiTabStateProvider({
    Key? key,
    required Widget child,
    required this.multiTabState,
    required this.multiTabPageStack,
  }) : super(key: key, child: child);

  final MultiTabState multiTabState;
  final MultiTabPageStack multiTabPageStack;

  static MultiTabState of(BuildContext context) {
    final MultiTabStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<MultiTabStateProvider>();
    assert(result != null, 'No MultiTabStateProvider found in context');
    return result!.multiTabState;
  }

  static IList<PageStackBase> tabsPageStacksOf(BuildContext context) {
    final MultiTabStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<MultiTabStateProvider>();
    assert(result != null, 'No MultiTabStateProvider found in context');
    return result!.multiTabState._pageStacks;
  }

  static MultiTabPageStack pageStackOf(BuildContext context) {
    final MultiTabStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<MultiTabStateProvider>();
    assert(result != null, 'No MultiTabStateProvider found in context');
    return result!.multiTabPageStack;
  }

  @override
  bool updateShouldNotify(MultiTabStateProvider old) {
    return old.multiTabState != multiTabState;
  }
}

/// The element created by [_STabsSWidget]
///
/// It manages the [MultiTabState] and all the [SElement]s it creates
class STabsSElement<S extends MultiTabState> extends SElement {
  /// Initialize the [state] with the initial state of the [MultiTabPageStack]
  STabsSElement(_STabsSWidget<S> sWidget)
      : _initialState = sWidget._multiTabPageStack.initialState,
        super(sWidget);

  @override
  _STabsSWidget<S> get sWidget => super.sWidget as _STabsSWidget<S>;

  /// The state of the [MultiTabPageStack]
  ///
  /// It will first be [MultiTabPageStack.initialState], then mutate each time
  /// [update] is called by being assigned the result of
  /// [MultiTabPageStack._stateBuilder]
  ///
  /// This state is then given to [MultiTabPageStack.buildPage] and
  /// [MultiTabPageStack.onPop]
  ///
  ///
  /// The state contains page stacks which are translated into [SWidget]s, the
  /// element associated with this widgets are stored into [_tabsSElements]
  /// which is updated each time the state mutates
  S get state => _state;

  /// The value of [state]
  ///
  /// IMPORTANT: only use [_updateState] to change this variable
  late S _state;

  /// Whether [_state] has been initialized
  ///
  ///
  /// This is used in [_updateState] to avoid reading the uninitialized
  /// [_state]
  bool _isStateInitialized = false;

  /// The initial value of [_state] to use in the first state builder
  final S _initialState;

  /// The elements created by the [state]
  ///
  ///
  /// The [state] has different tabs, each tab has a [PageStackBase] which
  /// produces a list of [SElement]s. The map maps the tab index to the
  /// generated tab [SElement]s
  ///
  ///
  /// This is updated each time [state] changes, by using the method described
  /// at the top of this file (the same method Flutter uses to update its
  /// widgets and elements)
  IMap<int, IList<SElement>> get tabsSElements => _tabsSElements;
  IMap<int, IList<SElement>> _tabsSElements = IMap();

  /// The [GlobalKey] of the navigator of each tab
  ///
  /// The keys of this IMap are the same as the one of [_tabsSElements]
  IMap<int, GlobalKey<NavigatorState>> _tabsNavigatorKeys = IMap();

  /// The [HeroController] of the navigator of each tab
  ///
  /// The keys of this IMap are the same as the one of [_tabsSElements]
  IMap<int, HeroController> _tabsHeroControllers = IMap();

  /// Builds the page by calling [MultiTabPageStack.buildPage]
  ///
  /// This is also responsible for populating [state.tabs] which consist in:
  ///   1. Updating the [SElement]s associated with each tab
  ///   2. Using each tab [SElement]s to get the page_transitions to put in the nested
  ///   ^  [Navigator]
  @override
  Page buildPage(BuildContext context) {
    return sWidget._multiTabPageStack.buildPage(context, state);
  }

  /// This must be called after each [state] update
  ///
  /// This will update the [_tabsSElements] and [state.tabs]
  void _updateState(BuildContext context, {required S newState}) {
    // If the new state is the same as the old one, don't do anything
    if (_isStateInitialized && newState == state) {
      return;
    } else {
      // Set to true since it is initialized in 2 lines
      _isStateInitialized = true;
    }

    // Update [_state]
    _state = newState;

    // Update the [SElement]s of each tabs
    for (var i = 0; i < state._pageStacks.length; i++) {
      _tabsSElements = _tabsSElements.add(
        i,
        updatePageStackBaseSElements(
          context,
          oldSElements: _tabsSElements[i] ?? IList(),
          pageStack: state._pageStacks[i],
        ),
      );
      _tabsNavigatorKeys =
          _tabsNavigatorKeys.putIfAbsent(i, GlobalKey<NavigatorState>.new);
      _tabsHeroControllers =
          _tabsHeroControllers.putIfAbsent(i, HeroController.new);
    }

    state.tabs = [
      for (var _tabIndex in _tabsSElements.keys)
        MultiTabStateProvider(
          multiTabState: state,
          multiTabPageStack: sWidget._multiTabPageStack,
          child: HeroControllerScope(
            controller: _tabsHeroControllers[_tabIndex]!,
            child: Builder(
              // Use this key so that AnimatedSwitcher can easily be used to animate
              // a transition between tabs
              key: ValueKey('sRouter_tabIndex_$_tabIndex'),
              builder: (context) => Navigator(
                key: _tabsNavigatorKeys[_tabIndex]!,
                pages: _tabsSElements[_tabIndex]!
                    .map((e) => e.buildPage(context))
                    .toList(),
                onPopPage: (route, data) {
                  final didPop = route.didPop(data);

                  if (didPop) {
                    final tabSElements = _tabsSElements[_tabIndex]!;

                    // Replace the current tab pageStack (which is the last one) by
                    // the one bellow
                    //
                    // It has to exist if didPop is true
                    final tabPageStackBellow =
                        tabSElements[tabSElements.length - 2].sWidget.pageStack;
                    _updateState(
                      context,
                      newState:
                          sWidget._multiTabPageStack._buildFromMultiTabState(
                        state.activeIndex,
                        state._pageStacks
                            .replace(state.activeIndex, tabPageStackBellow),
                      ),
                    );

                    // Update SRouter
                    (SRouter.of(context) as SRouterState).update();
                  }

                  return didPop;
                },
              ),
            ),
          ),
        ),
    ];
  }

  @override
  void initialize(BuildContext context) {
    super.initialize(context);

    // We need to update the state even now because the initial
    // [_MultiTabPageStack] also has a state builder which must
    // be taken into account
    _updateState(context,
        newState: sWidget._multiTabPageStack._stateBuilder(_initialState));
  }

  /// Updates:
  ///   - [sWidget] (by calling super)
  ///   - [state] using [MultiTabPageStack._stateBuilder]
  ///   - [_tabsSElements] using the [SWidget]s generating by [state._pageStacks]
  @override
  void update(covariant _STabsSWidget<S> newSWidget, BuildContext context) {
    super.update(newSWidget, context);

    // Since [MultiTabState] is immutable, we receive a new instance where
    // the tabs have not been populated. This is why we can set the tabs in
    // [buildPage] even if [MultiTabState.tabs] is final
    _updateState(context,
        newState: newSWidget._multiTabPageStack._stateBuilder(state));
  }

  /// TODO: add comment
  @override
  SystemPopResult onSystemPop(BuildContext context) {
    final activeTabSElements = _tabsSElements[state.activeIndex]!;

    final result = activeTabSElements.last.onSystemPop(context);

    return result.when(
      parent: () {
        // We don't know if a tab bellow exists, so use getOrNull
        final tabPageStackBellow = activeTabSElements
            .getOrNull(activeTabSElements.length - 2)
            ?.sWidget
            .pageStack;

        if (tabPageStackBellow == null) {
          // If there is no [PageStack] bellow, delegate the system pop to the
          // parent
          return SystemPopResult.parent();
        }

        // If there is a [PageStack] bellow, update the state with the new tab
        // PageStack
        _updateState(
          context,
          newState: sWidget._multiTabPageStack._buildFromMultiTabState(
            state.activeIndex,
            state._pageStacks.replace(state.activeIndex, tabPageStackBellow),
          ),
        );

        return SystemPopResult.done();
      },
      done: SystemPopResult.done,
    );
  }
}

/// The [SWidget] creating the [STabsSElement]
///
/// It uses [MultiTabPageStack] as its configuration
class _STabsSWidget<S extends MultiTabState> extends SWidget {
  /// Passes the [key] to the super constructor and initializes [_multiTabPageStack]
  const _STabsSWidget(this._multiTabPageStack, {Key? key})
      : super(_multiTabPageStack, key: key);

  /// The configuration of this widget
  final MultiTabPageStack<S> _multiTabPageStack;

  @override
  SElement createSElement() => STabsSElement<S>(this);
}

/// {@template srouter.framework.STabsRoute}
///
/// An [PageStackBase] used to build a screen which has different tabs
///
///
/// Each tab is represented by an [PageStack] in the state. Each tab is therefore
/// a stack of [Page]s.
///
/// An index (named [activeIndex]) is also stored in the state, and is useful
/// to easily know which [PageStack] to display and is also used when popping to
/// call onPop the active [PageStack]
///
///
/// ### Building a widget with the different tabs
///
/// [MultiTabPageStack] is focused on providing you an easy way to build a widget
/// with different tabs, the easiest way is to implement [build] and use the
/// given state to access the tabs:
///
/// ```dart
/// build(BuildContext context, S state) {
///   return Scaffold(
///     body: state.tabs[state.activeIndex],
///       bottomNavigationBar: BottomNavigationBar(
///       currentIndex: tabsRouter.activeIndex,
///       onTap: (value) => SRouter.to(
///         My2TabsPageStack((state) => state.copyWith(activeIndex: value)),
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
/// To change the state, you have to push your [MultiTabPageStack] into [SRouter] and
/// use the [_stateBuilder] to provide the new state
///
/// For example, here is how to change the active index to be 0:
///
/// ```dart
/// SRouter.to(
///   My2TabsPageStack((state) => state.copyWith(activeIndex: 0)),
/// )
/// ```
///
///
/// ### Initial state
///
/// Since [MultiTabPageStack] uses a [_stateBuilder] to build the next state based on
/// the previous one, there has to be a first state to transition from.
///
///
/// Use the [_stateBuilder] is the constructor to go to a [MultiTabPageStack] with an
/// updated state. For example to change the active index you can use
///
///
/// Use a subclass [Multi2Tabs], [Multi3Tabs], ... which allows you to build
/// a fixed number of tabs
///
/// {@endtemplate}
abstract class MultiTabPageStack<S extends MultiTabState> extends PageStackBase
    with _DefaultBuildPage {
  /// A const constructor initializing different attributes with the given
  /// values
  ///
  /// {@template srouter.framework.STabsRoute.constructor}
  ///
  /// [stateBuilder] is used to build a new state based on the previous one.
  /// It is called each time a [MultiTabPageStack] is given to [SRouter]
  ///
  ///
  /// Example of changing the active index:
  /// ```dart
  /// My2TabsPageStack((state) => state.copyWith(activeIndex: 0))
  /// ```
  ///
  /// If you don't want to change the state, you can simply use:
  /// ```dart
  /// My2TabsPageStack((state) => state)
  /// ```
  ///
  /// {@endtemplate}
  const MultiTabPageStack(
    this._stateBuilder,
    this._buildFromMultiTabState, {
    this.key,
  });

  /// The key of the [Page] created in [buildPage] (if non-null)
  ///
  ///
  /// This key will also be attached to the [_STabsSWidget] that this
  /// [StatelessPageStack] describes, see [SWidget.key] for more info
  final Key? key;

  /// The initial state, it will be used the first time [StateBuilder] is
  /// called
  ///
  ///
  /// It is useless to change it, if you need to return a new state independent
  /// of the previous one, use [StateBuilder] and return a new instance:
  /// `(state) => _STabsState(activeIndex: ..., ...)`
  S get initialState;

  /// The widget which will be displayed on the screen when this [PageStack] is
  /// used directly
  ///
  ///
  /// This widget will be put inside the [Page] built in [buildPage]
  Widget build(BuildContext context, S state);

  /// {@macro srouter.framework.defaultBuildPage}
  Page buildPage(BuildContext context, S state) => _defaultBuildPage(
        context,
        (context) => build(context, state),
      );

  /// By default, we don't build any [Page] bellow this one
  PageStackBase? get pageStackBellow => null;

  /// Returns a new state based on the previous value of the state
  ///
  /// This is used every time a [MultiTabPageStack] is given to [SRouter]
  ///
  ///
  /// Example of changing the active index:
  /// ```dart
  /// My2TabsPageStack((state) => state.copyWith(activeIndex: 0))
  /// ```
  final StateBuilder<S> _stateBuilder;

  @override
  @nonVirtual
  SWidget createSWidget(BuildContext context) =>
      _STabsSWidget<S>(this, key: key ?? ValueKey(runtimeType));

  /// A function which build the state [S] based on the base state class
  /// [MultiTabState]
  ///
  /// It uses [MultiTabState] attributes rather than the class directly because
  /// the class [_pageStacks] attribute is private and we want to be able to
  /// create subclasses in other files
  ///
  ///
  /// This should be provided by [Multi2Tabs], [Multi3Tabs], ... and never
  /// visible to the end user
  final S Function(
    int activeIndex,
    IList<PageStackBase> tabsPageStacks,
  ) _buildFromMultiTabState;
}

/// {@template srouter.framework.STabsRouteTranslator}
///
/// A translator which is used to map a [MultiTabPageStack] to a [WebEntry]
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
/// which implementation of [MultiTabPageStack] you implemented
abstract class MultiTabTranslator<PS extends MultiTabPageStack<S>,
    S extends MultiTabState> extends STranslator<STabsSElement<S>, PS> {
  /// Returns the [MultiTabPageStack] associated with the given [WebEntry]
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
  /// [MultiTabPageStack]
  PS? Function(
    WebEntryMatch match,
    StateBuilder<S>? stateBuilder,
  ) get matchToPageStack;

  /// Returns the web entry to return web the associated [MultiTabPageStack]
  /// is pushed into [SRouter]
  ///
  ///
  /// [pageStack] is the [MultiTabPageStack]
  ///
  /// [state] is the current state of [pageStack]
  ///
  /// [activeTabWebEntry] is the web entry returned by the tab at the active
  /// index. If the active tab could not be converted to a [WebEntry] this
  /// value is null
  WebEntry Function(
    PS pageStack,
    S state,
    WebEntry? activeTabWebEntry,
  ) get pageStackToWebEntry;

  /// A class which determined whether a given [WebEntry] is valid
  WebEntryMatcher get matcher;

  /// A [STranslatorHandler] for each tab of the state
  List<TranslatorsHandler> get translatorsHandlers;

  /// A function which build the state [S] based on the base state class
  /// [MultiTabState]
  ///
  /// It uses [MultiTabState] attributes rather than the class directly because
  /// the class [_pageStacks] attribute is private and we want to be able to
  /// create subclasses in other files
  ///
  ///
  /// This should be provided by [Multi2Tabs], [Multi3Tabs], ... and never
  /// visible to the end user
  S buildFromMultiTabState(
    int activeIndex,
    IList<PageStackBase> tabsPageStacks,
  );

  @override
  WebEntry sElementToWebEntry(
    BuildContext context,
    STabsSElement<S> element,
    PS pageStack,
  ) {
    // Get the web entry returned by the active tab
    final activeIndex = element.state.activeIndex;
    final activeTabWebEntry =
        translatorsHandlers[activeIndex].getWebEntryFromSElement(
      context,
      element.tabsSElements[activeIndex]!.last,
    );

    return pageStackToWebEntry(
      pageStack,
      element.state,
      activeTabWebEntry,
    );
  }

  @override
  PS? webEntryToPageStack(BuildContext context, WebEntry webEntry) {
    final match = matcher.match(webEntry);

    if (match == null) {
      return null;
    }

    // Get the pageStack and its associated index returned from the [webEntry]
    MapEntry<int, PageStackBase>? maybeNewActiveTabPageStack;
    for (var i = 0; i < translatorsHandlers.length; i++) {
      final sTranslatorsHandler = translatorsHandlers[i];

      final pageStack =
          sTranslatorsHandler.getPageStackFromWebEntry(context, webEntry);
      if (pageStack != null) {
        maybeNewActiveTabPageStack = MapEntry(i, pageStack);
        break;
      }
    }

    return matchToPageStack(
      match,
      maybeNewActiveTabPageStack == null
          ? null
          : (state) => buildFromMultiTabState(
                maybeNewActiveTabPageStack!.key,
                state._pageStacks.replace(
                  maybeNewActiveTabPageStack.key,
                  maybeNewActiveTabPageStack.value,
                ),
              ),
    );
  }
}
