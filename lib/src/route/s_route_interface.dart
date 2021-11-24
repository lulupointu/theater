import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'on_pop_result/on_pop_result.dart';
import 'pushables/pushables.dart';

/// An interface which describes the stack of pages which defines
/// a route (i.e. a stack of [Page]s)
@immutable
abstract class SRouteInterface<P extends MaybeSPushable> {
  // ignore: public_member_api_docs
  const SRouteInterface();

  /// Builds the page of this route
  ///
  ///
  /// The one which is actually visible
  Page pageBuilder(BuildContext context);

  /// The [SRoute] which describes the stack of pages which
  /// are bellow the page returned be [buildPage]
  ///
  ///
  /// If null is returned, no pages are displayed bellow this one
  SRouteInterface<P>? buildSRouteBellow(BuildContext context);

  /// A callback which will be used when a "popping" event occurs
  ///
  ///
  /// [SPop] describes what should happen:
  ///   - [SPop.prevent] prevents the pop event
  ///   - [SPop.on] allows you to give a [SRouteInterface] on which we 
  ///   ^ should pop
  ///   - [SPop.parent] should be used by [SRouteInterface] which are 
  ///   ^ [NonSPushable] and want their parent to handle the pop event
  SPop<P> onPop(BuildContext context, Object? data);

  /// A callback which will be used when a "back button" event occurs
  /// (typically pressing the back button of an Android device)
  ///
  ///
  /// Return true if the "back button" event is handled by this function, false
  /// otherwise
  ///
  /// If false is returned and other [SRoute] are active (in other
  /// [SRouter]), they will be called
  ///
  /// TODO: rewritte description
  FutureOr<SPop<P>> onBack(BuildContext context);
}
