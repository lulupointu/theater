import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  Theater.ensureInitialized();
  
  runApp(BooksApp());
}

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

abstract class Authentication {
  Future<bool> isSignedIn();

  Future<void> signOut();

  Future<bool> signIn(String username, String password);
}

class MockAuthentication implements Authentication {
  bool _signedIn = false;

  @override
  Future<bool> isSignedIn() async {
    return _signedIn;
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
  }

  @override
  Future<bool> signIn(String username, String password) async {
    return _signedIn = true;
  }
}

class AuthState extends ChangeNotifier {
  final Authentication _auth;
  bool _isSignedIn = false;

  AuthState({required Authentication auth}) : _auth = auth;

  Future<bool> signIn(Credentials credentials) async {
    var success = await _auth.signIn(credentials.username, credentials.password);
    _isSignedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _isSignedIn = false;
    notifyListeners();
  }

  bool get isSignedIn => _isSignedIn;
}

class BooksApp extends StatefulWidget {
  @override
  State<BooksApp> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final authState = AuthState(auth: MockAuthentication());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Theater(
        initialPageStack: SignInPageStack(onSignedIn: authState.signIn),
        builder: (_, child) => AuthStateUpdateHandler(child: child, authState: authState),
        translatorsBuilder: (_) => [
          ...authState.isSignedIn
              ? [
                  PathTranslator<HomePageStack>(
                    path: '/',
                    pageStack: HomePageStack(onSignOut: authState.signOut),
                  ),
                  PathTranslator<BooksListPageStack>(
                    path: '/books',
                    pageStack: BooksListPageStack(onSignOut: authState.signOut),
                  ),
                  RedirectorTranslator(
                    path: '*',
                    pageStack: HomePageStack(onSignOut: authState.signOut),
                  ),
                ]
              : [
                  PathTranslator<SignInPageStack>(
                    path: '/signin',
                    pageStack: SignInPageStack(onSignedIn: authState.signIn),
                  ),
                  RedirectorTranslator(
                    path: '*',
                    pageStack: SignInPageStack(onSignedIn: authState.signIn),
                  ),
                ],
        ],
      ),
    );
  }
}

class AuthStateUpdateHandler extends StatefulWidget {
  final Widget child;
  final AuthState authState;

  AuthStateUpdateHandler({required this.child, required this.authState});

  @override
  State<AuthStateUpdateHandler> createState() => _AuthStateUpdateHandlerState();
}

class _AuthStateUpdateHandlerState extends State<AuthStateUpdateHandler> {
  void _onAuthStateChange() {
    context.to(
      widget.authState.isSignedIn
          ? HomePageStack(onSignOut: widget.authState.signOut)
          : SignInPageStack(onSignedIn: widget.authState.signIn),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.authState.addListener(_onAuthStateChange);
  }

  @override
  void dispose() {
    widget.authState.removeListener(_onAuthStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class HomePageStack extends PageStack {
  final VoidCallback onSignOut;

  HomePageStack({required this.onSignOut});

  @override
  Widget build(BuildContext context) => HomeScreen(onSignOut: onSignOut);
}

class SignInPageStack extends PageStack {
  final ValueChanged<Credentials> onSignedIn;

  SignInPageStack({required this.onSignedIn});

  @override
  Widget build(BuildContext context) => SignInScreen(onSignedIn: onSignedIn);
}

class BooksListPageStack extends PageStack {
  final VoidCallback onSignOut;

  BooksListPageStack({required this.onSignOut});

  @override
  Widget build(BuildContext context) => BooksListScreen();

  @override
  PageStackBase get pageStackBellow =>
      HomePageStack(onSignOut: onSignOut);
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onSignOut;

  HomeScreen({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.to(BooksListPageStack(onSignOut: onSignOut)),
              child: Text('View my bookshelf'),
            ),
            ElevatedButton(
              onPressed: onSignOut,
              child: Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignedIn;

  SignInScreen({required this.onSignedIn});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'username (any)'),
              onChanged: (s) => _username = s,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'password (any)'),
              obscureText: true,
              onChanged: (s) => _password = s,
            ),
            ElevatedButton(
              onPressed: () => widget.onSignedIn(Credentials(_username, _password)),
              child: Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  BooksListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            title: Text('Stranger in a Strange Land'),
            subtitle: Text('Robert A. Heinlein'),
          ),
          ListTile(
            title: Text('Foundation'),
            subtitle: Text('Isaac Asimov'),
          ),
          ListTile(
            title: Text('Fahrenheit 451'),
            subtitle: Text('Ray Bradbury'),
          ),
        ],
      ),
    );
  }
}
