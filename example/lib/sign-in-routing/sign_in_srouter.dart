import 'package:flutter/material.dart';
import 'package:srouter/src/route/s_route_interface.dart';
import 'package:srouter/srouter.dart';

void main() {
  initializeSRouter();

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
      title: 'Books App',
      home: SRouter(
        initialRoute: SignInSRoute(onSignedIn: authState.signIn),
        builder: (_, child) => AuthStateUpdateHandler(child: child, authState: authState),
        translatorsBuilder: (_) => [
          ...authState.isSignedIn
              ? [
                  SPathTranslator<HomeSRoute, SPushable>(
                    path: '/',
                    route: HomeSRoute(onSignOut: authState.signOut),
                  ),
                  SPathTranslator<BooksListSRoute, SPushable>(
                    path: '/books',
                    route: BooksListSRoute(onSignOut: authState.signOut),
                  ),
                  SRedirectorTranslator(
                    path: '*',
                    route: HomeSRoute(onSignOut: authState.signOut),
                  ),
                ]
              : [
                  SPathTranslator<SignInSRoute, SPushable>(
                    path: '/signin',
                    route: SignInSRoute(onSignedIn: authState.signIn),
                  ),
                  SRedirectorTranslator(
                    path: '*',
                    route: SignInSRoute(onSignedIn: authState.signIn),
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
    context.sRouter.to(
      widget.authState.isSignedIn
          ? HomeSRoute(onSignOut: widget.authState.signOut)
          : SignInSRoute(onSignedIn: widget.authState.signIn),
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

class HomeSRoute extends SRoute<SPushable> {
  final VoidCallback onSignOut;

  HomeSRoute({required this.onSignOut});

  @override
  Widget build(BuildContext context) => HomeScreen(onSignOut: onSignOut);
}

class SignInSRoute extends SRoute<SPushable> {
  final ValueChanged<Credentials> onSignedIn;

  SignInSRoute({required this.onSignedIn});

  @override
  Widget build(BuildContext context) => SignInScreen(onSignedIn: onSignedIn);
}

class BooksListSRoute extends SRoute<SPushable> {
  final VoidCallback onSignOut;

  BooksListSRoute({required this.onSignOut});

  @override
  Widget build(BuildContext context) => BooksListScreen();

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) =>
      HomeSRoute(onSignOut: onSignOut);
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
              onPressed: () => context.sRouter.to(BooksListSRoute(onSignOut: onSignOut)),
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
