// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

void main() {
  initializeSRouter();

  runApp(BooksApp());
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: SRouter(
        initialRoute: ScaffoldSRoute(activeTab: 0),
        translatorsBuilder: (_) => [
          STabbedRouteTranslator<ScaffoldSRoute, int, SPushable>(
            routeBuilder: (tabs) {
              if (!tabs.entries.any((e) => e.value != null)) return null;

              final activeTabRoute = tabs.entries.firstWhere((e) => e.value != null);

              return ScaffoldSRoute._toTab(
                activeTab: activeTabRoute.key,
                newTabRoute: activeTabRoute.value,
              );
            },
            tabTranslators: {
              0: [
                STabbedRouteTranslator<TabViewSRoute, int, NonSPushable>(
                  routeBuilder: (tabs) {
                    if (!tabs.entries.any((e) => e.value != null)) return null;

                    final activeTabRoute = tabs.entries.firstWhere((e) => e.value != null);

                    return TabViewSRoute(activeTab: activeTabRoute.key);
                  },
                  tabTranslators: {
                    0: [
                      SPathTranslator<NewBooksSRoute, NonSPushable>(
                        path: '/books/new',
                        route: NewBooksSRoute(),
                      ),
                    ],
                    1: [
                      SPathTranslator<AllBooksSRoute, NonSPushable>(
                        path: '/books/all',
                        route: AllBooksSRoute(),
                      ),
                    ],
                  },
                ),
              ],
              1: [
                SPathTranslator<SettingsSRoute, NonSPushable>(
                  path: '/settings',
                  route: SettingsSRoute(),
                ),
              ],
            },
          ),
          SRedirectorTranslator(path: '*', route: ScaffoldSRoute(activeTab: 0)),
        ],
      ),
    );
  }
}

class ScaffoldSRoute extends STabbedRoute<int, SPushable> {
  static final _initialSRoutes = {
    0: TabViewSRoute(activeTab: 0),
    1: SettingsSRoute(),
  };

  ScaffoldSRoute({required this.activeTab, int? tabViewTab})
      : super(
          sTabs: {
            0: STab(
              initialSRoute: _initialSRoutes[0]!,
              currentSRoute: tabViewTab != null ? TabViewSRoute(activeTab: tabViewTab) : null,
            ),
            1: STab(initialSRoute: _initialSRoutes[1]!, currentSRoute: null),
          },
        );

  // This factory is used in [onTabPop] and may used in the [STabbedTranslator]
  ScaffoldSRoute._toTab({
    required this.activeTab,
    SRouteInterface<NonSPushable>? newTabRoute,
  }) : super(
          sTabs: {
            0: STab(
              initialSRoute: _initialSRoutes[0]!,
              currentSRoute: activeTab == 0 ? newTabRoute : null,
            ),
            1: STab(
              initialSRoute: _initialSRoutes[1]!,
              currentSRoute: activeTab == 1 ? newTabRoute : null,
            ),
          },
        );

  @override
  final int activeTab;

  @override
  Widget tabsBuilder(BuildContext context, Map<int, Widget> tabs) {
    return ScaffoldScreen(child: tabs[activeTab]!, currentIndex: activeTab);
  }

  @override
  STabbedRoute<int, SPushable>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  ) {
    return ScaffoldSRoute._toTab(
      activeTab: activeTab,
      newTabRoute: activeTabSRouteBellow,
    );
  }
}

class TabViewSRoute extends STabbedRoute<int, NonSPushable> {
  TabViewSRoute({required this.activeTab})
      : super(
          sTabs: {
            0: STab(initialSRoute: NewBooksSRoute(), currentSRoute: null),
            1: STab(initialSRoute: AllBooksSRoute(), currentSRoute: null),
          },
        );

  @override
  final int activeTab;

  @override
  Widget tabsBuilder(BuildContext context, Map<int, Widget> tabs) {
    return BooksScreen(selectedTab: activeTab, tabs: tabs.values.toList());
  }

  @override
  STabbedRoute<int, NonSPushable>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  ) =>
      TabViewSRoute(activeTab: activeTab);
}

class NewBooksSRoute extends SRoute<NonSPushable> {
  @override
  Widget build(BuildContext context) => NewBooksScreen();
}

class AllBooksSRoute extends SRoute<NonSPushable> {
  @override
  Widget build(BuildContext context) => AllBooksScreen();
}

class SettingsSRoute extends SRoute<NonSPushable> {
  @override
  Widget build(BuildContext context) => SettingsScreen();
}

class ScaffoldScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldScreen({
    Key? key,
    required this.child,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) => context.sRouter.to(ScaffoldSRoute(activeTab: idx)),
        items: [
          BottomNavigationBarItem(
            label: 'Books',
            icon: Icon(Icons.chrome_reader_mode_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}

class BooksScreen extends StatefulWidget {
  final int selectedTab;
  final List<Widget> tabs;

  BooksScreen({
    Key? key,
    required this.selectedTab,
    required this.tabs,
  }) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.selectedTab);
  }

  @override
  void didUpdateWidget(BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.selectedTab;
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: (value) =>
              context.sRouter.to(ScaffoldSRoute(activeTab: 0, tabViewTab: value)),
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(icon: Icon(Icons.bathtub), text: 'New'),
            Tab(icon: Icon(Icons.group), text: 'All'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs,
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}

class AllBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('All Books'),
      ),
    );
  }
}

class NewBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('New Books'),
      ),
    );
  }
}
