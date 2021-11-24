import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../route/pushables/pushables.dart';
import '../route/s_route_interface.dart';
import '../web_entry/web_entry.dart';
import 's_translator.dart';

/// This will use the given [STranslator]s to convert a web entry
/// to a [SRoute] and vise versa
@immutable
class STranslatorsHandler<P extends MaybeSPushable> {
  /// The list of [STranslator]s which will be used to convert a web
  /// to a [SRoute] and vise versa
  final List<STranslator<SRouteInterface<P>, P>> translators;

  // ignore: public_member_api_docs
  const STranslatorsHandler({required this.translators});

  /// Returns a [SRoute] from a [WebEntry]
  ///
  ///
  /// If no translator returns a route from the [webEntry], return null
  SRouteInterface<P>? getRouteFromWebEntry(BuildContext context, WebEntry webEntry) {
    // We search which translator from [translators] returns a [SRoute]
    // considering the given web entry
    for (var translator in translators) {
      final route = translator.webEntryToRoute(context, webEntry);
      if (route != null) return route;
    }

    return null;
  }

  /// Returns a [WebEntry] from a [SRoute]
  ///
  ///
  /// If multiple translators can translate the route to a web entry, only the
  /// first one in the list is called
  ///
  ///
  /// If no translator can translate the route to a web entry, return null
  WebEntry? getWebEntryFromRoute<R extends SRouteInterface<P>>(
    BuildContext context,
    R route,
  ) {
    // We explicitly allow [dynamic] so that a route can implement matching
    // everything (on mobile with [UniversalWebEntryMatcherTranslator] for
    // example)

    // If there is no match, return null
    if (!translators.any(
      (translator) =>
          translator.routeType == route.runtimeType || translator.routeType == dynamic,
    )) {
      return null;
    }

    // A translator is unique to a [SRoute] so we simply take the
    // first match
    //
    // We explicitly allow [dynamic] so that a route can implement matching
    // everything (on mobile with [UniversalWebEntryMatcherTranslator] for
    // example)
    final translator = translators.firstWhere(
      (translator) =>
          translator.routeType == route.runtimeType || translator.routeType == dynamic,
    );

    return translator.routeToWebEntry(context, route);
  }
}
