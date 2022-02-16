import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

/// The state of [Multi5TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi5TabsPageStack] is pushed)
@immutable
class Multi5TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi5TabsState({
    required this.activeIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
    required this.tab4PageStack,
    required this.tab5PageStack,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [
            tab1PageStack,
            tab2PageStack,
            tab3PageStack,
            tab4PageStack,
            tab5PageStack,
          ].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  ///
  /// [tab1PageStack] must implement the [Tab1In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab1In<MyMulti5TabsPageStack> {...}
  /// ```
  final Tab1In<Multi5TabsPageStack> tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  ///
  /// [tab2PageStack] must implement the [Tab2In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab2In<MyMulti5TabsPageStack> {...}
  /// ```
  final Tab2In<Multi5TabsPageStack> tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  ///
  /// [tab3PageStack] must implement the [Tab3In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab3In<MyMulti5TabsPageStack> {...}
  /// ```
  final Tab3In<Multi5TabsPageStack> tab3PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  ///
  /// [tab4PageStack] must implement the [Tab4In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab4In<MyMulti5TabsPageStack> {...}
  /// ```
  final Tab4In<Multi5TabsPageStack> tab4PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 4)
  ///
  /// [tab5PageStack] must implement the [Tab5In] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with Tab5In<MyMulti5TabsPageStack> {...}
  /// ```
  final Tab5In<Multi5TabsPageStack> tab5PageStack;

  /// A list of 5 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi5TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi5TabsState copyWith({
    int? activeIndex,
    Tab1In<Multi5TabsPageStack>? tab1PageStack,
    Tab2In<Multi5TabsPageStack>? tab2PageStack,
    Tab3In<Multi5TabsPageStack>? tab3PageStack,
    Tab4In<Multi5TabsPageStack>? tab4PageStack,
    Tab5In<Multi5TabsPageStack>? tab5PageStack,
  }) {
    return Multi5TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
      tab4PageStack: tab4PageStack ?? this.tab4PageStack,
      tab5PageStack: tab5PageStack ?? this.tab5PageStack,
    );
  }

  /// Creates a [Multi5TabsState] from a [_STabsState], internal use only
  factory Multi5TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi5TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi5TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi5TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi5TabsPageStack>,
        tab4PageStack: sRoutes[3] as Tab4In<Multi5TabsPageStack>,
        tab5PageStack: sRoutes[4] as Tab5In<Multi5TabsPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 5 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi5TabsPageStack extends MultiTabPageStack<Multi5TabsState> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi5TabsPageStack(StateBuilder<Multi5TabsState> stateBuilder)
      : super(stateBuilder, Multi5TabsState._fromSTabsState);
}
