import '../s_router/s_router.dart';
import 'framework.dart';

/// The generic of [PageStackBase] which describes whether the route can
/// be pushed into [SRouter] or not.
///
///
/// DO use [NestedStack] or [NonNestedStack] when implementing a [PageStackBase]
abstract class MaybeNestedStack {}

/// Use [NonNestedStack] for [PageStackBase] which are used in [SRouter.to]
abstract class NonNestedStack extends MaybeNestedStack {}

/// Use [NestedStack] for [PageStackBase] which are nested in other (typically inside
/// a [MultiTabPageStack])
///
/// Passing the associated [PageStackBase] to [SRouter.to] is a compile error
/// since only top-level (i.e. [NonNestedStack]) [PageStackBase] can be navigated to
/// directly
abstract class NestedStack extends MaybeNestedStack {}
