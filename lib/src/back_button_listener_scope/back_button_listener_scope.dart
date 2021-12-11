import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget to place at the top of the widget tree
///
///
/// Any child of this widget will be able to use [BackButtonListener] to react
/// to back button events
class BackButtonListenerScope extends StatefulWidget {
  /// The child bellow this widget
  ///
  ///
  /// The child's context will be able to use [BackButtonListener] to react to
  /// back button events
  final Widget child;

  // ignore: public_member_api_docs
  const BackButtonListenerScope({Key? key, required this.child}) : super(key: key);

  @override
  State<BackButtonListenerScope> createState() => _BackButtonListenerScopeState();
}

class _BackButtonListenerScopeState extends State<BackButtonListenerScope> {
  late BackButtonDispatcher? parentBackButtonDispatcher;

  @override
  void didChangeDependencies() {
    parentBackButtonDispatcher = Router.maybeOf(context)?.backButtonDispatcher;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      // Creates the back button dispatcher:
      //  - If there is already a back button dispatcher above, create a
      //  ^ [ChildBackButtonDispatcher]
      //  - If there is no back button dispatcher above, create a
      //  ^ [RootBackButtonDispatcher]
      backButtonDispatcher: parentBackButtonDispatcher == null
          ? RootBackButtonDispatcher()
          : ChildBackButtonDispatcher(parentBackButtonDispatcher!),
      // We use a [RouterDelegate] because we don't have the choice but it
      // really does nothing apart from telling [Router] that [widget.child]
      // should be used as a child
      routerDelegate: _BackButtonListenerScopeRouterDelegate(child: widget.child),
    );
  }
}

/// This is a perfectly useless [RouterDelegate] which does nothing apart from
/// returning the given [child] to its [build] method
// ignore: prefer_mixin
class _BackButtonListenerScopeRouterDelegate extends RouterDelegate with ChangeNotifier {
  /// The child of [BackButtonListenerScope]
  final Widget child;

  _BackButtonListenerScopeRouterDelegate({required this.child});

  @override
  Widget build(BuildContext context) => child;

  // Never handle the request here
  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  // This will never be called
  @override
  Future<void> setNewRoutePath(_) async {}
}
