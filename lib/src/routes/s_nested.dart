import '../s_router/s_router.dart';
import 'framework.dart';

/// The generic of [SRouteBase] which describes whether the route can
/// be pushed into [SRouter] or not.
///
///
/// DO use [SNested] or [NotSNested] when implementing a [SRouteBase]
abstract class MaybeSNested {}

/// Use [NotSNested] for [SRouteBase] which are used in [SRouter.to]
abstract class NotSNested extends MaybeSNested {}

/// Use [SNested] for [SRouteBase] which are nested in other (typically inside
/// a [STabsRoute])
///
/// Passing the associated [SRouteBase] to [SRouter.to] is a compile error
/// since only top-level (i.e. [NotSNested]) [SRouteBase] can be navigated to
/// directly
abstract class SNested extends MaybeSNested {}
