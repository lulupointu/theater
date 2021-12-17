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
      home: SRouter(
        initialRoute: ScaffoldSRoute((state) => state),
        translatorsBuilder: (_) => [
          S2TabsRouteTranslator<ScaffoldSRoute, NotSNested>(
            route: ScaffoldSRoute.new,
            tab1Translators: [
              S2TabsRouteTranslator<BooksViewSRoute, SNested>(
                route: BooksViewSRoute.new,
                tab1Translators: [
                  SPathTranslator<NewBooksSRoute, SNested>(
                    path: '/books/new',
                    route: NewBooksSRoute(),
                  ),
                ],
                tab2Translators: [
                  SPathTranslator<AllBooksSRoute, SNested>(
                    path: '/books/all',
                    route: AllBooksSRoute(),
                  ),
                ],
              ),
            ],
            tab2Translators: [
              SPathTranslator<SettingsSRoute, SNested>(
                path: '/settings',
                route: SettingsSRoute(),
              ),
            ],
          ),
          SRedirectorTranslator(
            path: '*',
            route: ScaffoldSRoute((state) => state),
          ),
        ],
      ),
    );
  }
}

class ScaffoldSRoute extends S2TabsRoute<NotSNested> {
  ScaffoldSRoute(StateBuilder<S2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, S2TabsState state) {
    return ScaffoldScreen(
      child: state.tabs[state.activeIndex],
      currentIndex: state.activeIndex,
    );
  }

  @override
  S2TabsState get initialState => S2TabsState(
        activeIndex: 0,
        tab1SRoute: BooksViewSRoute((state) => state),
        tab2SRoute: SettingsSRoute(),
      );
}

class BooksViewSRoute extends S2TabsRoute<SNested> {
  BooksViewSRoute(StateBuilder<S2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, S2TabsState state) {
    return BooksScreen(selectedTab: state.activeIndex, tabs: state.tabs);
  }

  @override
  S2TabsState get initialState => S2TabsState(
        activeIndex: 0,
        tab1SRoute: NewBooksSRoute(),
        tab2SRoute: AllBooksSRoute(),
      );
}

class NewBooksSRoute extends SRoute<SNested> {
  @override
  Widget build(BuildContext context) => NewBooksScreen();
}

class AllBooksSRoute extends SRoute<SNested> {
  @override
  Widget build(BuildContext context) => AllBooksScreen();
}

class SettingsSRoute extends SRoute<SNested> {
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
        onTap: (idx) => context.sRouter.to(
          ScaffoldSRoute((state) => state.copyWith(activeIndex: idx)),
        ),
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
              (state) => state.copyWith(
                tab1SRoute: BooksViewSRoute((state) => state.copyWith(activeIndex: index)),
              ),
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
