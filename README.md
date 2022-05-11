Navigation/routing package which is:
  * Compile safe
  * Web compatible yet does not required url handling on mobile
  * Comes with a powerful nested navigator pattern
  * No codegen

## Getting started

### 1. Create stacks of pages:

```dart
class HomePageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class SettingsPageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }
  
  @override
  PageStackBase? get pageStackBellow => HomePageStack();
}
```

### 2. Use the `Theater` widget

```dart
MaterialApp(
  builder: Theater.build(
    initialPageStack: HomePageStack(),
  ),
);
```


### 3. Navigate:

```dart
// Navigate to Home
context.to(HomePageStack());

// Navigate to Seettings
context.to(SettingsPageStack());
```


## Web/Deep linking

If you need deep-linking, or are on the web, use translators to translate you `PageStack`s to url and back

```dart
Theater(
  initialPageStack: HomePageStack(),
  translatorsBuilder: (_) => [
    PathTranslator<HomePageStack>(
      path: '/',
      pageStack: HomePageStack(),
    ),
    PathTranslator<SettingsPageStack>(
      path: '/settings',
      pageStack: SettingsPageStack(),
    ),
  ],
)
```

Use the `.parse` constructor to add and extract arguments from the url:
```dart
PathTranslator<HomePageStack>.parse(
  path: '/:userId',
  matchToPageStack: (match) => HomePageStack(userId: match.pathParams['userId']!),
  pageStackToWebEntry: (pageStack) => WebEntry(path: '/${pageStack.userId}'),
),
```

Use RedirectorTranslator to redirect:
```dart
RedirectorTranslator(path: '*', pageStack: HomePageStack())
```


The translators can be added/removed dynamically:
```dart
Theater(
  initialPageStack: HomePageStack(),
  translatorsBuilder: (_) => [
    isLoggedIn
      ? PathTranslator<HomePageStack>(
          path: '/',
          pageStack: HomePageStack(),
        ),
      : PathTranslator<HomePageStack>(
          path: '/login',
          pageStack: LoginPageStack(),
        ),
  ],
)
```
## Create tabbed page stack

### Create the page stacks

Page stacks of the tabs:
```dart
// Use [Tab1In] on [PageStack]s of the 1st tab
class HomePageStack extends PageStack with Tab1In<MyScaffoldPageStack> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

// Use [Tab2In] on [PageStack]s of the 2nd tab
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
```

Page stack of the scaffold in which the tabs are:
```dart
class MyScaffoldPageStack extends Multi2TabsPageStack {
  // See how to use this constructor in the next section
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
```

### Navigate
```dart
// To the Profile tab
context.theater.to(
  MyScaffoldPageStack((state) => state.withCurrentStack(ProfilePageStack())),
)

// Switch between tabs
context.theater.to(
  MyScaffoldPageStack((state) => state.withCurrentIndex(0)),
)
```

## Handle pop

Use the `WillPopScope` provided by flutter:

```dart
WillPopScope(
  onWillPop: () async {
    // Prevent any pop
    return false;
  },
  child: child,
);
```

## Handle back button

Use the `BackButtonListener` provided by flutter:

```dart
BackButtonListener(
  onBackButtonPressed: () async {
    // Prevent the back button from popping the stack.
    return true;
  },
  child: child,
);
```

## React to visibility change

If you need to know if you widget is currently visible, use `PageState.of(context).isCurrent`:

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late bool _isCurrent;

  @override
  void didChangeDependencies() {
    _isCurrent = PageState.of(context).isCurrent;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
```

This will cause your widget to rebuild when `isActive` changes.