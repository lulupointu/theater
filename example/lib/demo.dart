import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  Theater.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsersScreen(),
    );
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.age,
  });

  final String id;
  final String name;
  final String age;
}

final users = [
  User(id: '1', name: 'John', age: '30'),
  User(id: '2', name: 'Mary', age: '25'),
  User(id: '3', name: 'Peter', age: '35'),
  User(id: '4', name: 'Sara', age: '22'),
  User(id: '5', name: 'Mike', age: '27'),
  User(id: '6', name: 'Jane', age: '32'),
];

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Text(
            'All users:',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          Expanded(
            child: UsersList(
              users: users,
              onUserTapped: toUser,
            ),
          ),
        ],
      ),
    );
  }

  void toUser(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => Navigator.popUntil(
              context,
              (route) => route.isFirst,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: child,
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  UserDetailsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  late final List<User> friends = users.where((u) => u.id != user.id).toList();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User:',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          Text('Name: ${user.name}'),
          SizedBox(height: 8),
          Text('Age:    ${user.age}'),
          SizedBox(height: 32),
          Center(
            child: Text(
              'User\'s friends:',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: UsersList(
              users: friends,
              onUserTapped: toUser,
            ),
          ),
        ],
      ),
    );
  }

  void toUser(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }
}

class UsersList extends StatelessWidget {
  const UsersList({
    Key? key,
    required this.users,
    required this.onUserTapped,
  }) : super(key: key);

  final List<User> users;

  final void Function(BuildContext context, User user) onUserTapped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final friend = users[index];
        return ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(friend.name),
          subtitle: Text(friend.age),
          onTap: () => onUserTapped(context, friend),
          trailing: Icon(Icons.keyboard_arrow_right_rounded),
        );
      },
    );
  }
}

// class UserScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('User')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => context.to(SettingsPageStack()),
//           child: Text('Go to settings'),
//         ),
//       ),
//     );
//   }
// }
//
// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Settings')),
//       body: Center(
//         child: Text('Here are your settings'),
//       ),
//     );
//   }
// }
