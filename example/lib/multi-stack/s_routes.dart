import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'multi_stack_srouter.dart';

class SettingsPageStack extends PageStack {
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
  PageStackBase get pageStackBellow {
    return AppPageStack(
      (state) => state.copyWith(activeIndex: TabItem.values.indexOf(tabItem)),
    );
  }
}

class AppPageStack extends Multi2TabsPageStack {
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
        tab1PageStack: RedListPageStack(),
        tab2PageStack: GreenListPageStack(),
      );
}

class RedListPageStack extends ColoredListPageStack with Tab1In<AppPageStack> {
  RedListPageStack() : super(TabItem.red);
}

class GreenListPageStack extends ColoredListPageStack with Tab2In<AppPageStack> {
  GreenListPageStack() : super(TabItem.green);
}

abstract class ColoredListPageStack extends PageStack {
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
            tab1PageStack: tabItem == TabItem.red
                ? RedDetailPageStack(materialIndex: materialIndex)
                : null,
            tab2PageStack: tabItem == TabItem.green
                ? GreenDetailPageStack(materialIndex: materialIndex)
                : null,
          ),
        ),
      ),
    );
  }
}

class RedDetailPageStack extends ColoredDetailPageStack with Tab1In<AppPageStack> {
  final int materialIndex;

  RedDetailPageStack({required this.materialIndex}) : super(TabItem.red);
}

class GreenDetailPageStack extends ColoredDetailPageStack with Tab2In<AppPageStack> {
  final int materialIndex;

  GreenDetailPageStack({required this.materialIndex}) : super(TabItem.green);
}

abstract class ColoredDetailPageStack extends PageStack {
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
  PageStackBase? get pageStackBellow {
    switch (tabItem) {
      case TabItem.red:
        return RedListPageStack();
      case TabItem.green:
        return GreenListPageStack();
    }
  }
}
