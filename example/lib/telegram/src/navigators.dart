import 'package:example/telegram/src/screens.dart';
import 'package:flutter/widgets.dart';

import 'data.dart';

/// This is a list of all navigator which represent what each screen needs
/// to navigate
///
///
/// This classes are interfaces which allows the UI to be independent from the
/// routing package

// Left side
abstract class ChatsListNavigator {
  void showSettings(BuildContext context, {required ChatsListScreen chatsListScreen});

  void showChat(BuildContext context, {required Chat chat});
}

abstract class SettingsNavigator {
  void popSettings(BuildContext context);
}

// Middle side
abstract class ChatNavigator {
  void showMembersDetails(BuildContext context);

  void hideMembersDetails(BuildContext context);

  void showContactChat(BuildContext context, {required Contact contact});

  void showLeftTab(BuildContext context);

  void hideLeftTab(BuildContext context);
}

// Right side
abstract class MembersDetailsNavigator {
  void showContactChat(BuildContext context, {required Contact contact});

  void hideMembersDetails(BuildContext context);
}
