import 'package:flutter/widgets.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';

/// A class used to interact with the docs url
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
abstract class Translator<Element extends PageElement, PS extends PageStackBase> {
  /// This constructor checks that the [PS] generic (stored in [pageStackType])
  /// is resolved at runtime (i.e. that it is NOT [PageStackBase] but the
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
  Translator() {
    assert(() {
      if (pageStackType == PageStackBase) {
        final translatorType =
            runtimeType.toString().replaceFirst('<SRouteBase<dynamic>>', '');
        print('''\x1B[31m
The [SRoute] type of $runtimeType could not be resolved.

This is likely because you did not manually specify the [SRoute]:
```
// GOOD
$translatorType<YourSRouteType>(...)

// BAD
$translatorType(...)
```
\x1B[0m''');
        return false;
      }

      return true;
    }());
  }

  /// This attributes describe which [PageElement] is associated with this
  /// [Translator] :
  ///   - When this [PageStackBase] associated with this [PageElement] is pushed in
  ///   ^ [Theater], the translator with which is is associated will be used to
  ///   ^ convert it to a [WebEntry]
  ///   - When a [WebEntry] matches this translator, it is this translator job
  ///   ^ to convert it to an [PageStack] instance
  ///
  /// This type match is exact match only, no subclass match
  ///
  ///
  /// You generally don't want to override this attribute. Exceptions are:
  ///   - If you want to match every route, overwrite with [dynamic]
  ///   - If you don't want to match any route, overwrite with [Null]
  ///
  ///
  /// It must be resolved at runtime, this means that if its value is
  /// [SRouteBase<MaybeSNested>], an assertion error will be raised.
  /// We impose this constraint so that developers don't forget to specify the
  /// generic type (i.e. use Translator<MySRoute, ...>(), NOT Translator())
  /// This is checked by the assert in this class' constructor
  final Type pageStackType = PS;

  /// Converts the associated [PageElement] and [PageStack] into a string representing
  /// the url
  WebEntry pageElementToWebEntry(BuildContext context, Element element, PS sRoute);

  /// Converts the given url into the associated [PageStack]
  ///
  ///
  /// If the returned value is null, it means that the given url can't
  /// be used to create such a route
  PS? webEntryToPageStack(BuildContext context, WebEntry webEntry);
}
