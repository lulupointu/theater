import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../nested_stack.dart';

/// The state of [Multi3TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi3TabsPageStack] is pushed)
@immutable
class Multi3TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi3TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
    required this.tab3SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [tab1SRoute, tab2SRoute, tab3SRoute].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  final PageStackBase<NestedStack> tab1SRoute;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase<NestedStack> tab2SRoute;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  final PageStackBase<NestedStack> tab3SRoute;


  /// A list of 3 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi3TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi3TabsState copyWith({
    int? activeIndex,
    PageStackBase<NestedStack>? tab1SRoute,
    PageStackBase<NestedStack>? tab2SRoute,
    PageStackBase<NestedStack>? tab3SRoute,
  }) {
    return Multi3TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
      tab3SRoute: tab3SRoute ?? this.tab3SRoute,
    );
  }

  /// Creates a [Multi3TabsState] from a [_STabsState], internal use only
  factory Multi3TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase<NestedStack>> sRoutes,
  ) =>
      Multi3TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
        tab3SRoute: sRoutes[2],
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 3 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi3TabsPageStack<N extends MaybeNestedStack> extends MultiTabPageStack<Multi3TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi3TabsPageStack(StateBuilder<Multi3TabsState> stateBuilder)
      : super(stateBuilder, Multi3TabsState._fromSTabsState);
}
