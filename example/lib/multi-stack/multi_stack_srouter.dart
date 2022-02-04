import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

import 's_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: SRouter.build(
        initialPageStack: AppPageStack((state) => state),
        translatorsBuilder: (_) => [
          Multi2TabsTranslator<AppPageStack>(
            pageStack: AppPageStack.new,
            tab1Translators: _getTranslatorOfTab(TabItem.red),
            tab2Translators: _getTranslatorOfTab(TabItem.green),
          ),
          PathTranslator<SettingsPageStack>.parse(
            path: '/:color/settings',
            matchToPageStack: (match) => SettingsPageStack(
              tabItem: tabName.entries
                  .firstWhere((element) => element.value == match.pathParams['color'])
                  .key,
            ),
            pageStackToWebEntry: (route) => WebEntry(
              pathSegments: [tabName[route.tabItem]!, 'settings'],
            ),
          ),
        ],
      ),
    );
  }

  List<PageStackTranslator<PageStackBase>> _getTranslatorOfTab(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.red:
        return [
          PathTranslator<RedListPageStack>(
            path: '${tabName[tabItem]!}',
            pageStack: RedListPageStack(),
          ),
          PathTranslator<RedDetailPageStack>.parse(
            path: '${tabName[tabItem]!}/details_:materialIndex',
            matchToPageStack: (match) => RedDetailPageStack(
              materialIndex: int.parse(match.pathParams['materialIndex']!),
            ),
            pageStackToWebEntry: (route) =>
                WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
          ),
        ];
      case TabItem.green:
        return [
          PathTranslator<GreenListPageStack>(
            path: '${tabName[tabItem]!}',
            pageStack: GreenListPageStack(),
          ),
          PathTranslator<GreenDetailPageStack>.parse(
            path: '${tabName[tabItem]!}/details_:materialIndex',
            matchToPageStack: (match) => GreenDetailPageStack(
              materialIndex: int.parse(match.pathParams['materialIndex']!),
            ),
            pageStackToWebEntry: (route) =>
                WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
          ),
        ];
      // case TabItem.blue:
      //   return [
      //     SPathTranslator<BlueListPageStack, NonSPushable>(
      //       path: '${tabName[tabItem]!}',
      //       route: BlueListPageStack(),
      //     ),
      //     SPathTranslator<BlueDetailPageStack, NonSPushable>.parse(
      //       path: '${tabName[tabItem]!}/details_:materialIndex',
      //       matchToRoute: (match) => BlueDetailPageStack(
      //         materialIndex: int.parse(match.pathParams['materialIndex']!),
      //       ),
      //       routeToWebEntry: (route) =>
      //           WebEntry(path: '${tabName[tabItem]!}/details_${route.materialIndex}'),
      //     ),
      //   ];
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
      context.sRouter.to(
        AppPageStack(
          (state) => state.copyWith(
            activeIndex: TabItem.values.indexOf(tabItem),
            tab1PageStack: tabItem == TabItem.red ? RedListPageStack() : null,
            tab2PageStack: tabItem == TabItem.green ? GreenListPageStack() : null,
          ),
        ),
      );
    } else {
      context.sRouter.to(
        AppPageStack((state) => state.copyWith(activeIndex: TabItem.values.indexOf(tabItem))),
      );
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
        // _buildItem(TabItem.blue),
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
                  onPressed: () => context.sRouter.to(
                    AppPageStack(
                      (state) => state.copyWith(activeIndex: TabItem.values.indexOf(e)),
                    ),
                  ),
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
              onPressed: () => context.sRouter.to(SettingsPageStack(tabItem: e)),
              icon: Icon(Icons.settings, color: activeTabColor[e]),
            ),
          ),
        ),
      )
      .toList();
}

enum TabItem {
  red,
  green,
  // blue,
}

const Map<TabItem, String> tabName = {
  TabItem.red: 'red',
  TabItem.green: 'green',
  // TabItem.blue: 'blue',
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.red: Colors.red,
  TabItem.green: Colors.green,
  // TabItem.blue: Colors.blue,
};
