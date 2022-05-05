import '../framework.dart';

/// A class which static methods should be used to give the result of
/// [PageElement.onSystemPop]
///
///
/// Use [SystemPopResult.done] or [SystemPopResult.parent] to describe result of the callback
abstract class SystemPopResult {
  /// The pop event has been handled internally
  static _SystemPopResultDone done() => _SystemPopResultDone();

  /// The event should be handled by the parent
  static _SystemPopResultParent parent() => _SystemPopResultParent();

  /// Used to handle the different possible value of an instance of this class
  T when<T>({
    required T Function() parent,
    required T Function() done,
  }) {
    final _this = this;

    if (_this is _SystemPopResultParent) {
      return parent();
    }

    if (_this is _SystemPopResultDone) {
      return done();
    }

    throw 'Unexpected type: $runtimeType';
  }
}

/// The pop event has been handled internally
class _SystemPopResultDone extends SystemPopResult {}

/// Delegate the pop responsibility to this [PageStackBase] parent
class _SystemPopResultParent extends SystemPopResult {}
