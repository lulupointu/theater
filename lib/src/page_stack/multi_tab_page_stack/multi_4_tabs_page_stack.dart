import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tab_x_in.dart';

/// The state of [Multi4TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi4TabsPageStack] is pushed)
@immutable
class Multi4TabsState extends MultiTabState {
  /// {@macro theater.framework.MultiTabState.constructor}
  Multi4TabsState({
    required this.currentIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
    required this.tab4PageStack,
  })  : tabsPageStacks = IList([
          tab1PageStack,
          tab2PageStack,
          tab3PageStack,
          tab4PageStack,
        ]),
        super(
          currentIndex: currentIndex,
          tabsPageStacks: [
            tab1PageStack,
            tab2PageStack,
            tab3PageStack,
            tab4PageStack,
          ].lock,
        );

  @override
  final int currentIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  ///
  /// [tab1PageStack] must implement the [Tab1In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab1In<MyMulti4TabsPageStack> {...}
  /// ```
  final Tab1In<Multi4TabsPageStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  ///
  /// [tab2PageStack] must implement the [Tab2In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab2In<MyMulti4TabsPageStack> {...}
  /// ```
  final Tab2In<Multi4TabsPageStack> tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  ///
  /// [tab3PageStack] must implement the [Tab3In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab3In<MyMulti4TabsPageStack> {...}
  /// ```
  final Tab3In<Multi4TabsPageStack> tab3PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  ///
  /// [tab4PageStack] must implement the [Tab4In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab4In<MyMulti4TabsPageStack> {...}
  /// ```
  final Tab4In<Multi4TabsPageStack> tab4PageStack;

  /// A list of 4 [PageStack], one for each tab
  @override
  final IList<TabXOf4<Multi4TabsPageStack>> tabsPageStacks;

  /// Builds a copy of this [Multi4TabsState] where
  ///   - [pageStack] will replace the [PageStack] of its corresponding tab
  ///   - The index corresponding to [pageStack] will be set as the current index
  ///
  /// [TabXOf4] is either a [Tab1In], [Tab2In], [Tab3In] or [Tab4In] mixin.
  Multi4TabsState withCurrentStack<PS extends Multi4TabsPageStack>(
    TabXOf3<PS> pageStack,
  ) {
    final index = pageStack is Tab1In<PS>
        ? 0
        : pageStack is Tab2In<PS>
            ? 1
            : pageStack is Tab3In<PS>
                ? 2
                : pageStack is Tab4In<PS>
                    ? 3
                    : throw 'The index of the pageStack $pageStack could not be determined, does it implement [Tab1In], [Tab2In], [Tab3In] or [Tab4In]?';
    return copyWith(
      currentIndex: index,
      tab1PageStack: index == 0 ? pageStack as Tab1In<PS> : tab1PageStack,
      tab2PageStack: index == 1 ? pageStack as Tab2In<PS> : tab2PageStack,
      tab3PageStack: index == 2 ? pageStack as Tab3In<PS> : tab3PageStack,
      tab4PageStack: index == 3 ? pageStack as Tab4In<PS> : tab4PageStack,
    );
  }

  /// Builds a copy of this [Multi4TabsState] where [index] will be set as the
  /// current index
  ///
  /// 0 <= [index] <= 3
  Multi4TabsState withCurrentIndex<PS extends Multi4TabsState>(int index) {
    return copyWith(currentIndex: index);
  }

  /// Builds a copy of this [Multi4TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi4TabsState copyWith({
    int? currentIndex,
    Tab1In<Multi4TabsPageStack>? tab1PageStack,
    Tab2In<Multi4TabsPageStack>? tab2PageStack,
    Tab3In<Multi4TabsPageStack>? tab3PageStack,
    Tab4In<Multi4TabsPageStack>? tab4PageStack,
  }) {
    assert(
      currentIndex == null || (0 <= currentIndex && currentIndex <= 3),
      'The given currentIndex ($currentIndex) is not valid, it must be between 0 and 3',
    );

    return Multi4TabsState(
      currentIndex: currentIndex ?? this.currentIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
      tab4PageStack: tab4PageStack ?? this.tab4PageStack,
    );
  }

  /// Creates a [Multi4TabsState] from a [_MultiTabState], internal use only
  factory Multi4TabsState._fromMultiTabState(
    int currentIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi4TabsState(
        currentIndex: currentIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi4TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi4TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi4TabsPageStack>,
        tab4PageStack: sRoutes[3] as Tab4In<Multi4TabsPageStack>,
      );
}

/// An implementation of [MultiTabsPageStack] which makes it easy to build screens
/// with 4 tabs.
///
/// {@macro theater.framework.STabsRoute}
abstract class Multi4TabsPageStack extends MultiTabsPageStack<Multi4TabsState> {
  /// {@macro theater.framework.STabsRoute.constructor}
  const Multi4TabsPageStack(StateBuilder<Multi4TabsState> stateBuilder)
      : super(stateBuilder, Multi4TabsState._fromMultiTabState);
}
