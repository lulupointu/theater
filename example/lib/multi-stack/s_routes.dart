import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'multi_stack_srouter.dart';

class SettingsSRoute extends SRoute<NotSNested> {
  final TabItem tabItem;

  SettingsSRoute({required this.tabItem});

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
  SRouteBase<NotSNested> createSRouteBellow(BuildContext context) {
    return AppSRoute(
      (state) => state.copyWith(activeIndex: TabItem.values.indexOf(tabItem)),
    );
  }
}

class AppSRoute extends S2TabsRoute<NotSNested> {
  AppSRoute(StateBuilder<S2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, S2TabsState state) {
    return App(
      activeTab: TabItem.values[state.activeIndex],
      tabs: {TabItem.red: state.tabs[0], TabItem.green: state.tabs[1]},
    );
  }

  @override
  S2TabsState get initialState => S2TabsState(
        activeIndex: 0,
        tab1SRoute: RedListSRoute(),
        tab2SRoute: GreenListSRoute(),
      );
}

class RedListSRoute extends ColoredListSRoute {
  RedListSRoute() : super(TabItem.red);
}

class GreenListSRoute extends ColoredListSRoute {
  GreenListSRoute() : super(TabItem.green);
}

abstract class ColoredListSRoute extends SRoute<SNested> {
  final TabItem tabItem;

  ColoredListSRoute(this.tabItem);

  @override
  Widget build(BuildContext context) {
    return ColorsListScreen(
      tabItem: tabItem,
      color: activeTabColor[tabItem]!,
      title: tabName[tabItem]!,
      onPush: (materialIndex) => context.sRouter.to(
        AppSRoute(
          (state) => state.copyWith(
            activeIndex: TabItem.values.indexOf(tabItem),
            tab1SRoute:
                tabItem == TabItem.red ? RedDetailSRoute(materialIndex: materialIndex) : null,
            tab2SRoute: tabItem == TabItem.green
                ? GreenDetailSRoute(materialIndex: materialIndex)
                : null,
          ),
        ),
      ),
    );
  }
}

class RedDetailSRoute extends ColoredDetailSRoute {
  final int materialIndex;

  RedDetailSRoute({required this.materialIndex}) : super(TabItem.red);
}

class GreenDetailSRoute extends ColoredDetailSRoute {
  final int materialIndex;

  GreenDetailSRoute({required this.materialIndex}) : super(TabItem.green);
}

abstract class ColoredDetailSRoute extends SRoute<SNested> {
  int get materialIndex;

  final TabItem tabItem;

  ColoredDetailSRoute(this.tabItem);

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
  SRouteBase<SNested>? createSRouteBellow(BuildContext context) {
    switch (tabItem) {
      case TabItem.red:
        return RedListSRoute();
      case TabItem.green:
        return GreenListSRoute();
    }
  }
}
