part of '../s_router.dart';

/// An object which can be used to store the state of a [SRouteInterface]
///
///
/// IMPORTANT: The state is associated to the [SRouteInterface] runtimeType
class _SRoutesStateManager  {
  /// The map which associated the [SRouteInterface]s runtimeType to the
  /// [SRouteInterface]s state
  var _sRoutesState = IMap<Type, Object>();

  /// Store the given state
  ///
  ///
  /// [SRouteInterface] is only used to get the runtimeType and won't be stored
  ///
  ///
  /// If a [SRouteInterface] of the same runtimeType had already stored a state,
  /// it will be overwritten
  void setSRouteState({
    required SRouteInterface sRouteInterface,
    required Object state,
  }) {
    _sRoutesState = _sRoutesState.add(sRouteInterface.runtimeType, state);
  }

  /// Delete the state associated with the given route runtimeType
  ///
  ///
  /// If no state was previously stored, this does nothing
  void deleteSRouteState({required SRouteInterface sRouteInterface}) {
    _sRoutesState = _sRoutesState.remove(sRouteInterface.runtimeType);
  }

  /// Returns a state associated to the [SRouteInterface] runtimeType that was
  /// previously saved using [setSRouteState]
  ///
  ///
  /// If no state was previously saved, or is was deleted, then return null
  Object? getSRouteState({required SRouteInterface sRouteInterface}) {
    return _sRoutesState.get(sRouteInterface.runtimeType);
  }
}
