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
    context.sRouter.to(
      TabsWrapperPageStack.from(
        context,
        tabLeftRoute: SettingsPageStack(
          settingsNavigator: SettingsNavigatorImplementation(),
          chatsListNavigator: chatsListScreen.navigator,
          chats: chatsListScreen.chats,
        ),
      ),
      isReplacement: true,
    );
  }

  void showChat(BuildContext context, {required Chat chat}) {
    context.sRouter.to(TabsWrapperPageStack.from(context, selectedChats: [chat]));
  }
}

class SettingsNavigatorImplementation implements SettingsNavigator {
  @override
  void popSettings(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(
        context,
        tabLeftRoute: ChatsListPageStack(
          navigator: ChatsListNavigatorImplementation(),
          chats: chats,
        ),
      ),
      isReplacement: true,
    );
  }
}

// Middle side
class ChatNavigatorImplementation implements ChatNavigator {
  void showMembersDetails(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(context, showMemberDetails: true),
      isReplacement: true,
    );
  }

  void hideMembersDetails(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(context, showMemberDetails: false),
      isReplacement: true,
    );
  }

  void showContactChat(
    BuildContext context, {
    required Contact contact,
  }) {
    var selectedChats = context.read<TabsWrapperScreenState>().widget.chats;
    final newChat = chats.firstWhere(
      (element) => element.members.length == 1 && element.members.first == contact,
    );

    // Don't change anything if we push the same chat
    selectedChats = selectedChats + (selectedChats.last == newChat ? [] : [newChat]);

    context.sRouter.to(TabsWrapperPageStack.from(context, selectedChats: selectedChats));
  }

  @override
  void showLeftTab(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(context, maybeShowLeftTab: true),
      isReplacement: true,
    );
  }

  @override
  void hideLeftTab(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(context, maybeShowLeftTab: false),
      isReplacement: true,
    );
  }
}

// Right side
class MembersDetailsNavigatorImplementation implements MembersDetailsNavigator {
  void showContactChat(
    BuildContext context, {
    required Contact contact,
  }) {
    var selectedChats = context.read<TabsWrapperScreenState>().widget.chats;
    final newChat = chats.firstWhere(
      (element) => element.members.length == 1 && element.members.first == contact,
    );

    // Don't change anything if we push the same chat
    selectedChats = selectedChats + (selectedChats.last == newChat ? [] : [newChat]);

    context.sRouter.to(TabsWrapperPageStack.from(context, selectedChats: selectedChats));
  }

  @override
  void hideMembersDetails(BuildContext context) {
    context.sRouter.to(
      TabsWrapperPageStack.from(context, showMemberDetails: false),
      isReplacement: true,
    );
  }
}
