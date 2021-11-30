import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../srouter.dart';
import '../../flutter_navigator_builder/nested_flutter_navigator_builder.dart';
import '../../s_router/s_routes_state_manager/s_route_state_saver.dart';
import '../on_pop_result/on_pop_result.dart';
import '../pushables/pushables.dart';
import '../s_route.dart';
import '../s_route_interface.dart';
import 's_tab.dart';

part 's_tabbed_route_state.dart';

/// A [SRoute] used for tabbed screen. A tabbed screen can either be:
///   - One tab shown at a time (e.g. with a bottom navigation bar)
///   - Multiple tabs shown at the same time (e.g. a desktop app with a
///   ^ permanent side bar)
abstract class STabbedRoute<T, P extends MaybeSPushable> extends SRoute<P> {
  /// [STabbedRoute] must have [sTabs] which is a mapping between:
  ///   - Indexes of type [T]
  ///   - [STab]s
  /// [STab] :
  ///   - must contain initial [SRouteInterface] in [STab.initialSRoute]
  ///   - can contain a non-null [STab.currentSRoute] to overwrite the currently
  ///   ^ used route for the associated tab
  /// If [STab.currentSRoute] is null: the current route will be the last route
  /// that has been used in this tab.
  ///
  /// The size of [sTabs] will determine the number of tabs
  STabbedRoute({required Map<T, STab> sTabs}) : _sTabs = sTabs;

  /// The list of the different tabs
  final Map<T, STab> _sTabs;

  /// The index of the tab being considered active
  ///
  /// This will be used to call [onPop] and [onBack] on the [SRouteInterface]
  /// of the active tab
  ///
  ///
  /// This must be in [_sTabs.keys]
  T get activeTab;

  /// A function which will be called when the active tab tries to pop
  ///
  ///
  /// If you DO want to pop, return an instance of this [STabbedRoute], and
  /// typically update the [activeTab] with [activeTabSRouteBellow]
  ///
  /// If you DON'T want to pop, return null
  STabbedRoute<T, P>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  );

  /// Builds a widget around the tabs
  ///
  ///
  /// [tabs] can be used to get the different tabs, its length is the same as
  /// the given [_sTabs] parameter in this class constructor
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
      child: tabsBuilder(context, {
        for (final key in _sTabs.keys)
          key: NestedSFlutterNavigatorBuilder(
            key: ValueKey(key),
            sRoute: state.tabsRoute[key]!,
            navigatorKey: state.navigatorKeys[key]!,
            navigatorObservers: [], // This could be inconvenient
          ),
      }),
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
