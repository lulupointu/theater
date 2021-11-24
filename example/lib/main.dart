import 'dart:math';

import 'package:flutter/material.dart';
import 'package:srouter/src/route/s_route_interface.dart';
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
          SPathTranslator<LogInSRoute, SPushable>.static(path: '/', route: LogInSRoute()),
          SPathTranslator<MainSRoute, SPushable>(
            path: '*',
            matchToRoute: (_) => MainSRoute(),
            routeToWebEntry: (_) => WebEntry(path: '/user/0'),
          ),
        ],
      ),
    );
  }
}

class LogInSRoute extends SRoute<SPushable> {
  @override
  Widget build(BuildContext context) => LoginScreen();
}

class MainSRoute extends SRoute<SPushable> {
  @override
  Widget build(BuildContext context) => MainScreen();

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) {
    return LogInSRoute();
  }
}

abstract class SRouteWithUserId {
  String get userId;
}

class UserSRoute extends SRoute<SPushable> implements SRouteWithUserId {
  final String userId;

  UserSRoute({required this.userId});

  @override
  Widget build(BuildContext context) => UserScreen(userId: userId);
}

class SettingsSRoute extends SRoute<SPushable> implements SRouteWithUserId {
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
        onPressed: () => context.sRouter.push(MainSRoute()),
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
        SPathTranslator<UserSRoute, SPushable>(
          path: '/user/:id',
          matchToRoute: (match) => UserSRoute(userId: match.pathParams['id']!),
          routeToWebEntry: (route) => WebEntry(path: 'user/${route.userId}'),
        ),
        SPathTranslator<SettingsSRoute, SPushable>(
          path: '/settings',
          matchToRoute: (match) => SettingsSRoute(userId: match.historyState['id'] ?? '0'),
          routeToWebEntry: (route) =>
              WebEntry(path: '/settings', historyState: {'id': route.userId}),
        ),
        SRedirectorTranslator.static(from: '*', to: UserSRoute(userId: '0')),
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
                context.sRouter.push(UserSRoute(userId: userId));
              } else {
                context.sRouter.push(SettingsSRoute(userId: userId));
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
              onPressed: () => context.sRouter.push(SettingsSRoute(userId: userId)),
              child: Text('Go to settings'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => SRouter.of(context, findRoot: true).push(LogInSRoute()),
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
              onPressed: () => context.sRouter.push(UserSRoute(userId: userId)),
              child: Text('Go to user $userId'),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () =>
                  context.sRouter.push(SettingsSRoute(userId: '${Random().nextInt(100)}')),
              child: Text('Change user id'),
            ),
          ],
        ),
      ),
    );
  }
}
