import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Theater.build(
        initialPageStack: MyScaffoldPageStack((state) => state),
        translatorsBuilder: (_) => [
          PathTranslator<FeaturePageStack>(
            path: '/feature',
            pageStack: FeaturePageStack(),
          ),
          Multi2TabsTranslator<MyScaffoldPageStack>(
            pageStack: MyScaffoldPageStack.new,
            tab1Translators: [
              PathTranslator<HomePageStack>(
                path: '/home',
                pageStack: HomePageStack(),
              ),
              PathTranslator<Home2PageStack>(
                path: '/home2',
                pageStack: Home2PageStack(),
              ),
            ],
            tab2Translators: [
              PathTranslator<ProfilePageStack>(
                path: '/profile',
                pageStack: ProfilePageStack(),
              ),
              PathTranslator<SettingsPageStack>(
                path: '/settings',
                pageStack: SettingsPageStack(),
              ),
              PathTranslator<Settings2PageStack>(
                path: '/settings2',
                pageStack: Settings2PageStack(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void didChangeDependencies() {
    print('ProfileScreen isCurrent: ${PageState.of(context).isCurrent}');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Theater.of(context).to(
                MyScaffoldPageStack(
                  (state) => state.withCurrentStack(SettingsPageStack()),
                ),
              ),
              child: Text('Go to settings'),
            ),
            ElevatedButton(
              onPressed: () => Theater.of(context).to(FeaturePageStack()),
              child: Text('Go to feature'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Theater.of(context).to(
            MyScaffoldPageStack(
              (state) => state.withCurrentStack(Settings2PageStack()),
            ),
          ),
          child: Text('Go to settings2'),
        ),
      ),
    );
  }
}

class Settings2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings2')),
      body: Center(
        child: Text('Here are your settings2'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Center(
          child: ElevatedButton(
            onPressed: () => Theater.of(context).to(
              MyScaffoldPageStack(
                (state) => state.withCurrentStack(Home2PageStack()),
              ),
            ),
            child: Text('Go to Home2'),
          ),
        ),
      ),
    );
  }
}

class Home2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home2')),
      body: Center(
        child: Center(
          child: ElevatedButton(
            onPressed: () => Theater.of(context).to(FeaturePageStack()),
            child: Text('Go to feature'),
          ),
        ),
      ),
    );
  }
}

class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Theater.of(context).to(Feature2PageStack()),
          child: Text('Go to feature2'),
        ),
      ),
    );
  }
}

class Feature2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature2')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Theater.of(context).to(
            MyScaffoldPageStack(
              (state) => state.withCurrentStack(ProfilePageStack()),
            ),
          ),
          child: Text('Go to profile'),
        ),
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final List<Widget> children;
  final int currentIndex;

  const MyScaffold({
    Key? key,
    required this.children,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => Theater.of(context).to(
          MyScaffoldPageStack((state) => state.withCurrentIndex(index)),
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MyScaffoldPageStack extends Multi2TabsPageStack {
  const MyScaffoldPageStack(StateBuilder<Multi2TabsState> stateBuilder)
      : super(stateBuilder);

  @override
  Widget build(BuildContext context, MultiTabPageState<Multi2TabsState> state) {
    return MyScaffold(children: state.tabs, currentIndex: state.currentIndex);
  }

  @override
  Multi2TabsState get initialState => Multi2TabsState(
        currentIndex: 0,
        tab1PageStack: HomePageStack(),
        tab2PageStack: ProfilePageStack(),
      );
}

class HomePageStack extends PageStack with Tab1In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class Home2PageStack extends PageStack with Tab1In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return Home2Screen();
  }

  @override
  Tab1In<MyScaffoldPageStack>? get pageStackBellow => HomePageStack();
}

class ProfilePageStack extends PageStack with Tab2In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}

class SettingsPageStack extends PageStack with Tab2In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }

  @override
  Tab2In<MyScaffoldPageStack>? get pageStackBellow => ProfilePageStack();
}

class Settings2PageStack extends PageStack with Tab2In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return Settings2Screen();
  }

  @override
  Tab2In<MyScaffoldPageStack>? get pageStackBellow => SettingsPageStack();
}

class FeaturePageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return FeatureScreen();
  }

  @override
  PageStackBase? get pageStackBellow => MyScaffoldPageStack((state) => state);
}

class Feature2PageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return Feature2Screen();
  }

  @override
  PageStackBase? get pageStackBellow => FeaturePageStack();
}
