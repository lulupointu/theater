import 'package:example/telegram/src/navigators_implementations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'src/data.dart';
import 'src/screens.dart';
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
  initializeSRouter();

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
      home: SRouter(
        initialRoute: TabsWrapperSRoute(
          showMemberDetails: false,
          maybeShowLeftTab: false,
          selectedChats: [chats.first],
        ),
        translatorsBuilder: (_) => [
          STabbedRouteTranslator<TabsWrapperSRoute, MyTab, SPushable>.static(
            matchToRoute: (match, tabs) {
              // We should be able to return null from here

              final showMemberDetails = match.historyState['showMemberDetails'] == 'true';
              final maybeShowLeftTab = match.historyState['maybeShowLeftTab'] == 'true';

              final selectedChats = match.pathSegments
                  .map((id) => chats.firstWhere((chat) => chat.id == id))
                  .toList();

              return TabsWrapperSRoute.from(
                context,
                showMemberDetails: showMemberDetails,
                maybeShowLeftTab: maybeShowLeftTab,
                selectedChats: selectedChats,
                tabLeftRoute: tabs[MyTab.left],
              );
            },
            routeToWebEntry: (_, route, tabsWebEntry) {
              return WebEntry(
                pathSegments: route.selectedChats.map((e) => e.id).toList(),
                historyState: {
                  'showMemberDetails': '${route.showMemberDetails}',
                  'maybeShowLeftTab': '${route.maybeShowLeftTab}',
                  ...(tabsWebEntry[MyTab.left]?.historyState ?? {}),
                },
                title: 'Chat ${route.selectedChats.last.title}',
              );
            },
            tabTranslators: {
              MyTab.left: [
                SPathTranslator<ChatsListSRoute, NonSPushable>(
                  path: null,
                  validateHistoryState: (historyState) =>
                      historyState['showSettings'] != 'true',
                  matchToRoute: (match) => ChatsListSRoute(
                    navigator: ChatsListNavigatorImplementation(),
                    chats: chats,
                  ),
                  routeToWebEntry: (route) => WebEntry(),
                ),
                SPathTranslator<SettingsSRoute, NonSPushable>(
                  path: null,
                  validateHistoryState: (historyState) =>
                      historyState['showSettings'] == 'true',
                  matchToRoute: (match) => SettingsSRoute(
                    settingsNavigator: SettingsNavigatorImplementation(),
                    chatsListNavigator: ChatsListNavigatorImplementation(),
                    chats: chats,
                  ),
                  routeToWebEntry: (route) => WebEntry(historyState: {'showSettings': 'true'}),
                ),
              ],
            },
          ),
        ],
      ),
    );
  }
}
