import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../route/pushables/pushables.dart';
import '../route/s_route_interface.dart';
import '../web_entry/web_entry.dart';

/// A class used to interact with the web url
///
/// This class has three goals:
///   1. Define which type of url can access this translator
///   2. Convert the url to a [SRoute]
///   3. Convert the [SRoute] to a url
///
/// It uses the [Route] type to determine if it is its role to convert a given
/// [SRouteInterface] to a [WebEntry]
///
///
/// Prefer extending this class since the [routeType] type should usually keep
/// its default value ([Route])
@immutable
abstract class STranslator<Route extends SRouteInterface<P>, P extends MaybeSPushable> {
  /// This constructor checks that the [Route] generic (stored in [routeType])
  /// is resolved at runtime (i.e. that it is NOT [SRoute] but the
  /// name of a route class you created)
  ///
  ///
  /// For example:
  /// ```
  /// // GOOD
  /// PathTranslator<YourRouteType>(...)
  ///
  /// // BAD
  /// PathTranslator(...)
  /// ```
  STranslator() {
    assert(() {
      if (routeType == SRouteInterface) {
        final translatorType =
            runtimeType.toString().replaceFirst('<SRouteInterface<dynamic>>', '');
        print('''\x1B[31m
The [SRoute] type of $runtimeType could not be resolved.

This is likely because you did not manually specify the [SRoute]:
```
// GOOD
$translatorType<YourRouteType>(...)

// BAD
$translatorType(...)
```
\x1B[0m''');
        return false;
      }

      return true;
    }());
  }

  // TODO: add description
  /// Exact match only, no subclass match
  ///
  ///
  /// It can be overwritten to [dynamic] to match any route
  /// It can be overwritten to [Null] to match no route
  ///
  ///
  /// It should be resolved at runtime (i.e. that it is NOT [SRoute]
  /// but the name of a route class you created). This is checked by the
  /// assert in the constructor
  final Type routeType = Route;

  /// Converts the associated [SRoute] into a string representing
  /// the url
  ///
  ///
  /// This is only called when a new [SRoute] is pushed (or replaced)
  /// in [SRouter]
  WebEntry routeToWebEntry(BuildContext context, Route route);

  /// Converts the given url into the associated [SRoute]
  ///
  ///
  /// If the returned value is null, it means that the given url can't
  /// be used to create such a route
  ///
  ///
  /// This can be called as often as needed
  Route? webEntryToRoute(BuildContext context, WebEntry webEntry);
}
