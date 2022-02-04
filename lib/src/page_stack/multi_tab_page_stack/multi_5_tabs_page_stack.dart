import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';

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
  final PageStackBase tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  final PageStackBase tab3PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  final PageStackBase tab4PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 4)
  final PageStackBase tab5PageStack;

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
    PageStackBase? tab1PageStack,
    PageStackBase? tab2PageStack,
    PageStackBase? tab3PageStack,
    PageStackBase? tab4PageStack,
    PageStackBase? tab5PageStack,
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
        tab1PageStack: sRoutes[0],
        tab2PageStack: sRoutes[1],
        tab3PageStack: sRoutes[2],
        tab4PageStack: sRoutes[3],
        tab5PageStack: sRoutes[4],
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
