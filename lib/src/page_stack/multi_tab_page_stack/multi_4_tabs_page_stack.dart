import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

/// The state of [Multi4TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi4TabsPageStack] is pushed)
@immutable
class Multi4TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi4TabsState({
    required this.activeIndex,
    required this.tab1PageStack,
    required this.tab2PageStack,
    required this.tab3PageStack,
    required this.tab4PageStack,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [tab1PageStack, tab2PageStack, tab3PageStack, tab4PageStack].lock,
        );

  @override
  final int activeIndex;

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

  /// A list of 4 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi4TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi4TabsState copyWith({
    int? activeIndex,
    Tab1In<Multi4TabsPageStack>? tab1PageStack,
    Tab2In<Multi4TabsPageStack>? tab2PageStack,
    Tab3In<Multi4TabsPageStack>? tab3PageStack,
    Tab4In<Multi4TabsPageStack>? tab4PageStack,
  }) {
    return Multi4TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1PageStack: tab1PageStack ?? this.tab1PageStack,
      tab2PageStack: tab2PageStack ?? this.tab2PageStack,
      tab3PageStack: tab3PageStack ?? this.tab3PageStack,
      tab4PageStack: tab4PageStack ?? this.tab4PageStack,
    );
  }

  /// Creates a [Multi4TabsState] from a [_STabsState], internal use only
  factory Multi4TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      Multi4TabsState(
        activeIndex: activeIndex,
        tab1PageStack: sRoutes[0] as Tab1In<Multi4TabsPageStack>,
        tab2PageStack: sRoutes[1] as Tab2In<Multi4TabsPageStack>,
        tab3PageStack: sRoutes[2] as Tab3In<Multi4TabsPageStack>,
        tab4PageStack: sRoutes[3] as Tab4In<Multi4TabsPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 4 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi4TabsPageStack extends MultiTabPageStack<Multi4TabsState> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi4TabsPageStack(StateBuilder<Multi4TabsState> stateBuilder)
      : super(stateBuilder, Multi4TabsState._fromSTabsState);
}
