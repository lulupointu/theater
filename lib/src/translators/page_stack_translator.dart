import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import '../page_stack/nested_stack.dart';
import 'translator.dart';

/// A class used to interact with the web url
///
/// This class has three goals:
///   1. Define which type of url can access this translator
///   2. Convert the url to a [PageStackBase]
///   3. Convert the [SElement] to a url
///
/// It uses the [Element] type to determine if it is its role to convert a given
/// [SElement] to a [WebEntry]
///
///
/// Prefer extending this class since the [routeType] type should usually keep
/// its default value ([Element])
@immutable
abstract class PageStackTranslator<Route extends PageStackBase<N>, N extends MaybeNestedStack>
    extends STranslator<SElement<N>, Route, N> {

  @override
  WebEntry sElementToWebEntry(BuildContext context, SElement<N> element, Route sRoute) {
    return sRouteToWebEntry(context, sRoute);
  }

  /// Converts the associated [SElement] into a string representing
  /// the url
  WebEntry sRouteToWebEntry(BuildContext context, Route route);
}
