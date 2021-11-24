import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

/// A singleton which handles the Android back button in [SRouter]
///
///
/// If several [SBackButtonHandler] are placed in the widget tree, they will
/// each be called until one return true. If none return true, the back button
/// event will be ignored
///
///
/// The order of calling is Breadth First Search (BFS) from the bottom to the
/// top of the tree
/// 
/// 
/// We use a single class and report the depth of each [SBackButtonHandler]
/// because there might be multiple [SBackButtonHandler] side by side (not
/// nested) and we still want to call from most nested to least. To be honest,
/// this might be overkill.
class SBackButtonObserver extends WidgetsBindingObserver {
  /// Adds a back button callback
  ///
  ///
  /// depth starts at 0
  void addBackButtonHandler({
    required int depth,
    required OnBackButtonEventCallback callback,
  }) {
    _debugValidAddDepth(depth: depth);

    final callbacks = _onBackButtonEventCallbacks
        .get(depth, orElse: (_) => IList()) //
        .add(callback);

    if (depth < _onBackButtonEventCallbacks.length) {
      _onBackButtonEventCallbacks = _onBackButtonEventCallbacks.replace(depth, callbacks);
    } else {
      _onBackButtonEventCallbacks = _onBackButtonEventCallbacks.add(callbacks);
    }
  }

  /// A debug function which checks if the depth given in [addBackButtonHandler] is valid
  ///
  /// For a depth to be valid, it must be a depth contained in
  /// [_onBackButtonEventCallbacks] or the next one ([_onBackButtonEventCallbacks.length])
  ///
  ///
  /// This must be called BEFORE the callback is added
  void _debugValidAddDepth({required int depth}) {
    assert(depth <= _onBackButtonEventCallbacks.length);
  }

  /// Removes a back button callback which was added using [addBackButtonHandler]
  ///
  ///
  /// Throws an error if the [callback] is unknown
  void removeBackButtonCallback({required OnBackButtonEventCallback callback}) {
    final callbackIndex = _onBackButtonEventCallbacks.indexWhere(
      (callbacks) => callbacks.contains(callback),
    );

    if (callbackIndex == -1) {
      throw 'Tried to remove a callback which was never added';
    }

    _onBackButtonEventCallbacks = _onBackButtonEventCallbacks.replace(
      callbackIndex,
      _onBackButtonEventCallbacks.get(callbackIndex).remove(callback),
    );
  }

  /// The placement on the first list indicates how "deep" the callback is
  ///
  ///
  /// The second list contains all the callbacks which are at this depth
  IList<IList<OnBackButtonEventCallback>> _onBackButtonEventCallbacks = IList();

  @override
  Future<bool> didPopRoute() async {
    for (var callbacks in _onBackButtonEventCallbacks.reversed) {
      for (var callback in callbacks) {
        final handled = await callback();
        if (handled) return true;
      }
    }

    // In any case, consider the event as handled so that the application does
    // not pop
    return true;
  }

  SBackButtonObserver._();

  /// The current (and unique) instance of [SBackButtonObserver]
  static SBackButtonObserver? _instance;

  /// Gets the current (and unique) instance of [SBackButtonObserver]
  ///
  ///
  /// DO make sure that you called [initialize] before
  static SBackButtonObserver get instance {
    if (_instance == null) {
      throw '''
Tried to get [SBackButtonObserver.instance] but [SBackButtonObserver] has never been initialized. 
You must call [SBackButtonObserver.initialize] before using [SBackButtonObserver.instance]
''';
    }

    return _instance!;
  }

  /// Creates the unique instance of this class
  ///
  ///
  /// This must only be called once
  static void initialize() {
    _instance = SBackButtonObserver._();

    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance!.addObserver(_instance!);
  }
}

/// A callback triggered when the Android back button is pressed
///
///
/// If true is returned, the event is considered as handled and wont trigger
/// any other [OnBackButtonEventCallback]
typedef OnBackButtonEventCallback = FutureOr<bool> Function();
