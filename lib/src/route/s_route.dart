import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../srouter.dart';
import 'on_pop_result/on_pop_result.dart';
import 'pushables/pushables.dart';
import 's_route_interface.dart';

/// An opinionated implementation of [SRoute] where:
///   - The visible page is determined by the platform (see [SPlatformPageMixin])
///   - A popping event will pop on the [SRoute] bellow
///   - A back button event will go back to the previous route if any, else pop
///   ^ if the associated [SRouter] is not nester
///
/// See [SingleChildSRoute] if you don't want to build any pages bellow
/// this one
///
///
/// TODO: add better doc, this is the main class of [SRouter]
abstract class SRoute<P extends MaybeSPushable> extends SRouteInterface<P> {
  /// TODO: add better doc
  const SRoute({this.key});

  /// The widget which will be visible when this [SRoute] is used
  ///
  ///
  /// This widget will be wrapped in the platform specific [Page] in
  /// [buildPage]
  /// You can overwrite [buildPage] to build a custom page
  Widget build(BuildContext context);

  /// The key associated with this page.
  ///
  /// This key will be used for comparing pages in [canUpdate].
  final LocalKey? key;

  /// By default, there is not [SRoute] bellow this one
  ///
  /// Override this method if you want to provide one
  @override
  SRouteInterface<P>? buildSRouteBellow(BuildContext context) => null;

  /// Provides the default implementation of [SRoute.onPop] which acts
  /// as follows:
  ///   - If the [SRoute] has a route bellow, push this route
  ///   - If the [SRoute] does NOT have a route bellow, do nothing
  @override
  SPop<P> onPop(BuildContext context, Object? data) {
    final sRouteBellow = buildSRouteBellow(context);

    if (sRouteBellow == null) {
      // We are no route bellow, delegate the pop responsibility to the parent
      return SPop.parent();
    }

    return SPop.on(sRouteBellow);
  }

  /// Which implementation of [onBack] to use
  OnBackMode get onBackMode => OnBackMode.pop;

  /// An implementation of [onBack] which depends on the value of [onBackMode]
  ///
  ///
  /// # Pop mode
  /// - If this [SRoute] has a route bellow, push this route
  /// - If this [SRoute] does NOT have a route bellow, put the app in
  /// ^ the background if the associated [SRouter] is not nested
  ///
  /// # History back mode
  /// - If the browser can go back, go back in the browser history
  /// - Else put the app in the background
  @override
  FutureOr<SPop<P>> onBack(BuildContext context) {
    switch (onBackMode) {
      case OnBackMode.pop:
        return SynchronousFuture(onPop(context, null));
      case OnBackMode.historyBack:
        return SynchronousFuture(_historyBackOnBack(context));
    }
  }

  /// Returns a page corresponding to the platform:
  ///   - [CupertinoPage] on iOS and macOS
  ///   - [MaterialPage] otherwise
  ///
  ///
  /// The [child] is the one returned by [build]
  ///
  /// [key] will be used as the page key
  ///
  ///
  /// You can override this method to build a custom page.
  /// If you don't want to implement [build] (because your page already
  /// contains a child for example), return a useless value in [build] (such
  /// as [Container]) and don't use it here
  Page buildPage(BuildContext context, Widget child) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPage(key: ValueKey(key ?? runtimeType), child: child);
      default:
        return MaterialPage(key: ValueKey(key ?? runtimeType), child: child);
    }
  }

  SPop<P> _historyBackOnBack(BuildContext context) {
    if (!(SRouter.of(context, listen: false).canGo(-1) ?? true)) {
      // If we are [NonPushable] and have no route bellow, tell the parent to
      // pop
      if (P is NonSPushable) {
        return SPop.parent() as SPop<P>;
      }

      // If we are [Pushable] but have no route bellow, prevent the pop
      return SPop.prevent();
    }

    return SPop.historyGo(-1);
  }

  @nonVirtual
  @override
  Page pageBuilder(BuildContext context) {
    return buildPage(context, build(context));
  }
}

/// A description of which implementation of [onBack] to used
enum OnBackMode {
  /// # Pop mode
  /// - If this [SRoute] has a route bellow, push this route
  /// - If this [SRoute] does NOT have a route bellow, put the app in
  /// ^ the background if the associated [SRouter] is not nested
  pop,

  /// # History back mode
  /// - If the browser can go back, go back in the browser history
  /// - Else put the app in the background
  historyBack,
}
