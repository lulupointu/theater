import '../framework.dart';

/// A class which static methods should be used to give the result of
/// [SElement.onSystemPop]
///
///
/// Use [SPop.done] or [SPop.parent] to describe result of the callback
abstract class SPop {
  /// The pop event has been handled internally
  static _SPopDone done() => _SPopDone();

  /// The event should be handled by the parent
  static _SPopParent parent() => _SPopParent();

  /// Used to handle the different possible value of an instance of this class
  T when<T>({
    required T Function() parent,
    required T Function() done,
  }) {
    final _this = this;

    if (_this is _SPopParent) {
      return parent();
    }

    if (_this is _SPopDone) {
      return done();
    }

    throw 'Unexpected type: $runtimeType';
  }
}

/// The pop event has been handled internally
class _SPopDone extends SPop {}

/// Delegate the pop responsibility to this [SRouteBase] parent
class _SPopParent extends SPop {}
