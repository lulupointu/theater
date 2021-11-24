import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_navigator_builder/nested_flutter_navigator_builder.dart';
import '../../s_router/s_routes_state_manager/s_route_state_saver.dart';
import '../on_pop_result/on_pop_result.dart';
import '../pushables/pushables.dart';
import '../s_route.dart';
import '../s_route_interface.dart';
import 's_tab.dart';
import 's_tabbed_route_state.dart';

abstract class STabbedRoute<T, P extends MaybeSPushable> extends SRoute<P> {
  // TODO: add doc
  // ignore: public_member_api_docs
  STabbedRoute({required this.sTabs});

  /// The list of the different tabs
  final Map<T, STab> sTabs;

  /// The index of the tab being considered active
  ///
  /// This will be used to call [onPop] and [onBack] on the [SRouteInterface]
  /// of the active tab
  ///
  ///
  /// This must be in [sTabs.keys]
  T get activeTab;

  /// A function which will be called when the active tab tries to pop
  ///
  ///
  /// If you DO want to pop, return an instance of this [STabbedRoute], and
  /// typically update the [activeTab] with [activeTabSRouteBellow]
  /// If you DON'T want to pop, return null
  STabbedRoute<T, P>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  );

  /// Builds a widget around the tabs
  ///
  ///
  /// [tabs] can be used to get the different tabs, its length is the same as
  /// the given [sTabs] parameter in this class constructor
  ///
  ///
  /// // TODO: find a better name, builder could be taken if we wanted to add a wrapper to every [SRouteInterface]
  Widget tabsBuilder(BuildContext context, Map<T, Widget> tabs);

  /// This is what [STabbedRoute] bring, an opinionated implementation of
  /// [build] which builds tabs
  @override
  @nonVirtual
  Widget build(BuildContext context) {
    final state = STabbedRouteState.from(context: context, sTabbedRoute: this);

    // Store the state using [SRouteStateSaver] so that it can be retrieved during
    // the next build (and in the translators)
    return SRouteStateSaver(
      sRoute: this,
      state: state,
      child: tabsBuilder(
        context,
        {
          for (final key in sTabs.keys)
            key: NestedSFlutterNavigatorBuilder(
              sRoute: state.tabsRoute[key]!,
              navigatorKey: state.navigatorKeys[key]!,
              navigatorObservers: [], // This could be inconvenient
            ),
        },
      ),
    );
  }

  /// The default pop tries to build the [sRouteBellow] of the active
  /// [SRouteInterface]
  ///
  ///
  /// If [sRouteBellow] is null, it will try to pop on this route [sRouteBellow]
  /// (i.e. call super)
  @override
  SPop<P> onPop(BuildContext context, Object? data) {
    final state = STabbedRouteState.from(context: context, sTabbedRoute: this);

    // Call onPop on this active tab
    final tabOnPop = state.tabsRoute[activeTab]!.onPop(context, data);

    // Handle the pop depending on what the active tab onPop returned
    return tabOnPop.when(
      // If the active tab prevented the pop, prevent the pop
      prevent: SPop.prevent,

      // If the active tab want to change the browser history index, return to
      // move the browser history index
      historyGo: SPop.historyGo,

      // If the active tab delegated the pop, handle the pop as any [SRoute]
      parent: () => super.onPop(context, data),

      // If the active tab popped, use [onTabPop] to construct the new [STabbedRoute]
      on: (sRouteBellow) {
        final maybeNewSTabbedRoute = onTabPop(context, sRouteBellow);

        // If [onTabPop] returned null, prevent the pop
        if (maybeNewSTabbedRoute == null) {
          return SPop.prevent();
        }

        // Else pop on the returned [STabbedRoute]
        return SPop.on(maybeNewSTabbedRoute);
      },
    );
  }

  @override
  Future<SPop<P>> onBack(BuildContext context) async {
    final state = STabbedRouteState.from(context: context, sTabbedRoute: this);

    final tabOnBack = await state.tabsRoute[activeTab]!.onBack(context);

    // Handle the pop depending on what the active tab onBack returned
    return tabOnBack.when(
      // If the active tab prevented the pop, prevent the pop
      prevent: SPop.prevent,

      // If the active tab want to change the browser history index, return to
      // move the browser history index
      historyGo: SPop.historyGo,

      // If the active tab delegated the pop, handle the pop as any [SRoute]
      parent: () {
        return super.onBack(context);
      },

      // If the active tab popped, use [onTabPop] to construct the new [STabbedRoute]
      on: (sRouteBellow) {
        final maybeNewSTabbedRoute = onTabPop(context, sRouteBellow);

        // If [onTabPop] returned null, prevent the pop
        if (maybeNewSTabbedRoute == null) {
          return SPop.prevent();
        }

        // Else pop on the returned [STabbedRoute]
        return SPop.on(maybeNewSTabbedRoute);
      },
    );
  }
}
