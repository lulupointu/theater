import '../pushables/pushables.dart';
import '../s_route_interface.dart';

/// A class which static methods should be used to give the result of
/// [SRouteInterface.onPop]
///
///
/// Use [SPop.prevent], [SPop.on] or [SPop.parent] to describe the behaviour of
/// the [SRouteInterface.onPop] callback
abstract class SPop<P extends MaybeSPushable> {
  /// This should be used to prevent the current pop
  static _PreventSPop<P> prevent<P extends MaybeSPushable>() => _PreventSPop<P>();

  /// This should be used to pop on [sRouteInterface]
  static _SPopOn<P> on<P extends MaybeSPushable>(SRouteInterface<P> sRouteInterface) =>
      _SPopOn<P>(
        sRouteInterface: sRouteInterface,
      );

  /// The should be used by [SRouteInterface] which are [NonSPushable] to tell
  /// their parent to handle the pop
  static _SPopParent<P> parent<P extends MaybeSPushable>() => _SPopParent();

  /// The pop should call the browser history to move its active index by [delta]
  static _HistoryGoSPop<P> historyGo<P extends MaybeSPushable>(int delta) =>
      _HistoryGoSPop<P>(delta);

  /// Used to handle the different possible value of an instance of this class
  T when<T>({
    required T Function() prevent,
    required T Function(int delta) historyGo,
    required T Function() parent,
    required T Function(SRouteInterface<P> sRouteInterface) on,
  }) {
    final _this = this;

    if (_this is _PreventSPop) {
      return prevent();
    }

    if (_this is _SPopParent) {
      return parent();
    }

    if (_this is _SPopOn<P>) {
      return on(_this.sRouteInterface);
    }

    if (_this is _HistoryGoSPop<P>) {
      return historyGo(_this.delta);
    }

    throw 'Unexpected type: $runtimeType';
  }
}

/// The pop is prevented and nothing happens
class _PreventSPop<P extends MaybeSPushable> extends SPop<P> {}

/// Delegate the pop responsibility to this [SRouteInterface] parent
class _SPopParent<P extends MaybeSPushable> extends SPop<P> {}

/// We should pop on [sRouteInterface]
class _SPopOn<P extends MaybeSPushable> extends SPop<P> {
  /// The [SRouteInterface] on which we should pop
  final SRouteInterface<P> sRouteInterface;

  _SPopOn({required this.sRouteInterface});
}

/// The pop should call the browser history to move its active index by [delta]
class _HistoryGoSPop<P extends MaybeSPushable> extends SPop<P> {
  /// How much we should move into the browser history
  final int delta;

  _HistoryGoSPop(this.delta);
}
