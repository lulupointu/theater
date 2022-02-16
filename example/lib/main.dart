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
        initialPageStack: LogInPageStack(),
        sUrlStrategy: SUrlStrategy.history,
        translatorsBuilder: (_) => [
          PathTranslator<LogInPageStack>(path: '/', pageStack: LogInPageStack()),
          Multi2TabsTranslator<MainPageStack>(
            pageStack: MainPageStack.new,
            tab1Translators: [
              PathTranslator<UserPageStack>(path: '/user', pageStack: UserPageStack()),
            ],
            tab2Translators: [
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

class LogInPageStack extends PageStack {
  @override
  Widget build(BuildContext context) => LoginScreen();
}

class MainPageStack extends Multi2TabsPageStack {
  MainPageStack(StateBuilder<Multi2TabsState> stateBuilder) : super(stateBuilder);

  @override
  Widget build(BuildContext context, Multi2TabsState state) =>
      MainScreen(currentIndex: state.activeIndex, child: state.tabs[state.activeIndex]);

  @override
  PageStackBase get pageStackBellow {
    return LogInPageStack();
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        activeIndex: 0,
        tab1PageStack: UserPageStack(),
        tab2PageStack: SettingsPageStack(),
      );
}

class UserPageStack extends PageStack with Tab1In<MainPageStack> {
  @override
  Widget build(BuildContext context) => UserScreen();
}

class SettingsPageStack extends PageStack with Tab2In<MainPageStack> {
  @override
  Widget build(BuildContext context) => SettingsScreen();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.sRouter.to(MainPageStack((state) => state)),
        child: Text('Click to log in'),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScreen({
    Key? key,
    required this.currentIndex,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            context.sRouter.to(
              MainPageStack((state) => state.copyWith(activeIndex: 0)),
            );
          } else {
            context.sRouter.to(
              MainPageStack((state) => state.copyWith(activeIndex: 1)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'user'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'settings'),
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
          onPressed: () => context.sRouter.to(
            MainPageStack((state) => state.copyWith(activeIndex: 1)),
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
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.sRouter.to(
            MainPageStack((state) => state.copyWith(activeIndex: 0)),
          ),
          child: Text('Go to user'),
        ),
      ),
    );
  }
}
