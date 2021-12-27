import 'package:example/telegram/src/navigators_implementations.dart';
import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

import 'src/data.dart';
import 'src/sroutes.dart';

/// This is a partial fake implementation of the telegram app
///
///
/// What is interesting is that there are 3 panels dancing together.
/// They are not tabs in the sense that only one is visible at a time, but they
/// are tabs in the sense that they each have their own stack
///
///
/// This app is optimized for big screen (i.e. desktop screens) only

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.deepPurpleAccent,
          primaryVariant: Colors.deepPurple,
          secondary: Colors.deepOrangeAccent,
          secondaryVariant: Colors.deepOrange,
          surface: Colors.black38,
          background: Colors.black87,
          error: Colors.redAccent,
          onPrimary: Colors.white.withOpacity(0.9),
          onSecondary: Colors.white.withOpacity(0.9),
          onSurface: Colors.white.withOpacity(0.9),
          onBackground: Colors.white.withOpacity(0.9),
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(subtitle1: TextStyle(color: Colors.white.withOpacity(0.9))),
        scaffoldBackgroundColor: Colors.black87,
      ),
      builder: SRouter.build(
        initialPageStack: TabsWrapperPageStack((state) => state),
        translatorsBuilder: (_) => [
          Multi3TabsTranslator<TabsWrapperPageStack, NonNestedStack>(
            pageStack: TabsWrapperPageStack.new,
            tab1Translators: [],
            tab2Translators: [
              PathTranslator<ChatsListPageStack, NestedStack>.parse(
                path: '*',
                matchToPageStack: (match) => ChatsListPageStack(
                  navigator: ChatsListNavigatorImplementation(),
                  chats: match.pathSegments
                      .map((id) => chats.firstWhere((chat) => chat.id == id))
                      .toList(),
                ),
                pageStackToWebEntry: (route) => WebEntry(
                  pathSegments: route.chats.map((e) => e.id).toList(),
                  title: 'Chat ${route.chats.last.title}',
                ),
              ),
            ],
            tab3Translators: [],
          ),
        ],
      ),
    );
  }
}
