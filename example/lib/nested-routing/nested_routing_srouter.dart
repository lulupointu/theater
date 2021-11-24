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
        initialRoute: NewBooksSRoute(),
        translatorsBuilder: (_) => [
          SPathTranslator<SettingsSRoute, SPushable>.static(path: '/settings', route: SettingsSRoute()),
          SPathTranslator<NewBooksSRoute, SPushable>.static(path: '/books/new', route: NewBooksSRoute()),
          SPathTranslator<AllBooksSRoute, SPushable>.static(path: '/books/all', route: AllBooksSRoute()),
          SRedirectorTranslator.static(from: '*', to: NewBooksSRoute()),
        ],
        builder: (context, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex:
                  SRouter.of(context).currentHistoryEntry!.route is SettingsSRoute
                      ? 1
                      : 0,
              onTap: (idx) =>
                  context.sRouter.push(idx == 0 ? NewBooksSRoute() : SettingsSRoute()),
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
        },
      ),
    );
  }
}

class NewBooksSRoute extends SRoute<SPushable> {
  @override
  Page buildPage(BuildContext context, Widget child) =>
      FadeTransitionPage(key: ValueKey('BooksScreen'), child: child);

  @override
  Widget build(BuildContext context) => BooksScreen(selectedTab: 0);
}

class AllBooksSRoute extends SRoute<SPushable> {
  @override
  Page buildPage(BuildContext context, Widget child) =>
      FadeTransitionPage(key: ValueKey('BooksScreen'), child: child);

  @override
  Widget build(BuildContext context) => BooksScreen(selectedTab: 1);
}

class SettingsSRoute extends SRoute<SPushable> {
  @override
  Page buildPage(BuildContext context, Widget child) => FadeTransitionPage(child: child);

  @override
  Widget build(BuildContext context) => SettingsScreen();
}

class BooksScreen extends StatefulWidget {
  final int selectedTab;

  BooksScreen({
    Key? key,
    required this.selectedTab,
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
          onTap: (value) => context.sRouter.push(
            value == 0 ? NewBooksSRoute() : AllBooksSRoute(),
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
            children: [
              NewBooksScreen(),
              AllBooksScreen(),
            ],
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

class FadeTransitionPage extends Page {
  final Widget child;

  FadeTransitionPage({LocalKey? key, required this.child}) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageBasedFadeTransitionRoute(this);
  }
}

class PageBasedFadeTransitionRoute extends PageRoute {
  PageBasedFadeTransitionRoute(Page page)
      : super(
          settings: page,
        );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var curveTween = CurveTween(curve: Curves.easeIn);
    return FadeTransition(
      opacity: animation.drive(curveTween),
      child: (settings as FadeTransitionPage).child,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
