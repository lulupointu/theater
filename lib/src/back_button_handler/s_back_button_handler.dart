import 'package:flutter/widgets.dart';
import 's_back_button_observer.dart';

/// A class which reports a callback to [SBackButtonObserver] so that it is
/// triggered when the back button is pressed
///
///
/// Read [SBackButtonHandler] to see in which order/conditions the callback are
/// called
class SBackButtonHandler extends StatefulWidget {
  /// A callback triggered when the back button is pressed
  final OnBackButtonEventCallback onBackButtonEventCallback;

  /// The child of this widget
  final Widget child;

  // ignore: public_member_api_docs
  const SBackButtonHandler({
    Key? key,
    required this.onBackButtonEventCallback,
    required this.child,
  }) : super(key: key);

  @override
  State<SBackButtonHandler> createState() => _SBackButtonHandlerState();
}

class _SBackButtonHandlerState extends State<SBackButtonHandler> {
  /// The depth of this [SBackButtonHandler] (i.e how many [SBackButtonHandler]
  /// are on top of this one in the widget tree)
  ///
  ///
  /// The minimum depth is 0 (if no [SBackButtonHandler] are on top of this
  /// one)
  late int depth;

  @override
  void initState() {
    super.initState();

    depth =
        (_SBackButtonHandlerDepthProvider.maybeOf(context, listen: false)?.depth ?? -1) + 1;
    SBackButtonObserver.instance.addBackButtonHandler(
      depth: depth,
      callback: widget.onBackButtonEventCallback,
    );
  }

  @override
  void didUpdateWidget(covariant SBackButtonHandler oldWidget) {
    if (oldWidget.onBackButtonEventCallback != widget.onBackButtonEventCallback) {
      SBackButtonObserver.instance.removeBackButtonCallback(
        callback: oldWidget.onBackButtonEventCallback,
      );
      SBackButtonObserver.instance.addBackButtonHandler(
        depth: depth,
        callback: widget.onBackButtonEventCallback,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    final newDepth = (_SBackButtonHandlerDepthProvider.maybeOf(context)?.depth ?? -1) + 1;
    if (newDepth != depth) {
      SBackButtonObserver.instance.removeBackButtonCallback(
        callback: widget.onBackButtonEventCallback,
      );
      depth = newDepth;
      SBackButtonObserver.instance.addBackButtonHandler(
        depth: depth,
        callback: widget.onBackButtonEventCallback,
      );
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    SBackButtonObserver.instance.removeBackButtonCallback(
      callback: widget.onBackButtonEventCallback,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SBackButtonHandlerDepthProvider(
      depth: depth,
      child: widget.child,
    );
  }
}

/// A [InheritedWidget] accessible via [_SBackButtonHandlerDepthProvider.maybeOf]
/// and which gives access to its associated [SBackButtonHandler] depth
///
///
/// This is only used within [SBackButtonHandler] to know its own depth depending
/// on the one of its parent (if any)
class _SBackButtonHandlerDepthProvider extends InheritedWidget {
  /// The depth of the associated [_SBackButtonHandlerDepthProvider]
  final int depth;

  const _SBackButtonHandlerDepthProvider({
    Key? key,
    required Widget child,
    required this.depth,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_SBackButtonHandlerDepthProvider old) => old.depth != depth;

  /// Returns the [_SBackButtonHandlerDepthProvider] of the given [context]
  static _SBackButtonHandlerDepthProvider? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    late final _SBackButtonHandlerDepthProvider? result;
    if (listen) {
      result = context.dependOnInheritedWidgetOfExactType<_SBackButtonHandlerDepthProvider>();
    } else {
      result = context
          .getElementForInheritedWidgetOfExactType<_SBackButtonHandlerDepthProvider>()
          ?.widget as _SBackButtonHandlerDepthProvider?;
    }
    return result;
  }
}
