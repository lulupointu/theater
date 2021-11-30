import 'package:flutter/widgets.dart';

import 's_router.dart';
import 's_router_interface.dart';

/// An extension an [BuildContext] which provides easy access to the closest
/// [SRouter]
extension BuildContextSRouterExtension on BuildContext {

  /// Gets the closest [SRouter] of the given context
  ///
  ///
  /// This will NOT listen to [SRouter] changes
  SRouterInterface get sRouter => SRouter.of(this, listen: false);
}