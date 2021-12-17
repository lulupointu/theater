import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'multi_stack_srouter.dart';

class SettingsPageStack extends PageStack<NonNestedStack> {
  final TabItem tabItem;

  SettingsPageStack({required this.tabItem});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      tabItem: tabItem,
      color: activeTabColor[tabItem]!,
      title: '${_withCapitalLetter(tabName[tabItem]!)} settings',
    );
  }

  _withCapitalLetter(String word) => word[0].toUpperCase() + word.substring(1);

  @override
  PageStackBase<NonNestedStack> createPageStackBellow(BuildContext context) {
    return AppPageStack(
      (state) => state.copyWith(activeIndex: TabItem.values.indexOf(tabItem)),
    );
  }
}

class AppPageStack extends Multi2TabsPageStack<NonNestedStack> {
  AppPageStack(StateBuilder<Multi2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) {
    return App(
      activeTab: TabItem.values[state.activeIndex],
      tabs: {TabItem.red: state.tabs[0], TabItem.green: state.tabs[1]},
    );
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1SRoute: RedListPageStack(),
        tab2SRoute: GreenListPageStack(),
      );
}

class RedListPageStack extends ColoredListPageStack {
  RedListPageStack() : super(TabItem.red);
}

class GreenListPageStack extends ColoredListPageStack {
  GreenListPageStack() : super(TabItem.green);
}

abstract class ColoredListPageStack extends PageStack<NestedStack> {
  final TabItem tabItem;

  ColoredListPageStack(this.tabItem);

  @override
  Widget build(BuildContext context) {
    return ColorsListScreen(
      tabItem: tabItem,
      color: activeTabColor[tabItem]!,
      title: tabName[tabItem]!,
      onPush: (materialIndex) => context.sRouter.to(
        AppPageStack(
          (state) => state.copyWith(
            activeIndex: TabItem.values.indexOf(tabItem),
            tab1SRoute:
                tabItem == TabItem.red ? RedDetailPageStack(materialIndex: materialIndex) : null,
            tab2SRoute: tabItem == TabItem.green
                ? GreenDetailPageStack(materialIndex: materialIndex)
                : null,
          ),
        ),
      ),
    );
  }
}

class RedDetailPageStack extends ColoredDetailPageStack {
  final int materialIndex;

  RedDetailPageStack({required this.materialIndex}) : super(TabItem.red);
}

class GreenDetailPageStack extends ColoredDetailPageStack {
  final int materialIndex;

  GreenDetailPageStack({required this.materialIndex}) : super(TabItem.green);
}

abstract class ColoredDetailPageStack extends PageStack<NestedStack> {
  int get materialIndex;

  final TabItem tabItem;

  ColoredDetailPageStack(this.tabItem);

  @override
  Widget build(BuildContext context) {
    return ColorDetailScreen(
      tabItem: tabItem,
      color: activeTabColor[tabItem]!,
      title: tabName[tabItem]!,
      materialIndex: materialIndex,
    );
  }

  @override
  PageStackBase<NestedStack>? createPageStackBellow(BuildContext context) {
    switch (tabItem) {
      case TabItem.red:
        return RedListPageStack();
      case TabItem.green:
        return GreenListPageStack();
    }
  }
}
