import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'multi_stack_srouter.dart';

class SettingsSRoute extends SRoute<SPushable> {
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
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) {
    return AppSRoute(activeTab: tabItem);
  }
}

class AppSRoute extends STabbedRoute<TabItem, SPushable> {
  static final initialTabsRoute = {
    TabItem.red: RedListSRoute(),
    TabItem.green: GreenListSRoute(),
    TabItem.blue: BlueListSRoute(),
  };

  AppSRoute({
    required this.activeTab,
    SRouteInterface<NonSPushable>? updatedSRoute,
  }) : super(sTabs: {
          for (final tabItem in TabItem.values)
            tabItem: STab(
              initialSRoute: initialTabsRoute[tabItem]!,
              currentSRoute: activeTab == tabItem ? updatedSRoute : null,
            ),
        });

  @override
  final TabItem activeTab;

  @override
  Widget tabsBuilder(BuildContext context, Map<TabItem, Widget> tabs) {
    return App(activeTab: activeTab, tabs: tabs);
  }

  @override
  STabbedRoute<TabItem, SPushable>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeSRouteBellow,
  ) {
    return AppSRoute(activeTab: activeTab, updatedSRoute: activeSRouteBellow);
  }
}

class RedListSRoute extends ColoredListSRoute {
  RedListSRoute() : super(TabItem.red);
}

class BlueListSRoute extends ColoredListSRoute {
  BlueListSRoute() : super(TabItem.blue);
}

class GreenListSRoute extends ColoredListSRoute {
  GreenListSRoute() : super(TabItem.green);
}

abstract class ColoredListSRoute extends SRoute<NonSPushable> {
  final TabItem tabItem;

  ColoredListSRoute(this.tabItem);

  @override
  Widget build(BuildContext context) {
    return ColorsListScreen(
      tabItem: tabItem,
      color: activeTabColor[tabItem]!,
      title: tabName[tabItem]!,
      onPush: (materialIndex) => context.sRouter.push(
        AppSRoute(
          activeTab: tabItem,
          updatedSRoute: _detailSRoute(tabItem: tabItem, materialIndex: materialIndex),
        ),
      ),
    );
  }

  _detailSRoute({required TabItem tabItem, required int materialIndex}) {
    switch (tabItem) {
      case TabItem.red:
        return RedDetailSRoute(materialIndex: materialIndex);
      case TabItem.green:
        return GreenDetailSRoute(materialIndex: materialIndex);
      case TabItem.blue:
        return BlueDetailSRoute(materialIndex: materialIndex);
    }
  }
}

class RedDetailSRoute extends ColoredDetailSRoute {
  final int materialIndex;

  RedDetailSRoute({required this.materialIndex}) : super(TabItem.red);
}

class BlueDetailSRoute extends ColoredDetailSRoute {
  final int materialIndex;

  BlueDetailSRoute({required this.materialIndex}) : super(TabItem.blue);
}

class GreenDetailSRoute extends ColoredDetailSRoute {
  final int materialIndex;

  GreenDetailSRoute({required this.materialIndex}) : super(TabItem.green);
}

abstract class ColoredDetailSRoute extends SRoute<NonSPushable> {
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
  SRouteInterface<NonSPushable>? buildSRouteBellow(BuildContext context) {
    switch (tabItem) {
      case TabItem.red:
        return RedListSRoute();
      case TabItem.green:
        return GreenListSRoute();
      case TabItem.blue:
        return BlueListSRoute();
    }
  }
}