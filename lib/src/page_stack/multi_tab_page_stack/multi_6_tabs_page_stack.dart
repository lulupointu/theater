import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tab_x_in.dart';

/// The state of [Multi6TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi6TabsPageStack] is pushed)
@immutable
class Multi6TabsState extends MultiTabState {
  /// {@macro theater.framework.MultiTabState.constructor}
  Multi6TabsState({
    required this.currentIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
    required this.tab4PageStack,
    required this.tab5PageStack,
    required this.tab6PageStack,
  })  : tabsPageStacks = IList([
          tab1PageStack,
          tab2PageStack,
          tab3PageStack,
          tab4PageStack,
          tab5PageStack,
          tab6PageStack,
        ]),
        super(
          currentIndex: currentIndex,
          tabsPageStacks: [
            tab1PageStack,
            tab2PageStack,
            tab3PageStack,
            tab4PageStack,
            tab5PageStack,
            tab6PageStack,
          ].lock,
        );

  @override
  final int currentIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  ///
  /// [tab1PageStack] must implement the [Tab1In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab1In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab1In<Multi6TabsPageStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  ///
  /// [tab2PageStack] must implement the [Tab2In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab2In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab2In<Multi6TabsPageStack> tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  ///
  /// [tab3PageStack] must implement the [Tab3In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab3In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab3In<Multi6TabsPageStack> tab3PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  ///
  /// [tab4PageStack] must implement the [Tab4In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab4In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab4In<Multi6TabsPageStack> tab4PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 4)
  ///
  /// [tab5PageStack] must implement the [Tab5In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab5In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab5In<Multi6TabsPageStack> tab5PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 5)
  ///
  /// [tab6PageStack] must implement the [Tab6In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab6In<MyMulti6TabsPageStack> {...}
  /// ```
  final Tab6In<Multi6TabsPageStack> tab6PageStack;

  /// A list of 6 [PageStack], one for each tab
  @override
  final IList<TabXOf6<Multi6TabsPageStack>> tabsPageStacks;

  /// Builds a copy of this [Multi6TabsState] where
  ///   - [pageStack] will replace the [PageStack] of its corresponding tab
  ///   - The index corresponding to [pageStack] will be set as the current index
  ///
  /// [TabXOf6] is either a [Tab1In], [Tab2In], [Tab3In], [Tab4In], [Tab5In], or
  /// [Tab6In] mixin.
  Multi6TabsState withCurrentStack<PS extends Multi6TabsPageStack>(
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
                    : pageStack is Tab5In<PS>
                        ? 4
                        : pageStack is Tab6In<PS>
                            ? 5
                            : throw 'The index of the pageStack $pageStack could not be determined, does it implement [Tab1In], [Tab2In], [Tab3In], [Tab4In], [Tab5In] or [Tab6In]?';
    return copyWith(
      currentIndex: index,
      tab1PageStack: index == 0 ? pageStack as Tab1In<PS> : tab1PageStack,
      tab2PageStack: index == 1 ? pageStack as Tab2In<PS> : tab2PageStack,
      tab3PageStack: index == 2 ? pageStack as Tab3In<PS> : tab3PageStack,
      tab4PageStack: index == 3 ? pageStack as Tab4In<PS> : tab4PageStack,
      tab5PageStack: index == 4 ? pageStack as Tab5In<PS> : tab5PageStack,
      tab6PageStack: index == 5 ? pageStack as Tab6In<PS> : tab6PageStack,
    );
  }

  /// Builds a copy of this [Multi6TabsState] where [index] will be set as the
  /// current index
  ///
  /// 0 <= [index] <= 5
  Multi6TabsState withCurrentIndex<PS extends Multi6TabsPageStack>(int index) {
    return copyWith(currentIndex: index);
  }

  /// Builds a copy of this [Multi6TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi6TabsState copyWith({
    int? currentIndex,
    Tab1In<Multi6TabsPageStack>? tab1PageStack,
    Tab2In<Multi6TabsPageStack>? tab2PageStack,
    Tab3In<Multi6TabsPageStack>? tab3PageStack,
    Tab4In<Multi6TabsPageStack>? tab4PageStack,
    Tab5In<Multi6TabsPageStack>? tab5PageStack,
    Tab6In<Multi6TabsPageStack>? tab6PageStack,
  }) {
    assert(
      currentIndex == null || (0 <= currentIndex && currentIndex <= 5),
      'The given currentIndex ($currentIndex) is not valid, it must be between 0 and 5',
    );

    return Multi6TabsState(
      currentIndex: currentIndex ?? this.currentIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
      tab4PageStack: tab4PageStack ?? this.tab4PageStack,
      tab5PageStack: tab5PageStack ?? this.tab5PageStack,
      tab6PageStack: tab6PageStack ?? this.tab6PageStack,
    );
  }

  /// Creates a [Multi6TabsState] from a [_MultiTabState], internal use only
  factory Multi6TabsState._fromMultiTabState(
    int currentIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi6TabsState(
        currentIndex: currentIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi6TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi6TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi6TabsPageStack>,
        tab4PageStack: sRoutes[3] as Tab4In<Multi6TabsPageStack>,
        tab5PageStack: sRoutes[4] as Tab5In<Multi6TabsPageStack>,
        tab6PageStack: sRoutes[5] as Tab6In<Multi6TabsPageStack>,
      );
}

/// An implementation of [MultiTabsPageStack] which makes it easy to build screens
/// with 6 tabs.
///
/// {@macro theater.framework.STabsRoute}
abstract class Multi6TabsPageStack extends MultiTabsPageStack<Multi6TabsState> {
  /// {@macro theater.framework.STabsRoute.constructor}
  @mustCallSuper
  const Multi6TabsPageStack(StateBuilder<Multi6TabsState> stateBuilder)
      : super(stateBuilder, Multi6TabsState._fromMultiTabState);
}
