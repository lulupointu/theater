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
          RedirectorTranslator(path: '*', pageStack: UserPageStack()),
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
          onPressed: () => SRouter.of(context).to(SettingsPageStack()),
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
  Widget build(BuildContext context) {
    return SettingsScreen();
  }

  @override
  PageStackBase? createPageStackBellow(BuildContext context) {
    return UserPageStack();
  }
}
