import 'package:flutter/widgets.dart';

import '../page_stack/framework.dart';
import 'theater.dart';

/// An extension an [BuildContext] which provides easy access to the closest
/// [Theater]
extension BuildContextTheaterExtension on BuildContext {
  /// Gets the closest [Theater] of the given context
  ///
  ///
  /// This will NOT listen to [Theater] changes
  void to(PageStackBase pageStack, {bool isReplacement = false}) {
    Theater.of(this, listen: false).to(pageStack, isReplacement: isReplacement);
  }
}
