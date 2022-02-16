import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

/// The state of [Multi6TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi6TabsPageStack] is pushed)
@immutable
class Multi6TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi6TabsState({
    required this.activeIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
    required this.tab4PageStack,
    required this.tab5PageStack,
    required this.tab6PageStack,
  }) : super(
          activeIndex: activeIndex,
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
  final int activeIndex;

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

  /// A list of 6 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi6TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi6TabsState copyWith({
    int? activeIndex,
    Tab1In<Multi6TabsPageStack>? tab1PageStack,
    Tab2In<Multi6TabsPageStack>? tab2PageStack,
    Tab3In<Multi6TabsPageStack>? tab3PageStack,
    Tab4In<Multi6TabsPageStack>? tab4PageStack,
    Tab5In<Multi6TabsPageStack>? tab5PageStack,
    Tab6In<Multi6TabsPageStack>? tab6PageStack,
  }) {
    return Multi6TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
      tab4PageStack: tab4PageStack ?? this.tab4PageStack,
      tab5PageStack: tab5PageStack ?? this.tab5PageStack,
      tab6PageStack: tab6PageStack ?? this.tab6PageStack,
    );
  }

  /// Creates a [Multi6TabsState] from a [_STabsState], internal use only
  factory Multi6TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi6TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi6TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi6TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi6TabsPageStack>,
        tab4PageStack: sRoutes[3] as Tab4In<Multi6TabsPageStack>,
        tab5PageStack: sRoutes[4] as Tab5In<Multi6TabsPageStack>,
        tab6PageStack: sRoutes[5] as Tab6In<Multi6TabsPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 6 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi6TabsPageStack extends MultiTabPageStack<Multi6TabsState> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi6TabsPageStack(StateBuilder<Multi6TabsState> stateBuilder)
      : super(stateBuilder, Multi6TabsState._fromSTabsState);
}
