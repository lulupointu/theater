import 'dart:math';

import 'package:faker/faker.dart';

/// We create the [chats] which are:
///   - One to one chat with a single [Contact]
///   - Group chat with multiple [Contact]
///
/// Each [Chat] contain [Message]s

class Contact {
  final String id;
  final String fullName;

  Contact({required this.id, required this.fullName});
}

class Message {
  final Contact contact;
  final String content;
  final DateTime date;

  Message({required this.contact, required this.content, required this.date});
}

class Chat {
  final String id;
  final String title;
  final List<Contact> members;
  final List<Message> messages;

  Chat({required this.id, required this.title, required this.members, required this.messages});
}

final randomSeed = 123456;
final _random = Random(randomSeed);

final _faker = Faker.withGenerator(RandomGenerator(seed: randomSeed));

final numberOfContacts = 30;
final contacts = [
  for (int i = 0; i < numberOfContacts; i++)
    Contact(id: '${_faker.guid}', fullName: '${_faker.person.name()}'),
];

final maxMessagesCount = 100;
final numberOfGroupChats = 20;
final chats = [
  // Create a chat with each contact
  ...contacts.map(
    (contact) => _createChat(maxMessagesCount: maxMessagesCount, members: [contact]),
  ),

  // Create "group" chats
  for (int i = 0; i < numberOfGroupChats / 2; i++)
    _createChat(
      maxMessagesCount: maxMessagesCount,
      members: contacts.toList()
        ..shuffle()
        ..removeRange(0, _random.nextInt(contacts.length)),
    ),
]..shuffle();

Chat _createChat({
  required int maxMessagesCount,
  required List<Contact> members,
}) {
  return Chat(
    id: _faker.guid.guid(),
    title: members.length == 1
        ? members.first.fullName
        : '${_faker.lorem.word().capitalize} ${_faker.lorem.word().capitalize}',
    members: members,
    messages: [
      for (int i = 0; i < _random.nextInt(maxMessagesCount - 1) + 1; i++)
        Message(
          contact: members[_random.nextInt(members.length)],
          content: _faker.lorem.sentence(),
          date: _getRandomDate(
            startDate: DateTime.now().subtract(Duration(days: 5)),
            endDate: DateTime.now(),
          ),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date)),
  );
}

extension StringCapitalizer on String {
  String get capitalize => this[0].toUpperCase() + this.substring(1).toLowerCase();
}

DateTime _getRandomDate({required DateTime startDate, required DateTime endDate}) {
  final timeSpan = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;
  final randomSpan = (_random.nextDouble() * timeSpan).toInt();
  return startDate.add(Duration(milliseconds: randomSpan));
}
