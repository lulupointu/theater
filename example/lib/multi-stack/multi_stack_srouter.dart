import 'package:flutter/material.dart';
import 'package:srouter/src/route/pushables/pushables.dart';
import 'package:srouter/srouter.dart';

import 's_routes.dart';

void main() {
  initializeSRouter();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SRouter(
        initialRoute: AppSRoute(activeTab: TabItem.red),
        translatorsBuilder: (_) => [
          SPathTranslator<SettingsSRoute, SPushable>(
            path: '/:color/settings',
            matchToRoute: (match) => SettingsSRoute(
              tabItem: tabName.entries
                  .firstWhere((element) => element.value == match.pathParams['color'])
                  .key,
            ),
            routeToWebEntry: (route) => WebEntry(
              pathSegments: [tabName[route.tabItem]!, 'settings'],
            ),
          ),
          STabbedRouteTranslator<AppSRoute, TabItem, SPushable>.static(
            matchToRoute: (_, tabsRoute) {
              if (!tabsRoute.entries.any((e) => e.value != null)) return null;

              final activeTabRoute = tabsRoute.entries.firstWhere((e) => e.value != null);

              return AppSRoute.toTab(
                activeTab: activeTabRoute.key,
                newTabRoute: activeTabRoute.value!,
              );
            },
            tabTranslators: {
              for (final tabItem in TabItem.values) tabItem: _getTranslatorOfTab(tabItem),
            },
          ),
        ],
      ),
    );
  }

  List<STranslator<SRouteInterface<NonSPushable>, NonSPushable>> _getTranslatorOfTab(
      TabItem tabItem) {
    switch (tabItem) {
      case TabItem.red:
        return [
          SPathTranslator<RedListSRoute, NonSPushable>.static(
            path: '${tabName[tabItem]!}',
            route: RedListSRoute(),
          ),
          SPathTranslator<RedDetailSRoute, NonSPushable>(
            path: '${tabName[tabItem]!}/details_:materialIndex',
            matchToRoute: (match) => RedDetailSRoute(
              materialIndex: int.parse(match.pathParams['materialIndex']!),
            ),
            routeToWebEntry: (route) =>
                WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
          ),
        ];
      case TabItem.green:
        return [
          SPathTranslator<GreenListSRoute, NonSPushable>.static(
            path: '${tabName[tabItem]!}',
            route: GreenListSRoute(),
          ),
          SPathTranslator<GreenDetailSRoute, NonSPushable>(
            path: '${tabName[tabItem]!}/details_:materialIndex',
            matchToRoute: (match) => GreenDetailSRoute(
              materialIndex: int.parse(match.pathParams['materialIndex']!),
            ),
            routeToWebEntry: (route) =>
                WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
          ),
        ];
      case TabItem.blue:
        return [
          SPathTranslator<BlueListSRoute, NonSPushable>.static(
            path: '${tabName[tabItem]!}',
            route: BlueListSRoute(),
          ),
          SPathTranslator<BlueDetailSRoute, NonSPushable>(
            path: '${tabName[tabItem]!}/details_:materialIndex',
            matchToRoute: (match) => BlueDetailSRoute(
              materialIndex: int.parse(match.pathParams['materialIndex']!),
            ),
            routeToWebEntry: (route) =>
                WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
          ),
        ];
    }
  }
}

class App extends StatelessWidget {
  final TabItem activeTab;

  final Map<TabItem, Widget> tabs;

  App({Key? key, required this.activeTab, required this.tabs}) : super(key: key);

  void _selectTab(BuildContext context, TabItem tabItem) {
    if (tabItem == activeTab) {
      // pop to first route
      context.sRouter.push(
        AppSRoute.toTab(activeTab: tabItem, newTabRoute: AppSRoute.initialTabsRoute[tabItem]!),
      );
    } else {
      context.sRouter.push(AppSRoute(activeTab: tabItem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: TabItem.values.indexOf(activeTab),
        children: tabs.values.toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTab: activeTab,
        onSelectTab: _selectTab,
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({required this.currentTab, required this.onSelectTab});

  final TabItem currentTab;
  final void Function(BuildContext context, TabItem tabItem) onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(TabItem.red),
        _buildItem(TabItem.green),
        _buildItem(TabItem.blue),
      ],
      onTap: (index) => onSelectTab(context, TabItem.values[index]),
      currentIndex: currentTab.index,
      selectedItemColor: activeTabColor[currentTab]!,
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    return BottomNavigationBarItem(
      icon: Icon(
        Icons.layers,
        color: _colorTabMatching(tabItem),
      ),
      label: tabName[tabItem],
    );
  }

  Color _colorTabMatching(TabItem item) {
    return currentTab == item ? activeTabColor[item]! : Colors.grey;
  }
}

class ColorDetailScreen extends StatelessWidget {
  ColorDetailScreen({
    required this.tabItem,
    required this.color,
    required this.title,
    this.materialIndex: 500,
  });

  final TabItem tabItem;
  final MaterialColor color;
  final String title;
  final int materialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text('$title[$materialIndex]'),
        actions: _buildSettingsButtons(context, tabItem: tabItem),
      ),
      body: Container(
        color: color[materialIndex],
        child: _buildButtons(context),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TabItem.values
            .where((element) => element != tabItem)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(50.0),
                child: ElevatedButton(
                  onPressed: () => context.sRouter.push(AppSRoute(activeTab: e)),
                  child: Text('Go to ${tabName[e]}'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ColorsListScreen extends StatelessWidget {
  ColorsListScreen({
    required this.tabItem,
    required this.color,
    required this.title,
    this.onPush,
  });

  final TabItem tabItem;
  final MaterialColor color;
  final String title;
  final ValueChanged<int>? onPush;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _buildSettingsButtons(context, tabItem: tabItem),
        backgroundColor: color,
      ),
      body: Container(
        color: Colors.white,
        child: _buildList(),
      ),
    );
  }

  final List<int> materialIndices = [900, 800, 700, 600, 500, 400, 300, 200, 100, 50];

  Widget _buildList() {
    return ListView.builder(
      itemCount: materialIndices.length,
      itemBuilder: (BuildContext content, int index) {
        int materialIndex = materialIndices[index];
        return Container(
          height: 100,
          color: color[materialIndex],
          child: InkWell(
            onTap: () => onPush?.call(materialIndex),
            child: Center(
              child: ListTile(
                title: Text('$materialIndex', style: TextStyle(fontSize: 24.0)),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  SettingsScreen({required this.tabItem, required this.color, required this.title});

  final TabItem tabItem;
  final MaterialColor color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        actions: _buildSettingsButtons(context, tabItem: tabItem),
      ),
      body: Container(
        color: color,
        child: Center(
          child: Text('Something'),
        ),
      ),
    );
  }
}

List<Widget> _buildSettingsButtons(BuildContext context, {required TabItem tabItem}) {
  return TabItem.values
      .map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeTabColor[tabItem]!.shade100,
            ),
            child: IconButton(
              onPressed: () => context.sRouter.push(SettingsSRoute(tabItem: e)),
              icon: Icon(Icons.settings, color: activeTabColor[e]),
            ),
          ),
        ),
      )
      .toList();
}

enum TabItem { red, green, blue }

const Map<TabItem, String> tabName = {
  TabItem.red: 'red',
  TabItem.green: 'green',
  TabItem.blue: 'blue',
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.red: Colors.red,
  TabItem.green: Colors.green,
  TabItem.blue: Colors.blue,
};
