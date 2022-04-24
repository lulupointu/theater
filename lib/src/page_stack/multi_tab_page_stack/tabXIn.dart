// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';

typedef NestedPageStack<T extends MultiTabPageStack> = Tab1In<T>;

/// The 1th tab of a [MultiTabPageStack].
mixin Tab1In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf2<T>, TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 0;
  }

  @nonVirtual
  bool isBellow(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[0] == this;
  }

  @override
  Tab1In<T>? get pageStackBellow => null;
}

/// The 2th tab of a [MultiTabPageStack].
mixin Tab2In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf2<T>, TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 1;
  }

  @nonVirtual
  bool isTopPageStack(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[1] == this;
  }

  @override
  Tab2In<T>? get pageStackBellow => null;
}

/// The 3th tab of a [MultiTabPageStack].
mixin Tab3In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf3<T>, TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 2;
  }

  @nonVirtual
  bool isTopPageStack(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[2] == this;
  }

  @override
  Tab3In<T>? get pageStackBellow => null;
}

/// The 4th tab of a [MultiTabPageStack].
mixin Tab4In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf4<T>, TabXOf5<T>, TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 3;
  }

  @nonVirtual
  bool isTopPageStack(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[3] == this;
  }

  @override
  Tab4In<T>? get pageStackBellow => null;
}

/// The 5th tab of a [MultiTabPageStack].
mixin Tab5In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf5<T>, TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 4;
  }

  @nonVirtual
  bool isTopPageStack(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[4] == this;
  }

  @override
  Tab5In<T>? get pageStackBellow => null;
}

/// The 6th tab of a [MultiTabPageStack].
mixin Tab6In<T extends MultiTabPageStack> on PageStackBase
    implements TabXOf6<T> {
  @nonVirtual
  bool isActiveTab(BuildContext context) {
    return MultiTabStateProvider.of(context).activeIndex == 5;
  }

  @nonVirtual
  bool isTopPageStack(BuildContext context) {
    return MultiTabStateProvider.tabsPageStacksOf(context)[5] == this;
  }

  @override
  Tab6In<T>? get pageStackBellow => null;
}

/// A union class in which [Tab1In] and [Tab2In] are the two possible types.
mixin TabXOf2<T extends MultiTabPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In] and [Tab3In] are the two possible
/// types.
mixin TabXOf3<T extends MultiTabPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In] and [Tab4In] are the
/// two possible types.
mixin TabXOf4<T extends MultiTabPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In], [Tab4In] and [Tab5In]
/// are the two possible types.
mixin TabXOf5<T extends MultiTabPageStack> on PageStackBase {}

/// A union class in which [Tab1In], [Tab2In], [Tab3In], [Tab4In], [Tab5In] and
/// [Tab6In] are the two possible types.
mixin TabXOf6<T extends MultiTabPageStack> on PageStackBase {}
