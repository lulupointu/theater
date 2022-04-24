import 'package:example/telegram/src/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:srouter/srouter.dart';

import 'data.dart';
import 'navigators.dart';
import 'navigators_implementations.dart';

/// Contains the definitions of each stack of page_transitions as [PageStack]s
///
///
/// Something interesting is how clear the dependencies are, if you are on
/// [SettingsSRoute], you have a stack of [ChatsListScreen, SettingsScreen]
/// therefore your dependencies are the union of the dependencies of the
/// two screens. This really shows that an [PageStack] is a STACK
///
///
/// Note how no [PageStack] is [Pushable] except the [STabbedRoute], this is
/// because only the [STabbedRoute] can directly be pushed into [SRouter]

// Left side
class ChatsListPageStack extends PageStack with Tab1In<TabsWrapperPageStack> {
  final ChatsListNavigator navigator;
  final List<Chat> chats;

  ChatsListPageStack({
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

class SettingsPageStack extends PageStack with Tab1In<TabsWrapperPageStack> {
  final SettingsNavigator settingsNavigator;
  final ChatsListNavigator chatsListNavigator;
  final List<Chat> chats;

  SettingsPageStack({
    required this.settingsNavigator,
    required this.chatsListNavigator,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(navigator: settingsNavigator);
  }

  @override
  Tab1In<TabsWrapperPageStack>? get pageStackBellow {
    return ChatsListPageStack(
      navigator: chatsListNavigator,
      chats: chats,
    );
  }
}

// Middle side
class StackedChatsPageStack extends PageStack with Tab2In<TabsWrapperPageStack> {
  final ChatNavigator navigator;
  final List<Chat> chats;

  StackedChatsPageStack({required this.navigator, required this.chats});

  @override
  Page buildPage(BuildContext context) {
    return MaterialPage(
      key: ValueKey(chats.length),
      child: build(context),
    );
  }

  void _onPop(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(
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
  Tab2In<TabsWrapperPageStack>? get pageStackBellow {
    return chats.length <= 1
        ? null
        : StackedChatsPageStack(chats: List.from(chats)..removeLast(), navigator: navigator);
  }
}

// Right side
class MembersDetailsPageStack extends PageStack with Tab3In<TabsWrapperPageStack> {
  final MembersDetailsNavigator navigator;

  MembersDetailsPageStack({required this.navigator});

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
class TabsWrapperPageStack extends Multi3TabsPageStack {
  final bool showMemberDetails;
  final bool maybeShowLeftTab;

  TabsWrapperPageStack(
    StateBuilder<Multi3TabsState> stateBuilder, {
    this.showMemberDetails = false,
    this.maybeShowLeftTab = false,
  }) : super(stateBuilder);

  factory TabsWrapperPageStack.from(
    BuildContext context, {
    bool? showMemberDetails,
    bool? maybeShowLeftTab,
    List<Chat>? selectedChats,
    Tab1In<Multi3TabsPageStack>? tabLeftRoute,
  }) {
    final previousState = context.read<TabsWrapperScreenState?>();

    return TabsWrapperPageStack(
      (state) => state.copyWith(
        tab1PageStack: tabLeftRoute,
        tab2PageStack: StackedChatsPageStack(
          navigator: ChatNavigatorImplementation(),
          chats: selectedChats ?? previousState?.widget.chats ?? [chats.first],
        ),
      ),
      showMemberDetails: showMemberDetails ?? previousState?.widget.showMemberDetails ?? false,
      maybeShowLeftTab: maybeShowLeftTab ?? previousState?.widget.maybeShowLeftTab ?? false,
    );
  }

  @override
  Widget build(BuildContext context, Multi3TabsState state) {
    return TabsWrapperScreen(
      tabs: state.tabs,
      chats: (state.tab2PageStack as StackedChatsPageStack).chats,
      showMemberDetails: showMemberDetails,
      maybeShowLeftTab: maybeShowLeftTab,
    );
  }

  @override
  Multi3TabsState get initialState => Multi3TabsState(
        activeIndex: 1,
        tab1PageStack: ChatsListPageStack(
          navigator: ChatsListNavigatorImplementation(),
          chats: chats,
        ),
        tab2PageStack: StackedChatsPageStack(
          navigator: ChatNavigatorImplementation(),
          chats: [chats.first],
        ),
        tab3PageStack: MembersDetailsPageStack(
          navigator: MembersDetailsNavigatorImplementation(),
        ),
      );
}
