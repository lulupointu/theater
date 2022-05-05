import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import 'translator.dart';

/// A class used to interact with the web url
///
/// This class has three goals:
///   1. Define which type of url can access this translator
///   2. Convert the url to a [PageStackBase]
///   3. Convert the [PageElement] to a url
///
/// It uses the [Element] type to determine if it is its role to convert a given
/// [PageElement] to a [WebEntry]
///
///
/// Prefer extending this class since the [pageStackType] type should usually keep
/// its default value ([Element])
@immutable
abstract class PageStackTranslator<Route extends PageStackBase>
    extends STranslator<PageElement, Route> {

  @override
  WebEntry pageElementToWebEntry(BuildContext context, PageElement element, Route sRoute) {
    return sRouteToWebEntry(context, sRoute);
  }

  /// Converts the associated [PageElement] into a string representing
  /// the url
  WebEntry sRouteToWebEntry(BuildContext context, Route route);
}
