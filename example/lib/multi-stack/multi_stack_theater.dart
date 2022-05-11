import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

import 'page_stacks.dart';

void main() {
  Theater.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Theater(
        initialPageStack: AppPageStack((state) => state),
        translatorsBuilder: (_) => [
          Multi2TabsTranslator<AppPageStack>(
            pageStack: AppPageStack.new,
            tab1Translators: [
              PathTranslator<RedListPageStack>(
                path: '${tabName[TabItem.red]!}',
                pageStack: RedListPageStack(),
              ),
              PathTranslator<RedDetailPageStack>.parse(
                path: '${tabName[TabItem.red]!}/details_:materialIndex',
                matchToPageStack: (match) => RedDetailPageStack(
                  materialIndex: int.parse(match.pathParams['materialIndex']!),
                ),
                pageStackToWebEntry: (route) => WebEntry(
                    path:
                        '${tabName[TabItem.red]!}/details_${route.materialIndex}'),
              ),
            ],
            tab2Translators: [
              PathTranslator<GreenListPageStack>(
                path: '${tabName[TabItem.green]!}',
                pageStack: GreenListPageStack(),
              ),
              PathTranslator<GreenDetailPageStack>.parse(
                path: '${tabName[TabItem.green]!}/details_:materialIndex',
                matchToPageStack: (match) => GreenDetailPageStack(
                  materialIndex: int.parse(match.pathParams['materialIndex']!),
                ),
                pageStackToWebEntry: (route) => WebEntry(
                    path:
                        '${tabName[TabItem.green]!}/details_${route.materialIndex}'),
              ),
            ],
          ),
          PathTranslator<SettingsPageStack>.parse(
            path: '/:color/settings',
            matchToPageStack: (match) => SettingsPageStack(
              tabItem: tabName.entries
                  .firstWhere(
                      (element) => element.value == match.pathParams['color'])
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
}

class App extends StatelessWidget {
  final TabItem currentTab;

  final Map<TabItem, Widget> tabs;

  App({Key? key, required this.currentTab, required this.tabs})
      : super(key: key);

  void _selectTab(BuildContext context, TabItem tabItem) {
    if (tabItem == currentTab) {
      // pop to first route
      context.to(
        AppPageStack(
          (state) => state.withCurrentStack(
            AppPageStack.initState.tabsPageStacks[state.currentIndex],
          ),
        ),
      );
    } else {
      context.to(
        AppPageStack(
          (state) => state.withCurrentIndex(TabItem.values.indexOf(tabItem)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: TabItem.values.indexOf(currentTab),
        children: tabs.values.toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTab: currentTab,
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
      ],
      onTap: (index) => onSelectTab(context, TabItem.values[index]),
      currentIndex: currentTab.index,
      selectedItemColor: currentTabColor[currentTab]!,
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
    return currentTab == item ? currentTabColor[item]! : Colors.grey;
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
                  onPressed: () => context.to(
                    AppPageStack(
                      (state) => state.withCurrentIndex(
                        TabItem.values.indexOf(e),
                      ),
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

  final List<int> materialIndices = [
    900,
    800,
    700,
    600,
    500,
    400,
    300,
    200,
    100,
    50
  ];

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
  SettingsScreen(
      {required this.tabItem, required this.color, required this.title});

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

List<Widget> _buildSettingsButtons(BuildContext context,
    {required TabItem tabItem}) {
  return TabItem.values
      .map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentTabColor[tabItem]!.shade100,
            ),
            child: IconButton(
              onPressed: () =>
                  context.to(SettingsPageStack(tabItem: e)),
              icon: Icon(Icons.settings, color: currentTabColor[e]),
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

const Map<TabItem, MaterialColor> currentTabColor = {
  TabItem.red: Colors.red,
  TabItem.green: Colors.green,
  // TabItem.blue: Colors.blue,
};
