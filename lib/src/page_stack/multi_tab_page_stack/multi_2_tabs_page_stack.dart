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
    required this.tab1PageStack,
    required this.tab2PageStack,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [tab1PageStack, tab2PageStack].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  final PageStackBase<NestedStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase<NestedStack> tab2PageStack;

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
    PageStackBase<NestedStack>? tab1PageStack,
    PageStackBase<NestedStack>? tab2PageStack,
  }) {
    return Multi2TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
    );
  }

  /// Creates a [Multi2TabsState] from a [_STabsState], internal use only
  factory Multi2TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase<NestedStack>> sRoutes,
  ) =>
      Multi2TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0],
        tab2PageStack: sRoutes[1],
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
