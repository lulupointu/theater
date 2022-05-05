import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import 'translator.dart';

/// This will use the given [STranslator]s to convert a web entry
/// to a [PageStack] and vise versa
@immutable
class TranslatorsHandler {
  /// The list of [STranslator]s which will be used to convert a web
  /// to a [PageStack] and vise versa
  final List<STranslator<PageElement, PageStackBase>> translators;

  // ignore: public_member_api_docs
  const TranslatorsHandler({required this.translators});

  /// Returns a [PageStack] from a [WebEntry]
  ///
  ///
  /// If no translator returns a route from the [webEntry], return null
  PageStackBase? getPageStackFromWebEntry(BuildContext context, WebEntry webEntry) {
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
  WebEntry? getWebEntryFromPageElement<Element extends PageElement, Route extends PageStackBase>(
    BuildContext context,
    Element pageElement,
  ) {
    // We explicitly allow [dynamic] so that a route can implement matching
    // everything (on mobile with [UniversalWebEntryMatcherTranslator] for
    // example)

    // If there is no match, return null
    if (!translators.any(
      (translator) =>
          translator.pageStackType == pageElement.pageWidget.pageStack.runtimeType ||
          translator.pageStackType == dynamic,
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
          translator.pageStackType == pageElement.pageWidget.pageStack.runtimeType ||
          translator.pageStackType == dynamic,
    );

    return translator.pageElementToWebEntry(
      context,
      pageElement,
      pageElement.pageWidget.pageStack as Route,
    );
  }
}
