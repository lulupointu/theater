// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: SRouter.build(
        initialPageStack: ScaffoldPageStack((state) => state),
        translatorsBuilder: (_) => [
          Multi2TabsTranslator<ScaffoldPageStack>(
            pageStack: ScaffoldPageStack.new,
            tab1Translators: [
              Multi2TabsTranslator<BooksViewPageStack>(
                pageStack: BooksViewPageStack.new,
                tab1Translators: [
                  PathTranslator<NewBooksPageStack>(
                    path: '/books/new',
                    pageStack: NewBooksPageStack(),
                  ),
                ],
                tab2Translators: [
                  PathTranslator<AllBooksPageStack>(
                    path: '/books/all',
                    pageStack: AllBooksPageStack(),
                  ),
                ],
              ),
            ],
            tab2Translators: [
              PathTranslator<SettingsPageStack>(
                path: '/settings',
                pageStack: SettingsPageStack(),
              ),
            ],
          ),
          RedirectorTranslator(
            path: '*',
            pageStack: ScaffoldPageStack((state) => state),
          ),
        ],
      ),
    );
  }
}

class ScaffoldPageStack extends Multi2TabsPageStack {
  ScaffoldPageStack(StateBuilder<Multi2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) {
    return ScaffoldScreen(
      child: state.tabs[state.activeIndex],
      currentIndex: state.activeIndex,
    );
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1PageStack: BooksViewPageStack((state) => state),
        tab2PageStack: SettingsPageStack(),
      );
}

class BooksViewPageStack extends Multi2TabsPageStack {
  BooksViewPageStack(StateBuilder<Multi2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) {
    return BooksScreen(selectedTab: state.activeIndex, tabs: state.tabs);
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1PageStack: NewBooksPageStack(),
        tab2PageStack: AllBooksPageStack(),
      );
}

class NewBooksPageStack extends PageStack {
  @override
  Widget build(BuildContext context) => NewBooksScreen();
}

class AllBooksPageStack extends PageStack {
  @override
  Widget build(BuildContext context) => AllBooksScreen();
}

class SettingsPageStack extends PageStack {
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
          ScaffoldPageStack((state) => state.copyWith(activeIndex: idx)),
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
            ScaffoldPageStack(
              (state) => state.copyWith(
                tab1PageStack: BooksViewPageStack((state) => state.copyWith(activeIndex: index)),
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
