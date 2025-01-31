import 'dart:math';

import 'package:provider/provider.dart';

import 'data.dart';
import 'navigators.dart';
import 'package:flutter/material.dart';

/// This is where we butcher Telegram UI
///
///
/// The most important part of the UI are divided between the left, middle or
/// right side:
///   - Left side: The list of all chat OR the settings
///   - Middle side: The list of messages of a chat OR "no chat selected" screen
///   - Right side: Nothing OR Profile info
///
/// Missing part which can be interesting to model:
///   - The right side can have a tab view when in a group chat
///   - Clicking on some elements can bring a full-screen screen which covers
///   ^ all the others
///
///
/// An important consideration is that nothing here should depend on the
/// routing package. This are only UI elements

// Left side
class ChatsListScreen extends StatelessWidget {
  final ChatsListNavigator navigator;
  final List<Chat> chats;

  const ChatsListScreen({
    Key? key,
    required this.chats,
    required this.navigator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open chats'),
        actions: [
          IconButton(
            onPressed: () => navigator.showSettings(context, chatsListScreen: this),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final isSelected = chats[index] ==
              context.watch<TabsWrapperScreenState>().selectedChat;

          return ColoredBox(
            color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
            child: ListTile(
              onTap: () => navigator.showChat(context, chat: chats[index]),
              title: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: chats[index].members.length > 1 ? '[Group] ' : '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: chats[index].title),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final SettingsNavigator navigator;

  const SettingsScreen({Key? key, required this.navigator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => navigator.popSettings(context),
        ),
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Nothing there', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// Middle side
class ChatScreen extends StatelessWidget {
  final ChatNavigator navigator;
  final Chat chat;

  const ChatScreen({
    Key? key,
    required this.navigator,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mustShowLeftTab = context.read<TabsWrapperScreenState>().mustShowLeftTab;
    final maybeShowLeftTab = context.read<TabsWrapperScreenState>().widget.maybeShowLeftTab;

    return Scaffold(
      appBar: AppBar(
        leading: mustShowLeftTab
            ? null
            : AnimatedRotation(
                duration: Duration(milliseconds: 300),
                turns: maybeShowLeftTab ? 1 / 2 : 0,
                child: BackButton(
                  onPressed: () => maybeShowLeftTab
                      ? navigator.hideLeftTab(context)
                      : navigator.showLeftTab(context),
                ),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chatAvatarIcon(context, chat: chat),
            SizedBox(width: 10),
            Text(chat.title),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: min(800, MediaQuery.of(context).size.width),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: chat.messages.length,
            reverse: true,
            separatorBuilder: (_, __) => Container(
              height: 1,
              width: double.infinity,
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              margin: EdgeInsets.symmetric(horizontal: 20),
            ),
            itemBuilder: (_, index) {
              final message = chat.messages[index];
              return ListTile(
                leading: _memberAvatarIcon(context, contact: message.contact),
                title: Text(message.contact.fullName),
                subtitle: Text(message.content),
                trailing: Text('${DateTime.now().difference(message.date).inHours}h'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chatAvatarIcon(BuildContext context, {required Chat chat}) {
    return InkWell(
      onTap: () => context.read<TabsWrapperScreenState>().widget.showMemberDetails
          ? navigator.hideMembersDetails(context)
          : navigator.showMembersDetails(context),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurpleAccent),
        padding: const EdgeInsets.all(8.0),
        child: Text(chat.title.substring(0, 2).capitalize),
      ),
    );
  }

  Widget _memberAvatarIcon(BuildContext context, {required Contact contact}) {
    return InkWell(
      onTap: () => navigator.showContactChat(context, contact: contact),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurpleAccent),
        padding: const EdgeInsets.all(8.0),
        child: Text(contact.fullName.substring(0, 2).capitalize),
      ),
    );
  }
}

// Right side
class MembersDetailsScreen extends StatelessWidget {
  final MembersDetailsNavigator navigator;

  const MembersDetailsScreen({
    Key? key,
    required this.navigator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<TabsWrapperScreenState>().selectedChat;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => navigator.hideMembersDetails(context)),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 20),
          _avatarIcon(context, chat: chat),
          SizedBox(height: 50),
          Flexible(flex: 6, child: _membersAvatars(context, chat: chat)),
        ],
      ),
    );
  }

  Widget _avatarIcon(BuildContext context, {required Chat chat}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent,
            ),
            padding: const EdgeInsets.all(40.0),
            child: Text(chat.title.substring(0, 2).capitalize),
          ),
          SizedBox(height: 20),
          Text(chat.title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('${chat.members.length} members'),
        ],
      ),
    );
  }

  Widget _membersAvatars(BuildContext context, {required Chat chat}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('Members', style: TextStyle(fontSize: 20)),
        Expanded(
          child: ListView.builder(
            itemCount: chat.members.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final contact = chat.members[index];
              return ListTile(
                onTap: () => navigator.showContactChat(
                  context,
                  contact: contact,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurpleAccent,
                  ),
                  child: Text(contact.fullName.substring(0, 2).capitalize),
                ),
                title: Text(contact.fullName),
              );
            },
          ),
        )
      ],
    );
  }
}

// The tabs wrapper which show the left, middle and right tab
class TabsWrapperScreen extends StatefulWidget {
  final List<Widget> tabs;
  final List<Chat> chats;
  final bool showMemberDetails;
  final bool maybeShowLeftTab;

  const TabsWrapperScreen({
    Key? key,
    required this.tabs,
    required this.chats,
    required this.showMemberDetails,
    required this.maybeShowLeftTab,
  }) : super(key: key);

  @override
  State<TabsWrapperScreen> createState() => TabsWrapperScreenState();
}

class TabsWrapperScreenState extends State<TabsWrapperScreen> {
  Chat get selectedChat => widget.chats.last;

  bool get mustShowLeftTab => MediaQuery.of(context).size.width > 1000;

  bool get showLeftTab => mustShowLeftTab ? true : widget.maybeShowLeftTab;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Row(
        children: [
          ClipRRect(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              tween: Tween(begin: 1, end: showLeftTab ? 1 : 0),
              builder: (_, animation, child) => Align(
                alignment: AlignmentDirectional(-1, -1.0),
                widthFactor: animation,
                child: child,
              ),
              child: SizedBox(
                width: 250,
                child: widget.tabs[0],
              ),
            ),
          ),
          Flexible(child: widget.tabs[1]),
          ClipRRect(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              tween: Tween(begin: 0, end: widget.showMemberDetails ? 1 : 0),
              builder: (_, animation, child) => Align(
                alignment: AlignmentDirectional(-1, -1.0),
                widthFactor: animation,
                child: child,
              ),
              child: SizedBox(
                width: 250,
                child: widget.tabs[2],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
