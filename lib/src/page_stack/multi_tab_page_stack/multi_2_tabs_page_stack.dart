import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tab_x_in.dart';

/// The state of [Multi2TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi2TabsPageStack] is pushed)
@immutable
class Multi2TabsState extends MultiTabState {
  /// {@macro theater.framework.MultiTabState.constructor}
  Multi2TabsState({
    required this.currentIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
  })  : tabsPageStacks = IList([tab1PageStack, tab2PageStack]),
        super(
          currentIndex: currentIndex,
          tabsPageStacks: [tab1PageStack, tab2PageStack].lock,
        );

  @override
  final int currentIndex;

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

  /// A list of 2 [PageStack], one for each tab
  @override
  final IList<TabXOf2<Multi2TabsPageStack>> tabsPageStacks;

  /// Builds a copy of this [Multi2TabsState] where
  ///   - [pageStack] will replace the [PageStack] of its corresponding tab
  ///   - The index corresponding to [pageStack] will be set as the current index
  ///
  /// [TabXOf2] is either a [Tab1In], [Tab2In] mixin
  Multi2TabsState withCurrentStack<PS extends Multi2TabsPageStack>(
    TabXOf2<PS> pageStack,
  ) {
    final index = pageStack is Tab1In<PS>
        ? 0
        : pageStack is Tab2In<PS>
            ? 1
            : throw 'The index of the pageStack $pageStack could not be determined, does it implement [Tab1In], [Tab2In]?';
    return copyWith(
      currentIndex: index,
      tab1PageStack: index == 0 ? pageStack as Tab1In<PS> : tab1PageStack,
      tab2PageStack: index == 1 ? pageStack as Tab2In<PS> : tab2PageStack,
    );
  }

  /// Builds a copy of this [Multi3TabsState] where [index] will be set as the
  /// current index
  ///
  /// 0 <= [index] <= 1
  Multi2TabsState withCurrentIndex<PS extends Multi2TabsState>(int index) {
    return copyWith(currentIndex: index);
  }

  /// Builds a copy of this [Multi2TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi2TabsState copyWith({
    int? currentIndex,
    Tab1In<Multi2TabsPageStack>? tab1PageStack,
    Tab2In<Multi2TabsPageStack>? tab2PageStack,
  }) {
    assert(
      currentIndex == null || (0 <= currentIndex && currentIndex <= 1),
      'The given currentIndex ($currentIndex) is not valid, it must be between 0 and 1',
    );

    return Multi2TabsState(
      currentIndex: currentIndex ?? this.currentIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
    );
  }

  /// Creates a [Multi2TabsState] from a [_MultiTabState], internal use only
  factory Multi2TabsState._fromMultiTabState(
    int currentIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi2TabsState(
        currentIndex: currentIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi2TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi2TabsPageStack>,
      );
}

/// An implementation of [MultiTabsPageStack] which makes it easy to build screens
/// with 2 tabs.
///
/// {@macro theater.framework.STabsRoute}
abstract class Multi2TabsPageStack extends MultiTabsPageStack<Multi2TabsState> {
  /// {@macro theater.framework.STabsRoute.constructor}
  const Multi2TabsPageStack(StateBuilder<Multi2TabsState> stateBuilder)
      : super(stateBuilder, Multi2TabsState._fromMultiTabState);
}
