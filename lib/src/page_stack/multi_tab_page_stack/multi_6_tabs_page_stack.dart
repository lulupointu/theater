import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../nested_stack.dart';

/// The state of [Multi6TabsPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [Multi6TabsPageStack] is pushed)
@immutable
class Multi6TabsState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  Multi6TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
    required this.tab3SRoute,
    required this.tab4SRoute,
    required this.tab5SRoute,
    required this.tab6SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [
            tab1SRoute,
            tab2SRoute,
            tab3SRoute,
            tab4SRoute,
            tab5SRoute,
            tab6SRoute,
          ].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] corresponding to the first tab (index 0)
  final PageStackBase<NestedStack> tab1SRoute;

  /// The [PageStackBase] corresponding to the second tab (index 1)
  final PageStackBase<NestedStack> tab2SRoute;

  /// The [PageStackBase] corresponding to the third tab (index 2)
  final PageStackBase<NestedStack> tab3SRoute;

  /// The [PageStackBase] corresponding to the third tab (index 3)
  final PageStackBase<NestedStack> tab4SRoute;

  /// The [PageStackBase] corresponding to the third tab (index 4)
  final PageStackBase<NestedStack> tab5SRoute;

  /// The [PageStackBase] corresponding to the third tab (index 5)
  final PageStackBase<NestedStack> tab6SRoute;

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
    PageStackBase<NestedStack>? tab1SRoute,
    PageStackBase<NestedStack>? tab2SRoute,
    PageStackBase<NestedStack>? tab3SRoute,
    PageStackBase<NestedStack>? tab4SRoute,
    PageStackBase<NestedStack>? tab5SRoute,
    PageStackBase<NestedStack>? tab6SRoute,
  }) {
    return Multi6TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
      tab3SRoute: tab3SRoute ?? this.tab3SRoute,
      tab4SRoute: tab4SRoute ?? this.tab4SRoute,
      tab5SRoute: tab5SRoute ?? this.tab5SRoute,
      tab6SRoute: tab6SRoute ?? this.tab6SRoute,
    );
  }

  /// Creates a [Multi6TabsState] from a [_STabsState], internal use only
  factory Multi6TabsState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase<NestedStack>> sRoutes,
  ) =>
      Multi6TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
        tab3SRoute: sRoutes[2],
        tab4SRoute: sRoutes[3],
        tab5SRoute: sRoutes[4],
        tab6SRoute: sRoutes[5],
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy to build screens
/// with 6 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class Multi6TabsPageStack<N extends MaybeNestedStack> extends MultiTabPageStack<Multi6TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  Multi6TabsPageStack(StateBuilder<Multi6TabsState> stateBuilder)
      : super(stateBuilder, Multi6TabsState._fromSTabsState);
}
