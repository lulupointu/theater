import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../s_nested.dart';

/// The state of [S2TabsRoute], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [S2TabsRoute] is pushed)
@immutable
class S2TabsState extends STabsState {
  /// {@macro srouter.framework.STabsState.constructor}
  S2TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsSRoutes: [tab1SRoute, tab2SRoute].lock,
        );

  @override
  final int activeIndex;

  /// The [SRouteBase] corresponding to the first tab (index 0)
  final SRouteBase<SNested> tab1SRoute;

  /// The [SRouteBase] corresponding to the second tab (index 1)
  final SRouteBase<SNested> tab2SRoute;

  /// A list of 2 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [SRouteBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [S2TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  S2TabsState copyWith({
    int? activeIndex,
    SRouteBase<SNested>? tab1SRoute,
    SRouteBase<SNested>? tab2SRoute,
  }) {
    return S2TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
    );
  }

  /// Creates a [S2TabsState] from a [_STabsState], internal use only
  factory S2TabsState._fromSTabsState(
    int activeIndex,
    IList<SRouteBase<SNested>> sRoutes,
  ) =>
      S2TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
      );
}

/// An implementation of [STabsRoute] which makes it easy to build screens
/// with 2 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class S2TabsRoute<N extends MaybeSNested> extends STabsRoute<S2TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  S2TabsRoute(StateBuilder<S2TabsState> stateBuilder)
      : super(stateBuilder, S2TabsState._fromSTabsState);
}
