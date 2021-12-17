import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../nested_stack.dart';

/// The state of [Multi2TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi2TabsPageStack] is pushed)
@immutable
class Multi2TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi2TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [tab1SRoute, tab2SRoute].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  final PageStackBase<NestedStack> tab1SRoute;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase<NestedStack> tab2SRoute;

  /// A list of 2 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi2TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi2TabsState copyWith({
    int? activeIndex,
    PageStackBase<NestedStack>? tab1SRoute,
    PageStackBase<NestedStack>? tab2SRoute,
  }) {
    return Multi2TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
    );
  }

  /// Creates a [Multi2TabsState] from a [_STabsState], internal use only
  factory Multi2TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase<NestedStack>> sRoutes,
  ) =>
      Multi2TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 2 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi2TabsPageStack<N extends MaybeNestedStack> extends MultiTabPageStack<Multi2TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi2TabsPageStack(StateBuilder<Multi2TabsState> stateBuilder)
      : super(stateBuilder, Multi2TabsState._fromSTabsState);
}
