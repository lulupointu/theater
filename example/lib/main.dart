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
        initialRoute: LogInSRoute(),
        translatorsBuilder: (_) => [
          SPathTranslator<LogInSRoute, NotSNested>(path: '/', route: LogInSRoute()),
          SPathTranslator<MainSRoute, NotSNested>.parse(
            path: '*',
            matchToRoute: (_) => MainSRoute(),
            routeToWebEntry: (_) => WebEntry(path: '/user/0'),
          ),
        ],
      ),
    );
  }
}

class LogInSRoute extends SRoute<NotSNested> {
  @override
  Widget build(BuildContext context) => LoginScreen();
}

class MainSRoute extends SRoute<NotSNested> {
  @override
  Widget build(BuildContext context) => MainScreen();

  @override
  SRouteBase<NotSNested> createSRouteBellow(BuildContext context) {
    return LogInSRoute();
  }
}

abstract class SRouteWithUserId {
  String get userId;
}

class UserSRoute extends SRoute<NotSNested> implements SRouteWithUserId {
  final String userId;

  UserSRoute({required this.userId});

  @override
  Widget build(BuildContext context) => UserScreen(userId: userId);
}

class SettingsSRoute extends SRoute<NotSNested> implements SRouteWithUserId {
  final String userId;

  SettingsSRoute({required this.userId});

  @override
  Widget build(BuildContext context) => SettingsScreen(userId: userId);
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.sRouter.to(MainSRoute()),
        child: Text('Click to log in'),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SRouter(
      initialRoute: UserSRoute(userId: '0'),
      translatorsBuilder: (_) => [
        SPathTranslator<UserSRoute, NotSNested>.parse(
          path: '/user/:id',
          matchToRoute: (match) => UserSRoute(userId: match.pathParams['id']!),
          routeToWebEntry: (route) => WebEntry(path: 'user/${route.userId}'),
        ),
        SPathTranslator<SettingsSRoute, NotSNested>.parse(
          path: '/settings',
          matchToRoute: (match) => SettingsSRoute(userId: match.historyState['id'] ?? '0'),
          routeToWebEntry: (route) =>
              WebEntry(path: '/settings', historyState: {'id': route.userId}),
        ),
        SRedirectorTranslator(path: '*', route: UserSRoute(userId: '0')),
      ],
      builder: (context, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: SRouter.of(context).currentHistoryEntry!.route is UserSRoute ? 0 : 1,
            onTap: (index) {
              final userId =
                  (SRouter.of(context).currentHistoryEntry!.route as SRouteWithUserId).userId;
              if (index == 0) {
                context.sRouter.to(UserSRoute(userId: userId));
              } else {
                context.sRouter.to(SettingsSRoute(userId: userId));
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
              onPressed: () => context.sRouter.to(SettingsSRoute(userId: userId)),
              child: Text('Go to settings'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => SRouter.of(context, findRoot: true).to(LogInSRoute()),
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
              onPressed: () => context.sRouter.to(UserSRoute(userId: userId)),
              child: Text('Go to user $userId'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () =>
                  context.sRouter.to(SettingsSRoute(userId: '${Random().nextInt(100)}')),
              child: Text('Change user id'),
            ),
          ],
        ),
      ),
    );
  }
}
