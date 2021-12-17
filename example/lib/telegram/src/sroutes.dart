import 'package:example/telegram/src/screens.dart';
import 'package:flutter/material.dart';
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
class ChatsListSRoute extends SRoute<SNested> {
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

class SettingsSRoute extends SRoute<SNested> {
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
  SRouteBase<SNested>? createSRouteBellow(BuildContext context) {
    return ChatsListSRoute(
      navigator: chatsListNavigator,
      chats: chats,
    );
  }
}

// Middle side
class StackedChatsSRoute extends SRoute<SNested> {
  final ChatNavigator navigator;
  final List<Chat> chats;

  StackedChatsSRoute({required this.navigator, required this.chats});

  @override
  Page buildPage(BuildContext context) {
    return MaterialPage(
      key: ValueKey(chats.length),
      child: build(context),
    );
  }

  void _onPop(BuildContext context) {
    context.sRouter.to(
      TabsWrapperSRoute.from(
        context,
        selectedChats: List.from(chats)..removeLast(),
      ),
    );
  }

  Widget popHandler(BuildContext context, {required Widget child}) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        _onPop(context);
        return true;
      },
      child: WillPopScope(
        onWillPop: () async {
          _onPop(context);
          return false;
        },
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = ChatScreen(
      navigator: navigator,
      chat: chats.last,
    );

    return chats.length > 1 ? popHandler(context, child: child) : child;
  }

  @override
  SRouteBase<SNested>? createSRouteBellow(BuildContext context) {
    return chats.length <= 1
        ? null
        : StackedChatsSRoute(chats: List.from(chats)..removeLast(), navigator: navigator);
  }
}

// Right side
class MembersDetailsSRoute extends SRoute<SNested> {
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
// Using the navigator src directly is ok since this is part of
// the SRouter package anyway, but a DI approach could be used
//
// The [chats] global variable is used directly but since it's a global
// dependency something like a [Provider] should be put on top on [SRouter] and
// be accessed here (or even in the screens directly)
class TabsWrapperSRoute extends S3TabsRoute<NotSNested> {
  final bool showMemberDetails;
  final bool maybeShowLeftTab;

  TabsWrapperSRoute(
    StateBuilder<S3TabsState> stateBuilder, {
    this.showMemberDetails = false,
    this.maybeShowLeftTab = false,
  }) : super(stateBuilder);

  factory TabsWrapperSRoute.from(
    BuildContext context, {
    bool? showMemberDetails,
    bool? maybeShowLeftTab,
    List<Chat>? selectedChats,
    SRouteBase<SNested>? tabLeftRoute,
  }) {
    final previousState = context.read<TabsWrapperScreenState?>();

    return TabsWrapperSRoute(
      (state) => state.copyWith(
        tab1SRoute: tabLeftRoute,
        tab2SRoute: StackedChatsSRoute(
          navigator: ChatNavigatorImplementation(),
          chats: selectedChats ?? previousState?.widget.chats ?? [chats.first],
        ),
      ),
      showMemberDetails: showMemberDetails ?? previousState?.widget.showMemberDetails ?? false,
      maybeShowLeftTab: maybeShowLeftTab ?? previousState?.widget.maybeShowLeftTab ?? false,
    );
  }

  @override
  Widget build(BuildContext context, S3TabsState state) {
    return TabsWrapperScreen(
      tabs: state.tabs,
      chats: (state.tab2SRoute as StackedChatsSRoute).chats,
      showMemberDetails: showMemberDetails,
      maybeShowLeftTab: maybeShowLeftTab,
    );
  }

  @override
  S3TabsState get initialState => S3TabsState(
        activeIndex: 1,
        tab1SRoute: ChatsListSRoute(
          navigator: ChatsListNavigatorImplementation(),
          chats: chats,
        ),
        tab2SRoute: StackedChatsSRoute(
          navigator: ChatNavigatorImplementation(),
          chats: [chats.first],
        ),
        tab3SRoute: MembersDetailsSRoute(
          navigator: MembersDetailsNavigatorImplementation(),
        ),
      );
}
