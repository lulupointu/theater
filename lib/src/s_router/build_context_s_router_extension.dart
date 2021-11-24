import 'package:flutter/widgets.dart';

import 's_router.dart';

/// An extension an [BuildContext] which provides easy access to the closest
/// [SRouter]
extension BuildContextSRouterExtension on BuildContext {

  /// Gets the closest [SRouter] of the given context
  ///
  ///
  /// This will NOT listen to [SRouter] changes
  SRouterState get sRouter => SRouter.of(this, listen: false);
}