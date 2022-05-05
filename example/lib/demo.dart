import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Theater.build(
        initialPageStack: UserPageStack(),
        translatorsBuilder: (_) => [
          PathTranslator<UserPageStack>(
            path: '/user',
            pageStack: UserPageStack(),
          ),
          PathTranslator<SettingsPageStack>(
            path: '/settings',
            pageStack: SettingsPageStack(),
          ),
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
          onPressed: () => Theater.of(context).to(SettingsPageStack()),
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

class UserPageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return UserScreen();
  }
}

class SettingsPageStack extends PageStack {
  @override
  Page buildPage(BuildContext context, PageState state, child) {
    return MaterialPage(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }

  @override
  PageStackBase? get pageStackBellow => UserPageStack();
}
