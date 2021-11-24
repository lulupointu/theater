import '../../s_router/s_router.dart';
import '../s_route_interface.dart';

/// The generic of [SRouteInterface] which describes whether the route can
/// be pushed into [SRouter] or not.
/// 
/// 
/// DO use [SPushable] or [NonSPushable] when implementing a [SRouteInterface]
abstract class MaybeSPushable {}

/// One of the two [MaybeSPushable] type
/// 
/// 
/// [SRouteInterface] which use [SPushable] as generic are top level 
/// [SRouteInterface] which can be directly pushed into [SRouter]
abstract class SPushable extends MaybeSPushable {}

/// One of the two [MaybeSPushable] type
/// 
/// 
/// [SRouteInterface] which use [NonSPushable] as generic are [SRouteInterface]
/// which are nested in other [SRouteInterface] and therefore cannot be pushed
/// directly into [SRouter]
abstract class NonSPushable extends MaybeSPushable {}
