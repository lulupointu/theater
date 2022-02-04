import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';

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
  final PageStackBase tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  final PageStackBase tab3PageStack;


  /// A list of 3 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [Multi3TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  Multi3TabsState copyWith({
    int? activeIndex,
    PageStackBase? tab1PageStack,
    PageStackBase? tab2PageStack,
    PageStackBase? tab3PageStack,
  }) {
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
        tab1PageStack: sRoutes[0],
        tab2PageStack: sRoutes[1],
        tab3PageStack: sRoutes[2],
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
