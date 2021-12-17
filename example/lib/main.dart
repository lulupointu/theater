import 'dart:math';

import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

void main() {
  initializeSRouter(sUrlStrategy: SUrlStrategy.history);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SRouter(
        initialPageStack: LogInPageStack(),
        translatorsBuilder: (_) => [
          PathTranslator<LogInPageStack, NonNestedStack>(path: '/', route: LogInPageStack()),
          PathTranslator<MainPageStack, NonNestedStack>.parse(
            path: '*',
            matchToRoute: (_) => MainPageStack(),
            routeToWebEntry: (_) => WebEntry(path: '/user/0'),
          ),
        ],
      ),
    );
  }
}

class LogInPageStack extends PageStack<NonNestedStack> {
  @override
  Widget build(BuildContext context) => LoginScreen();
}

class MainPageStack extends PageStack<NonNestedStack> {
  @override
  Widget build(BuildContext context) => MainScreen();

  @override
  PageStackBase<NonNestedStack> createPageStackBellow(BuildContext context) {
    return LogInPageStack();
  }
}

abstract class SRouteWithUserId {
  String get userId;
}

class UserPageStack extends PageStack<NonNestedStack> implements SRouteWithUserId {
  final String userId;

  UserPageStack({required this.userId});

  @override
  Widget build(BuildContext context) => UserScreen(userId: userId);
}

class SettingsPageStack extends PageStack<NonNestedStack> implements SRouteWithUserId {
  final String userId;

  SettingsPageStack({required this.userId});

  @override
  Widget build(BuildContext context) => SettingsScreen(userId: userId);
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.sRouter.to(MainPageStack()),
        child: Text('Click to log in'),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SRouter(
      initialPageStack: UserPageStack(userId: '0'),
      translatorsBuilder: (_) => [
        PathTranslator<UserPageStack, NonNestedStack>.parse(
          path: '/user/:id',
          matchToRoute: (match) => UserPageStack(userId: match.pathParams['id']!),
          routeToWebEntry: (route) => WebEntry(path: 'user/${route.userId}'),
        ),
        PathTranslator<SettingsPageStack, NonNestedStack>.parse(
          path: '/settings',
          matchToRoute: (match) => SettingsPageStack(userId: match.historyState['id'] ?? '0'),
          routeToWebEntry: (route) =>
              WebEntry(path: '/settings', historyState: {'id': route.userId}),
        ),
        RedirectorTranslator(path: '*', route: UserPageStack(userId: '0')),
      ],
      builder: (context, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: SRouter.of(context).currentHistoryEntry!.pageStack is UserPageStack ? 0 : 1,
            onTap: (index) {
              final userId =
                  (SRouter.of(context).currentHistoryEntry!.pageStack as SRouteWithUserId).userId;
              if (index == 0) {
                context.sRouter.to(UserPageStack(userId: userId));
              } else {
                context.sRouter.to(SettingsPageStack(userId: userId));
              }
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'user'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'settings'),
            ],
          ),
        );
      },
    );
  }
}

class UserScreen extends StatelessWidget {
  final String userId;

  UserScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User, id: $userId')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.sRouter.to(SettingsPageStack(userId: userId)),
              child: Text('Go to settings'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => SRouter.of(context, findRoot: true).to(LogInPageStack()),
              child: Text('Go back to login'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String userId;

  SettingsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.sRouter.to(UserPageStack(userId: userId)),
              child: Text('Go to user $userId'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () =>
                  context.sRouter.to(SettingsPageStack(userId: '${Random().nextInt(100)}')),
              child: Text('Change user id'),
            ),
          ],
        ),
      ),
    );
  }
}
