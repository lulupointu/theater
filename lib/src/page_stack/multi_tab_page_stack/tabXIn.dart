

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';

mixin Tab1In<T extends MultiTabPageStack> on PageStackBase {
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

mixin Tab2In<T extends MultiTabPageStack> on PageStackBase {
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

mixin Tab3In<T extends MultiTabPageStack> on PageStackBase {
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

mixin Tab4In<T extends MultiTabPageStack> on PageStackBase {
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

mixin Tab5In<T extends MultiTabPageStack> on PageStackBase {
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

mixin Tab6In<T extends MultiTabPageStack> on PageStackBase {
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