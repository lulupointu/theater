import 'package:flutter/widgets.dart';

import '../../route/s_route_interface.dart';
import '../s_router.dart';

/// A widget which is use to save the state of a [SRouteInterface] in the
/// containing [SRouter]
///
///
/// If the state is updated when rebuilding this widget, the state will
/// be updated in the [SRouter]
///
///
/// This widget will clear the [SRouteInterface] state if it is removed from
/// the widget tree
class SRouteStateSaver extends StatefulWidget {
  /// Used to get the [SRouteInterface] runtimeType and won't be stored
  final SRouteInterface sRoute;

  /// The actual state which needs to be saved
  ///
  ///
  /// If this parameter is updated when rebuilding this widget, the state will
  /// be updated in the [SRouter]
  final Object state;

  /// The child of this widget
  final Widget child;

  // ignore: public_member_api_docs
  const SRouteStateSaver({
    Key? key,
    required this.sRoute,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  State<SRouteStateSaver> createState() => _SRouteStateSaverState();
}

class _SRouteStateSaverState extends State<SRouteStateSaver> {
  @override
  void initState() {
    SRouter.of(context, listen: false).sRoutesStateManager.setSRouteState(
          sRouteInterface: widget.sRoute,
          state: widget.state,
        );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SRouteStateSaver oldWidget) {
    SRouter.of(context, listen: false).sRoutesStateManager.setSRouteState(
          sRouteInterface: widget.sRoute,
          state: widget.state,
        );
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
