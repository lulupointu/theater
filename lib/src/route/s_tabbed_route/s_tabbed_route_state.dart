part of 's_tabbed_route.dart';

/// A representation of the state of a [STabbedRoute], it will be stored in the
/// [SRouter]
///
///
/// This should never be used directly and is instead only used inside
/// [STabbedRoute]
class STabbedRouteState<T, P extends MaybeSPushable> {
  /// Builds the new state of the given [sTabbedRoute] by using its attributes
  /// and (if any), it's previously stored state
  STabbedRouteState.from({
    required BuildContext context,
    required STabbedRoute<T, P> sTabbedRoute,
  }) {
    final oldState = SRouter.of(context, listen: false)
        .sRoutesStateManager
        .getSRouteState(sRouteInterface: sTabbedRoute) as STabbedRouteState<T, P>?;

    final sTabs = sTabbedRoute._sTabs;

    tabsRoute = {
      for (final key in sTabs.keys)

        // We use [getOrNull] because the length might have changed, even if
        // it is unlikely
        key: sTabs[key]!.tabRouteBuilder(
          (oldState?.tabsRoute.get(key) ?? sTabs[key]!.initialSRoute),
        )
    }.lock;

    // Create/Remove navigator key if the number of tab changed
    navigatorKeys = {
      for (final key in sTabs.keys)
        key: oldState?.navigatorKeys.get(key) ?? GlobalKey<NavigatorState>()
    }.lock;
  }

  /// The list of the different [SRouteInterface] in each tabs
  late IMap<T, SRouteInterface<NonSPushable>> tabsRoute;

  /// The list of the navigator keys used in each tabs
  late IMap<T, GlobalKey<NavigatorState>> navigatorKeys;
}
