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
          Multi2TabsTranslator<MyScaffoldPageStack, NonNestedStack>(
            pageStack: MyScaffoldPageStack.new,
            tab1Translators: [
              PathTranslator<HomePageStack, NestedStack>(
                path: '/home',
                pageStack: HomePageStack(),
              ),
            ],
            tab2Translators: [
              PathTranslator<UserPageStack, NestedStack>(
                path: '/user',
                pageStack: UserPageStack(),
              ),
              PathTranslator<SettingsPageStack, NestedStack>(
                path: '/settings',
                pageStack: SettingsPageStack(),
              ),
            ],
          ),
          RedirectorTranslator(path: '*', pageStack: MyScaffoldPageStack((state) => state)),
        ],
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => SRouter.of(context).to(MyScaffoldPageStack(
            (state) => state.copyWith(
              activeIndex: 1,
              tab2PageStack: SettingsPageStack(),
            ),
          )),
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
        child: Text('Here is your home'),
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MyScaffold({
    Key? key,
    required this.child,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => SRouter.of(context).to(
          MyScaffoldPageStack(
            (state) => state.copyWith(activeIndex: index),
          ),
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}

class UserPageStack extends PageStack<NestedStack> {
  @override
  Widget build(BuildContext context) {
    return UserScreen();
  }
}

class SettingsPageStack extends PageStack<NestedStack> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }

  @override
  PageStackBase<NestedStack>? createPageStackBellow(BuildContext context) {
    return UserPageStack();
  }
}

class HomePageStack extends PageStack<NestedStack> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class MyScaffoldPageStack extends Multi2TabsPageStack<NonNestedStack> {
  MyScaffoldPageStack(StateBuilder<Multi2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) {
    return MyScaffold(child: state.tabs[state.activeIndex], currentIndex: state.activeIndex);
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1PageStack: HomePageStack(),
        tab2PageStack: UserPageStack(),
      );
}
