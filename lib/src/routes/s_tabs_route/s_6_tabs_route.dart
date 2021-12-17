import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import '../s_nested.dart';

/// The state of [S6TabsRoute], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [S6TabsRoute] is pushed)
@immutable
class S6TabsState extends STabsState {
  /// {@macro srouter.framework.STabsState.constructor}
  S6TabsState({
    required this.activeIndex,
    required this.tab1SRoute,
    required this.tab2SRoute,
    required this.tab3SRoute,
    required this.tab4SRoute,
    required this.tab5SRoute,
    required this.tab6SRoute,
  }) : super(
          activeIndex: activeIndex,
          tabsSRoutes: [
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

  /// The [SRouteBase] corresponding to the third tab (index 5)
  final SRouteBase<SNested> tab6SRoute;

  /// A list of 6 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [SRouteBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [S6TabsState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  S6TabsState copyWith({
    int? activeIndex,
    SRouteBase<SNested>? tab1SRoute,
    SRouteBase<SNested>? tab2SRoute,
    SRouteBase<SNested>? tab3SRoute,
    SRouteBase<SNested>? tab4SRoute,
    SRouteBase<SNested>? tab5SRoute,
    SRouteBase<SNested>? tab6SRoute,
  }) {
    return S6TabsState(
      activeIndex: activeIndex ?? this.activeIndex,
      tab1SRoute: tab1SRoute ?? this.tab1SRoute,
      tab2SRoute: tab2SRoute ?? this.tab2SRoute,
      tab3SRoute: tab3SRoute ?? this.tab3SRoute,
      tab4SRoute: tab4SRoute ?? this.tab4SRoute,
      tab5SRoute: tab5SRoute ?? this.tab5SRoute,
      tab6SRoute: tab6SRoute ?? this.tab6SRoute,
    );
  }

  /// Creates a [S6TabsState] from a [_STabsState], internal use only
  factory S6TabsState._fromSTabsState(
    int activeIndex,
    IList<SRouteBase<SNested>> sRoutes,
  ) =>
      S6TabsState(
        activeIndex: activeIndex,
        tab1SRoute: sRoutes[0],
        tab2SRoute: sRoutes[1],
        tab3SRoute: sRoutes[2],
        tab4SRoute: sRoutes[3],
        tab5SRoute: sRoutes[4],
        tab6SRoute: sRoutes[5],
      );
}

/// An implementation of [STabsRoute] which makes it easy to build screens
/// with 6 tabs.
///
/// {@macro srouter.framework.STabsRoute}
abstract class S6TabsRoute<N extends MaybeSNested> extends STabsRoute<S6TabsState, N> {
  /// {@macro srouter.framework.STabsRoute.constructor}
  @mustCallSuper
  S6TabsRoute(StateBuilder<S6TabsState> stateBuilder)
      : super(stateBuilder, S6TabsState._fromSTabsState);
}
