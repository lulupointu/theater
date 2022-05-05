import 'package:flutter/widgets.dart';

import 'theater.dart';
import 'theater_interface.dart';

/// An extension an [BuildContext] which provides easy access to the closest
/// [Theater]
extension BuildContextTheaterExtension on BuildContext {

  /// Gets the closest [Theater] of the given context
  ///
  ///
  /// This will NOT listen to [Theater] changes
  TheaterInterface get theater => Theater.of(this, listen: false);
}