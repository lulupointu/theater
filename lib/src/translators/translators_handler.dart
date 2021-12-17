import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import '../page_stack/nested_stack.dart';
import 'translator.dart';

/// This will use the given [STranslator]s to convert a web entry
/// to a [PageStack] and vise versa
@immutable
class TranslatorsHandler<N extends MaybeNestedStack> {
  /// The list of [STranslator]s which will be used to convert a web
  /// to a [PageStack] and vise versa
  final List<STranslator<SElement<N>, PageStackBase<N>, N>> translators;

  // ignore: public_member_api_docs
  const TranslatorsHandler({required this.translators});

  /// Returns a [PageStack] from a [WebEntry]
  ///
  ///
  /// If no translator returns a route from the [webEntry], return null
  PageStackBase<N>? getPageStackFromWebEntry(BuildContext context, WebEntry webEntry) {
    // We search which translator from [translators] returns a [SRoute]
    // considering the given web entry
    for (var translator in translators) {
      final route = translator.webEntryToPageStack(context, webEntry);
      if (route != null) return route;
    }

    return null;
  }

  /// Returns a [WebEntry] from a [PageStack]
  ///
  ///
  /// If multiple translators can translate the route to a web entry, only the
  /// first one in the list is called
  ///
  ///
  /// If no translator can translate the route to a web entry, return null
  WebEntry? getWebEntryFromSElement<Element extends SElement<N>, Route extends PageStackBase<N>>(
    BuildContext context,
    Element sElement,
  ) {
    // We explicitly allow [dynamic] so that a route can implement matching
    // everything (on mobile with [UniversalWebEntryMatcherTranslator] for
    // example)

    // If there is no match, return null
    if (!translators.any(
      (translator) =>
          translator.routeType == sElement.sWidget.pageStack.runtimeType ||
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
          translator.routeType == sElement.sWidget.pageStack.runtimeType ||
          translator.routeType == dynamic,
    );

    return translator.sElementToWebEntry(
      context,
      sElement,
      sElement.sWidget.pageStack as Route,
    );
  }
}
