import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: SRouter.build(
        initialPageStack: MyScaffoldPageStack((state) => state),
        translatorsBuilder: (_) => [
          PathTranslator<FeaturePageStack>(
            path: '/feature',
            pageStack: FeaturePageStack(),
          ),
          Multi2TabsTranslator<MyScaffoldPageStack>(
            pageStack: MyScaffoldPageStack.new,
            tab1Translators: [
              PathTranslator<HomePageStack>(
                path: '/home',
                pageStack: HomePageStack(),
              ),
            ],
            tab2Translators: [
              PathTranslator<ProfilePageStack>(
                path: '/profile',
                pageStack: ProfilePageStack(),
              ),
              PathTranslator<SettingsPageStack>(
                path: '/settings',
                pageStack: SettingsPageStack(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => SRouter.of(context).to(
            MyScaffoldPageStack(
              (state) => state.copyWith(tab2PageStack: SettingsPageStack()),
            ),
          ),
          child: Text('Go to settings'),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Text('Here are your settings'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Center(
          child: ElevatedButton(
            onPressed: () => SRouter.of(context).to(FeaturePageStack()),
            child: Text('Go to feature'),
          ),
        ),
      ),
    );
  }
}

class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature')),
      body: Center(
        child: Text('Here is your Feature'),
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final List<Widget> children;
  final int currentIndex;

  const MyScaffold({
    Key? key,
    required this.children,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => SRouter.of(context).to(
          MyScaffoldPageStack((state) => state.copyWith(activeIndex: index)),
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MyScaffoldPageStack extends Multi2TabsPageStack {
  MyScaffoldPageStack(StateBuilder<Multi2TabsState> stateBuilder)
      : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) {
    return MyScaffold(children: state.tabs, currentIndex: state.activeIndex);
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1PageStack: HomePageStack(),
        tab2PageStack: ProfilePageStack(),
      );
}

class HomePageStack extends PageStack with Tab1In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class ProfilePageStack extends PageStack with Tab2In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}

class SettingsPageStack extends PageStack with Tab2In<MyScaffoldPageStack> {

  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }

  @override
  Tab2In<MyScaffoldPageStack>? get pageStackBellow => ProfilePageStack();
}

class FeaturePageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return FeatureScreen();
  }

  @override
  PageStackBase? get pageStackBellow => MyScaffoldPageStack((state) => state);
}
