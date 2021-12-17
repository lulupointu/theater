import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../s_nested.dart';

/// The state of [S3TabsRoute], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [S3TabsRoute] is pushed)
@immutable
class S3TabsState extends STabsState {
  /// {@macro srouter.framework.STabsState.constructor}
  S3TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
    required this.tab3SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsSRoutes: [tab1SRoute, tab2SRoute, tab3SRoute].lock,
        );

  @override
  final int activeIndex;

  /// The [SRouteBase] corresponding to the first tab (index 0)
  final SRouteBase<SNested> tab1SRoute;

  /// The [SRouteBase] corresponding to the second tab (index 1)
  final SRouteBase<SNested> tab2SRoute;

  /// The [SRouteBase] corresponding to the third tab (index 2)
  final SRouteBase<SNested> tab3SRoute;


  /// A list of 3 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [SRouteBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [S3TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  S3TabsState copyWith({
    int? activeIndex,
    SRouteBase<SNested>? tab1SRoute,
    SRouteBase<SNested>? tab2SRoute,
    SRouteBase<SNested>? tab3SRoute,
  }) {
    return S3TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
      tab3SRoute: tab3SRoute ?? this.tab3SRoute,
    );
  }

  /// Creates a [S3TabsState] from a [_STabsState], internal use only
  factory S3TabsState._fromSTabsState(
    int activeIndex,
    IList<SRouteBase<SNested>> sRoutes,
  ) =>
      S3TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
        tab3SRoute: sRoutes[2],
      );
}

/// An implementation of [STabsRoute] which makes it easy to build screens
/// with 3 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class S3TabsRoute<N extends MaybeSNested> extends STabsRoute<S3TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  S3TabsRoute(StateBuilder<S3TabsState> stateBuilder)
      : super(stateBuilder, S3TabsState._fromSTabsState);
}
