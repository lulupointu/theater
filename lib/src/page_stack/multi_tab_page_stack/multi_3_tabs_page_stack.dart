import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

/// The state of [Multi3TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi3TabsPageStack] is pushed)
@immutable
class Multi3TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi3TabsState({
    required this.activeIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [tab1PageStack, tab2PageStack, tab3PageStack].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  ///
  /// [tab1PageStack] must implement the [Tab1In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab1In<MyMulti3TabsPageStack> {...}
  /// ```
  final Tab1In<Multi3TabsPageStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  ///
  /// [tab2PageStack] must implement the [Tab2In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab2In<MyMulti3TabsPageStack> {...}
  /// ```
  final Tab2In<Multi3TabsPageStack> tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  ///
  /// [tab3PageStack] must implement the [Tab3In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab3In<MyMulti3TabsPageStack> {...}
  /// ```
  final Tab3In<Multi3TabsPageStack> tab3PageStack;

  /// A list of 3 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi3TabsState] where
  ///   - [pageStack] will replace the [PageStack] of its corresponding tab
  ///   - The index corresponding to [pageStack] will be set as the active index
  ///
  /// [TabXOf3] is either a [Tab1In], [Tab2In] or [Tab3In] mixin
  Multi3TabsState withActiveStack<PS extends Multi3TabsPageStack>(
    TabXOf3<PS>? pageStack,
  ) {
    final index = pageStack is Tab1In<PS>
        ? 0
        : pageStack is Tab2In<PS>
            ? 1
            : pageStack is Tab3In<PS>
                ? 2
                : throw 'The index of the pageStack $pageStack could not be determined, does it implement [Tab1In], [Tab2In] or [Tab3In]?';
    return copyWith(
      activeIndex: index,
      tab1PageStack: index == 0 ? pageStack as Tab1In<PS> : tab1PageStack,
      tab2PageStack: index == 1 ? pageStack as Tab2In<PS> : tab2PageStack,
      tab3PageStack: index == 2 ? pageStack as Tab3In<PS> : tab3PageStack,
    );
  }

  /// Builds a copy of this [Multi3TabsState] where [index] will be set as the
  /// active index
  ///
  /// 0 <= [index] <= 2
  Multi3TabsState withActiveIndex<PS extends Multi3TabsPageStack>(int index) {
    return copyWith(activeIndex: index);
  }

  /// Builds a copy of this [Multi3TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi3TabsState copyWith({
    int? activeIndex,
    Tab1In<Multi3TabsPageStack>? tab1PageStack,
    Tab2In<Multi3TabsPageStack>? tab2PageStack,
    Tab3In<Multi3TabsPageStack>? tab3PageStack,
  }) {
    assert(
      activeIndex == null || (0 <= activeIndex && activeIndex <= 2),
      'The given activeIndex ($activeIndex) is not valid, it must be between 0 and 2',
    );

    return Multi3TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
    );
  }

  /// Creates a [Multi3TabsState] from a [_STabsState], internal use only
  factory Multi3TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi3TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi3TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi3TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi3TabsPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 3 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi3TabsPageStack extends MultiTabPageStack<Multi3TabsState> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi3TabsPageStack(StateBuilder<Multi3TabsState> stateBuilder)
      : super(stateBuilder, Multi3TabsState._fromSTabsState);
}
