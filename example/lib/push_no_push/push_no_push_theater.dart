import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  runApp(PushNoPush());
}

class PushNoPush extends StatelessWidget {
  const PushNoPush({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Theater.build(
        initialPageStack: ProfilesPageStack(profiles: [Faker().person.name()]),
        translatorsBuilder: (_) => [
          PathTranslator<ProfilesPageStack>.parse(
            path: '*',
            matchToPageStack: (match) => ProfilesPageStack(profiles: match.pathSegments),
            pageStackToWebEntry: (pageStack) => WebEntry(pathSegments: pageStack.profiles),
          ),
        ],
      ),
    );
  }
}

class ProfilesPageStack extends PageStack {
  final List<String> profiles;

  ProfilesPageStack({required this.profiles}) : super(key: ValueKey(profiles.length));

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(name: profiles.last, profiles: profiles);
  }

  @override
  PageStackBase? get pageStackBellow {
    if (profiles.length == 1) {
      return null;
    }
    return ProfilesPageStack(profiles: profiles.sublist(0, profiles.length - 1));
  }
}

class ProfileScreen extends StatelessWidget {
  final String name;
  final List<String> profiles;

  const ProfileScreen({Key? key, required this.name, required this.profiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$name profile')),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (_) => RandomProfileLink(profiles: profiles)),
      ),
    );
  }
}

class RandomProfileLink extends StatefulWidget {
  final List<String> profiles;

  const RandomProfileLink({Key? key, required this.profiles}) : super(key: key);

  @override
  State<RandomProfileLink> createState() => _RandomProfileLinkState();
}

class _RandomProfileLinkState extends State<RandomProfileLink> {
  final String randomName = Faker().person.name();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () => Theater.of(context).to(
          ProfilesPageStack(profiles: widget.profiles + [randomName]),
        ),
        child: Text('See $randomName profile'),
      ),
    );
  }
}
