import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../s_nested.dart';

/// The state of [S5TabsRoute], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [S5TabsRoute] is pushed)
@immutable
class S5TabsState extends STabsState {
  /// {@macro srouter.framework.STabsState.constructor}
  S5TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
    required this.tab3SRoute,
    required this.tab4SRoute,
    required this.tab5SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsSRoutes: [
            tab1SRoute,
            tab2SRoute,
            tab3SRoute,
            tab4SRoute,
            tab5SRoute,
          ].lock,
        );

  @override
  final int activeIndex;

  /// The [SRouteBase] corresponding to the first tab (index 0)
  final SRouteBase<SNested> tab1SRoute;

  /// The [SRouteBase] corresponding to the second tab (index 1)
  final SRouteBase<SNested> tab2SRoute;

  /// The [SRouteBase] corresponding to the third tab (index 2)
  final SRouteBase<SNested> tab3SRoute;

  /// The [SRouteBase] corresponding to the third tab (index 3)
  final SRouteBase<SNested> tab4SRoute;

  /// The [SRouteBase] corresponding to the third tab (index 4)
  final SRouteBase<SNested> tab5SRoute;

  /// A list of 5 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [SRouteBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [S5TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  S5TabsState copyWith({
    int? activeIndex,
    SRouteBase<SNested>? tab1SRoute,
    SRouteBase<SNested>? tab2SRoute,
    SRouteBase<SNested>? tab3SRoute,
    SRouteBase<SNested>? tab4SRoute,
    SRouteBase<SNested>? tab5SRoute,
  }) {
    return S5TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
      tab3SRoute: tab3SRoute ?? this.tab3SRoute,
      tab4SRoute: tab4SRoute ?? this.tab4SRoute,
      tab5SRoute: tab5SRoute ?? this.tab5SRoute,
    );
  }

  /// Creates a [S5TabsState] from a [_STabsState], internal use only
  factory S5TabsState._fromSTabsState(
    int activeIndex,
    IList<SRouteBase<SNested>> sRoutes,
  ) =>
      S5TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
        tab3SRoute: sRoutes[2],
        tab4SRoute: sRoutes[3],
        tab5SRoute: sRoutes[4],
      );
}

/// An implementation of [STabsRoute] which makes it easy to build screens
/// with 5 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class S5TabsRoute<N extends MaybeSNested> extends STabsRoute<S5TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  S5TabsRoute(StateBuilder<S5TabsState> stateBuilder)
      : super(stateBuilder, S5TabsState._fromSTabsState);
}
