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
        initialRoute: ScaffoldSRoute(activeTab: ScaffoldTab.books),
        translatorsBuilder: (_) => [
          STabbedRouteTranslator<ScaffoldSRoute, ScaffoldTab, SPushable>(
            routeBuilder: (tabs) {
              if (!tabs.entries.any((e) => e.value != null)) return null;

              final activeTabRoute = tabs.entries.firstWhere((e) => e.value != null);

              return ScaffoldSRoute(
                activeTab: activeTabRoute.key,
                booksViewSRoute: activeTabRoute.value is BooksViewSRoute
                    ? activeTabRoute.value as BooksViewSRoute
                    : null,
              );
            },
            tabTranslators: {
              ScaffoldTab.books: [
                STabbedRouteTranslator<BooksViewSRoute, BooksViewTab, NonSPushable>(
                  routeBuilder: (tabs) {
                    if (!tabs.entries.any((e) => e.value != null)) return null;

                    final activeTabRoute = tabs.entries.firstWhere((e) => e.value != null);

                    return BooksViewSRoute(activeTab: activeTabRoute.key);
                  },
                  tabTranslators: {
                    BooksViewTab.newBook: [
                      SPathTranslator<NewBooksSRoute, NonSPushable>(
                        path: '/books/new',
                        route: NewBooksSRoute(),
                      ),
                    ],
                    BooksViewTab.allBooks: [
                      SPathTranslator<AllBooksSRoute, NonSPushable>(
                        path: '/books/all',
                        route: AllBooksSRoute(),
                      ),
                    ],
                  },
                ),
              ],
              ScaffoldTab.settings: [
                SPathTranslator<SettingsSRoute, NonSPushable>(
                  path: '/settings',
                  route: SettingsSRoute(),
                ),
              ],
            },
          ),
          SRedirectorTranslator(
            path: '*',
            route: ScaffoldSRoute(activeTab: ScaffoldTab.books),
          ),
        ],
      ),
    );
  }
}

enum ScaffoldTab { books, settings }

class ScaffoldSRoute extends STabbedRoute<ScaffoldTab, SPushable> {
  ScaffoldSRoute({required this.activeTab, BooksViewSRoute? booksViewSRoute})
      : super(sTabs: {
          ScaffoldTab.books: STab(
            (tab) => booksViewSRoute ?? tab,
            initialSRoute: BooksViewSRoute(activeTab: BooksViewTab.newBook),
          ),
          ScaffoldTab.settings: STab.static(SettingsSRoute()),
        });

  @override
  final ScaffoldTab activeTab;

  @override
  Widget tabsBuilder(BuildContext context, Map<ScaffoldTab, Widget> tabs) {
    return ScaffoldScreen(
      child: tabs[activeTab]!,
      currentIndex: ScaffoldTab.values.indexOf(activeTab),
    );
  }

  @override
  STabbedRoute<ScaffoldTab, SPushable>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  ) =>
      ScaffoldSRoute(
        activeTab: activeTab,
        booksViewSRoute:
            activeTabSRouteBellow is BooksViewSRoute ? activeTabSRouteBellow : null,
      );
}

enum BooksViewTab { newBook, allBooks }

class BooksViewSRoute extends STabbedRoute<BooksViewTab, NonSPushable> {
  BooksViewSRoute({required this.activeTab})
      : super(sTabs: {
          BooksViewTab.newBook: STab.static(NewBooksSRoute()),
          BooksViewTab.allBooks: STab.static(AllBooksSRoute()),
        });

  @override
  final BooksViewTab activeTab;

  @override
  Widget tabsBuilder(BuildContext context, Map<BooksViewTab, Widget> tabs) {
    return BooksScreen(
      selectedTab: BooksViewTab.values.indexOf(activeTab),
      tabs: tabs.values.toList(),
    );
  }

  @override
  STabbedRoute<BooksViewTab, NonSPushable>? onTabPop(BuildContext context, _) =>
      BooksViewSRoute(activeTab: activeTab);
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
        onTap: (idx) => context.sRouter.to(ScaffoldSRoute(activeTab: ScaffoldTab.values[idx])),
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

    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.selectedTab,
    );
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
          onTap: (index) => context.sRouter.to(
            ScaffoldSRoute(
              activeTab: ScaffoldTab.books,
              booksViewSRoute: BooksViewSRoute(activeTab: BooksViewTab.values[index]),
            ),
          ),
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
