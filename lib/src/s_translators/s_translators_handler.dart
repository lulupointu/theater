import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../routes/framework.dart';
import '../routes/s_nested.dart';
import 's_translator.dart';

/// This will use the given [STranslator]s to convert a web entry
/// to a [SRoute] and vise versa
@immutable
class STranslatorsHandler<N extends MaybeSNested> {
  /// The list of [STranslator]s which will be used to convert a web
  /// to a [SRoute] and vise versa
  final List<STranslator<SElement<N>, SRouteBase<N>, N>> translators;

  // ignore: public_member_api_docs
  const STranslatorsHandler({required this.translators});

  /// Returns a [SRoute] from a [WebEntry]
  ///
  ///
  /// If no translator returns a route from the [webEntry], return null
  SRouteBase<N>? getRouteFromWebEntry(BuildContext context, WebEntry webEntry) {
    // We search which translator from [translators] returns a [SRoute]
    // considering the given web entry
    for (var translator in translators) {
      final route = translator.webEntryToSRoute(context, webEntry);
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
  WebEntry? getWebEntryFromSElement<Element extends SElement<N>, Route extends SRouteBase<N>>(
    BuildContext context,
    Element sElement,
  ) {
    // We explicitly allow [dynamic] so that a route can implement matching
    // everything (on mobile with [UniversalWebEntryMatcherTranslator] for
    // example)

    // If there is no match, return null
    if (!translators.any(
      (translator) =>
          translator.routeType == sElement.sWidget.sRoute.runtimeType ||
          translator.routeType == dynamic,
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
          translator.routeType == sElement.sWidget.sRoute.runtimeType ||
          translator.routeType == dynamic,
    );

    return translator.sElementToWebEntry(
      context,
      sElement,
      sElement.sWidget.sRoute as Route,
    );
  }
}
