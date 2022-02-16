import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

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
  ///
  /// [tab1PageStack] must implement the [Tab1In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab1In<MyMulti2TabsPageStack> {...}
  /// ```
  final Tab1In<Multi2TabsPageStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  ///
  /// [tab2PageStack] must implement the [Tab2In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab2In<MyMulti2TabsPageStack> {...}
  /// ```
  final Tab2In<Multi2TabsPageStack> tab2PageStack;

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
    Tab1In<Multi2TabsPageStack>? tab1PageStack,
    Tab2In<Multi2TabsPageStack>? tab2PageStack,
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
    IList<PageStackBase> sRoutes,
  ) =>
      Multi2TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi2TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi2TabsPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 2 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi2TabsPageStack extends MultiTabPageStack<Multi2TabsState> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi2TabsPageStack(StateBuilder<Multi2TabsState> stateBuilder)
      : super(stateBuilder, Multi2TabsState._fromSTabsState);
}
