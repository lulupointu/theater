import 'package:example/telegram/src/data.dart';
import 'package:example/telegram/src/screens.dart';
import 'package:example/telegram/src/sroutes.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/src/provider.dart';
import 'package:srouter/srouter.dart';

import 'navigators.dart';

/// This are concrete implementation of the navigator interfaces introduced
/// in the [navigators.dart] file
///
///
/// It uses [SRouter] to push the new page stacks defined in [sroutes.dart]

// Left side
class ChatsListNavigatorImplementation implements ChatsListNavigator {
  void showSettings(BuildContext context, {required ChatsListScreen chatsListScreen}) {
    context.sRouter.replace(
      TabsWrapperSRoute.from(
        context,
        tabLeftRoute: SettingsSRoute(
          settingsNavigator: SettingsNavigatorImplementation(),
          chatsListNavigator: chatsListScreen.navigator,
          chats: chatsListScreen.chats,
        ),
      ),
    );
  }

  void showChat(BuildContext context, {required Chat chat}) {
    context.sRouter.push(TabsWrapperSRoute.from(context, selectedChats: [chat]));
  }
}

class SettingsNavigatorImplementation implements SettingsNavigator {
  @override
  void popSettings(BuildContext context) {
    context.sRouter.replace(
      TabsWrapperSRoute.from(
        context,
        tabLeftRoute: TabsWrapperSRoute.initialTabSRoutes[MyTab.left],
      ),
    );
  }
}

// Middle side
class ChatNavigatorImplementation implements ChatNavigator {
  void showMembersDetails(BuildContext context) {
    context.sRouter.replace(TabsWrapperSRoute.from(context, showMemberDetails: true));
  }

  void hideMembersDetails(BuildContext context) {
    context.sRouter.replace(TabsWrapperSRoute.from(context, showMemberDetails: false));
  }

  void showContactChat(
    BuildContext context, {
    required Contact contact,
  }) {
    var selectedChats = context.read<TabsWrapperScreenState>().widget.selectedChats;
    final newChat = chats.firstWhere(
      (element) => element.members.length == 1 && element.members.first == contact,
    );

    // Don't change anything if we push the same chat
    selectedChats = selectedChats + (selectedChats.last == newChat ? [] : [newChat]);

    context.sRouter.push(TabsWrapperSRoute.from(context, selectedChats: selectedChats));
  }

  @override
  void showLeftTab(BuildContext context) {
    context.sRouter.replace(TabsWrapperSRoute.from(context, maybeShowLeftTab: true));
  }

  @override
  void hideLeftTab(BuildContext context) {
    context.sRouter.replace(TabsWrapperSRoute.from(context, maybeShowLeftTab: false));
  }
}

// Right side
class MembersDetailsNavigatorImplementation implements MembersDetailsNavigator {
  void showContactChat(
    BuildContext context, {
    required Contact contact,
  }) {
    var selectedChats = context.read<TabsWrapperScreenState>().widget.selectedChats;
    final newChat = chats.firstWhere(
      (element) => element.members.length == 1 && element.members.first == contact,
    );

    // Don't change anything if we push the same chat
    selectedChats = selectedChats + (selectedChats.last == newChat ? [] : [newChat]);

    context.sRouter.push(TabsWrapperSRoute.from(context, selectedChats: selectedChats));
  }

  @override
  void hideMembersDetails(BuildContext context) {
    context.sRouter.replace(TabsWrapperSRoute.from(context, showMemberDetails: false));
  }
}
