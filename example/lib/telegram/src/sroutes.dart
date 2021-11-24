import 'package:example/telegram/src/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/src/provider.dart';
import 'package:srouter/srouter.dart';

import 'data.dart';
import 'navigators.dart';
import 'navigators_implementations.dart';

/// Contains the definitions of each stack of pages as [SRoute]s
///
///
/// Something interesting is how clear the dependencies are, if you are on
/// [SettingsSRoute], you have a stack of [ChatsListScreen, SettingsScreen]
/// therefore your dependencies are the union of the dependencies of the
/// two screens. This really shows that an [SRoute] is a STACK
///
///
/// Note how no [SRoute] is [Pushable] except the [STabbedRoute], this is
/// because only the [STabbedRoute] can directly be pushed into [SRouter]

// Left side
class ChatsListSRoute extends SRoute<NonSPushable> {
  final ChatsListNavigator navigator;
  final List<Chat> chats;

  ChatsListSRoute({
    required this.navigator,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return ChatsListScreen(
      chats: chats,
      navigator: navigator,
    );
  }
}

class SettingsSRoute extends SRoute<NonSPushable> {
  final SettingsNavigator settingsNavigator;
  final ChatsListNavigator chatsListNavigator;
  final List<Chat> chats;

  SettingsSRoute({
    required this.settingsNavigator,
    required this.chatsListNavigator,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(navigator: settingsNavigator);
  }

  @override
  SRouteInterface<NonSPushable>? buildSRouteBellow(BuildContext context) {
    return ChatsListSRoute(
      navigator: chatsListNavigator,
      chats: chats,
    );
  }
}

// Middle side
class StackedChatsSRoute extends SRoute<NonSPushable> {
  final ChatNavigator navigator;
  final List<Chat>? selectedChats;

  StackedChatsSRoute({required this.navigator}) : selectedChats = null;

  StackedChatsSRoute._({required this.navigator, this.selectedChats});

  @override
  Page buildPage(BuildContext context, Widget child) {
    final chats = selectedChats != null
        ? selectedChats!
        : context.watch<TabsWrapperScreenState>().widget.selectedChats;
    return MaterialPage(
      key: ValueKey(chats.length),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreen(
      navigator: navigator,
      chat: selectedChats != null
          ? selectedChats!.last
          : context.read<TabsWrapperScreenState>().widget.selectedChats.last,
    );
  }

  @override
  SRouteInterface<NonSPushable>? buildSRouteBellow(BuildContext context) {
    final _selectedChats = List<Chat>.from(
      selectedChats != null
          ? selectedChats!
          : context.read<TabsWrapperScreenState>().widget.selectedChats,
    );
    return _selectedChats.length <= 1
        ? null
        : StackedChatsSRoute._(
            selectedChats: _selectedChats..removeLast(),
            navigator: navigator,
          );
  }
}

// Right side
class MembersDetailsSRoute extends SRoute<NonSPushable> {
  final MembersDetailsNavigator navigator;

  MembersDetailsSRoute({
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return MembersDetailsScreen(navigator: navigator);
  }
}

// Tabs wrapper
//
// Using the navigator implementations directly is ok since this is part of
// the SRouter package anyway, but a DI approach could be used
//
// The [chats] global variable is used directly but since it's a global
// dependency something like a [Provider] should be put on top on [SRouter] and
// be accessed here (or even in the screens directly)
class TabsWrapperSRoute extends STabbedRoute<MyTab, SPushable> {
  static final initialTabSRoutes = {
    MyTab.left: ChatsListSRoute(
      navigator: ChatsListNavigatorImplementation(),
      chats: chats,
    ),
    MyTab.middle: StackedChatsSRoute(
      navigator: ChatNavigatorImplementation(),
    ),
    MyTab.right: MembersDetailsSRoute(
      navigator: MembersDetailsNavigatorImplementation(),
    ),
  };

  final bool showMemberDetails;
  final bool maybeShowLeftTab;
  final List<Chat> selectedChats;

  TabsWrapperSRoute({
    SRouteInterface<NonSPushable>? tabLeftRoute,
    required this.showMemberDetails,
    required this.selectedChats,
    required this.maybeShowLeftTab,
  }) : super(
          sTabs: {
            MyTab.left: STab(
              initialSRoute: initialTabSRoutes[MyTab.left]!,
              currentSRoute: tabLeftRoute,
            ),
            MyTab.middle: STab(
              initialSRoute: initialTabSRoutes[MyTab.middle]!,
              currentSRoute: null, // This [SRoute] react to changes in the state
            ),
            MyTab.right: STab(
              initialSRoute: initialTabSRoutes[MyTab.right]!,
              currentSRoute: null, // This tab never switches
            ),
          },
        );

  factory TabsWrapperSRoute.from(
    BuildContext context, {
    bool? showMemberDetails,
    bool? maybeShowLeftTab,
    List<Chat>? selectedChats,
    SRouteInterface<NonSPushable>? tabLeftRoute,
  }) {
    final previousState = context.read<TabsWrapperScreenState?>();

    return TabsWrapperSRoute(
      tabLeftRoute: tabLeftRoute,
      showMemberDetails: showMemberDetails ?? previousState?.widget.showMemberDetails ?? false,
      maybeShowLeftTab: maybeShowLeftTab ?? previousState?.widget.maybeShowLeftTab ?? false,
      selectedChats: selectedChats ?? previousState?.widget.selectedChats ?? [chats.first],
    );
  }

  @override
  MyTab get activeTab => MyTab.middle;

  @override
  Widget tabsBuilder(BuildContext context, Map<MyTab, Widget> tabs) {
    return TabsWrapperScreen(
      tabs: tabs,
      selectedChats: selectedChats,
      showMemberDetails: showMemberDetails,
      maybeShowLeftTab: maybeShowLeftTab,
    );
  }

  @override
  STabbedRoute<MyTab, SPushable>? onTabPop(
    BuildContext context,
    SRouteInterface<NonSPushable> activeTabSRouteBellow,
  ) {
    final selectedChats = context.read<TabsWrapperScreenState>().widget.selectedChats;

    return TabsWrapperSRoute(
      selectedChats: selectedChats.sublist(0, selectedChats.length - 1),
      showMemberDetails: showMemberDetails,
      maybeShowLeftTab: maybeShowLeftTab,
    );
  }
}
