import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';

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
  final PageStackBase tab1PageStack;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase tab2PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  final PageStackBase tab3PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  final PageStackBase tab4PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 4)
  final PageStackBase tab5PageStack;

  /// The [PageStackBase] corresponding to the third tab (index 5)
  final PageStackBase tab6PageStack;

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
    PageStackBase? tab1PageStack,
    PageStackBase? tab2PageStack,
    PageStackBase? tab3PageStack,
    PageStackBase? tab4PageStack,
    PageStackBase? tab5PageStack,
    PageStackBase? tab6PageStack,
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
        tab1PageStack: sRoutes[0],
        tab2PageStack: sRoutes[1],
        tab3PageStack: sRoutes[2],
        tab4PageStack: sRoutes[3],
        tab5PageStack: sRoutes[4],
        tab6PageStack: sRoutes[5],
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
