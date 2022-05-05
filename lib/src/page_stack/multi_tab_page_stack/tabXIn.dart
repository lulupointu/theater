import '../framework.dart';
import 'nesting_page_stack.dart';

/// The [PageStack] to use in the [NestingPageStack]
typedef NestedPageStack<T extends MultiTabsPageStack> = Tab1In<T>;

/// The 1th tab of a [MultiTabsPageStack].
mixin Tab1In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf2<T>, TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @override
  Tab1In<T>? get pageStackBellow => null;
}

/// The 2th tab of a [MultiTabsPageStack].
mixin Tab2In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf2<T>, TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @override
  Tab2In<T>? get pageStackBellow => null;
}

/// The 3th tab of a [MultiTabsPageStack].
mixin Tab3In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @override
  Tab3In<T>? get pageStackBellow => null;
}

/// The 4th tab of a [MultiTabsPageStack].
mixin Tab4In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @override
  Tab4In<T>? get pageStackBellow => null;
}

/// The 5th tab of a [MultiTabsPageStack].
mixin Tab5In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf5<T>, TabXOf6<T> {
  @override
  Tab5In<T>? get pageStackBellow => null;
}

/// The 6th tab of a [MultiTabsPageStack].
mixin Tab6In<T extends MultiTabsPageStack> on PageStackBase
    implements TabXOf6<T> {
  @override
  Tab6In<T>? get pageStackBellow => null;
}

/// A union class in which [Tab1In] and [Tab2In] are the two possible types.
mixin TabXOf2<T extends MultiTabsPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In] and [Tab3In] are the two possible
/// types.
mixin TabXOf3<T extends MultiTabsPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In] and [Tab4In] are the
/// two possible types.
mixin TabXOf4<T extends MultiTabsPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In], [Tab4In] and [Tab5In]
/// are the two possible types.
mixin TabXOf5<T extends MultiTabsPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In], [Tab4In], [Tab5In] and
/// [Tab6In] are the two possible types.
mixin TabXOf6<T extends MultiTabsPageStack> on PageStackBase {}
