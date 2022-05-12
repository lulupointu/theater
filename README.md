Navigation/routing package which is:
  * Compile safe
  * Web compatible yet does not required url handling on mobile
  * Comes with a powerful nested navigator pattern
  * No codegen

# Index

- [Index](#index)
- [Getting started](#getting-started)
  - [1. Create stacks of pages](#1-create-stacks-of-pages)
  - [2. Use the `Theater` widget](#2-use-the-theater-widget)
  - [3. Navigate](#3-navigate)
- [Web/Deep linking](#webdeep-linking)
  - [Parsing path params, query params, etc.](#parsing-path-params-query-params-etc)
  - [Redirect](#redirect)
  - [Update translators](#update-translators)
- [Create tabbed page stack](#create-tabbed-page-stack)
  - [Create the page stacks](#create-the-page-stacks)
  - [Navigate](#navigate)
  - [Web/Deep linking](#webdeep-linking-1)
- [Handle pop](#handle-pop)
- [Handle back button](#handle-back-button)
- [Custom transitions](#custom-transitions)
  - [Override the default transition for every page stacks](#override-the-default-transition-for-every-page-stacks)
  - [Override the default transition for a specific page stack](#override-the-default-transition-for-a-specific-page-stack)
  - [Keys and transitions](#keys-and-transitions)
- [React to visibility change](#react-to-visibility-change)
- [theater_tutorial](#theater_tutorial)

# Getting started

## 1. Create stacks of pages

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
💡 Tip: use `pstack` in your IDE to easily create a `PageStack`

## 2. Use the `Theater` widget

```dart
MaterialApp(
  builder: Theater.build(
    initialPageStack: HomePageStack(),
  ),
);
```


## 3. Navigate

```dart
// Navigate to Home
context.to(HomePageStack());

// Navigate to Seettings
context.to(SettingsPageStack());
```


# Web/Deep linking

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
💡 Tip: use `ptrans` in your IDE to easily create a `PathTranslator`

⚠️ Warning: Don't forget to give the generic parameter:
```dart
// DO
PathTranslator<HomePageStack>(...)

// DON'T
PathTranslator(...)
```

You also need to add `ensureInitialized` before `runApp`
```dart
void main() {
  Theater.ensureInitialized();

  runApp(...)
}
```

## Parsing path params, query params, etc.

Use the `.parse` constructor to add and extract arguments from the url:
```dart
PathTranslator<HomePageStack>.parse(
  path: '/:userId',
  matchToPageStack: (match) => HomePageStack(userId: match.pathParams['userId']!),
  pageStackToWebEntry: (pageStack) => WebEntry(path: '/${pageStack.userId}'),
),
```
💡 Tip: use `ptransparse` in your IDE to easily create a `PathTranslator.parse`

## Redirect
```dart
RedirectorTranslator(path: '*', pageStack: HomePageStack())
```

## Update translators
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
# Create tabbed page stack

## Create the page stacks

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

💡 Tip: use `m2tabspagestack` in your IDE to easily create a `Multi2TabsPageStack`



## Navigate
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


## Web/Deep linking
```dart
Multi2TabsTranslator<MyScaffoldPageStack>(
  pageStack: MyScaffoldPageStack.new,
  tab1Translators: [
    PathTranslator<HomePageStack>(
      path: '/home',
      pageStack: HomePageStack(),
    ),
  ],
  tab2Translators: [
    PathTranslator<ProfilePageStack>(
      path: '/profile',
      pageStack: ProfilePageStack(),
    ),
  ],
)
```
💡 Tip: use `m2tabspagetrans` in your IDE to easily create a `Multi2TabsTranslator`

# Handle pop

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

# Handle back button

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


# Custom transitions

Transitions are provided by the [Page] object created by each of your page stack. You can use a 
custom page to create a custom transition.

Theater provides an helpful page for this: [CustomTransitionPage].

## Override the default transition for every page stacks

```dart
// Create a FadeTransition as the default transition
Theater(
  defaultPageBuilder: (context, pageStack, child) {
    return CustomTransitionPage(
      key: pageStack.key, // DO use pageStack.key
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  },
  ...
),
```

## Override the default transition for a specific page stack

```dart
class HomePageStack extends PageStack with {
  @override
  Page buildPage(BuildContext context, PageState state, Widget child) {
    return CustomTransitionPage(
      child: child,
      // Create a slide transition from left to right
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(-1, 0.0), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) => HomeScreen();
}
```

## Keys and transitions

Keys are used by Flutter navigator to know if two pages are the same. Transitions only play, when pages are siblings, when their type or keys are different.

For example, with the following `PageStack`:
```dart
class UserPageStack extends PageStack {
  final String userId;
  UserPageStack({required this.userId});
 
  @override
  Widget build(BuildContext context) {
    return UserScreen(userId: userId);
  }
}
```

If you are in the `UserScreen` and use:
```dart
context.to(UserPageStack(userId: 'anotherUserId'))
```
You won't see any transition.

To see a transition, **specify a key in you `PageStack`**:
```dart
class UserPageStack extends PageStack {
  final String userId;
  UserPageStack({required this.userId});
  
  // Use userId, which differentiate the UserPageStacks
  LocalKey get key => ValueKey(userId);

  @override
  Widget build(BuildContext context) {
    return UserScreen(userId: userId);
  }
}
```

# React to visibility change

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
    // Use [PageState.of] in [didChangeDependencies] or directly in your [build] method
    _isCurrent = PageState.of(context).isCurrent;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
```

This will cause your widget to rebuild when `isCurrent` changes.# theater-tutorial
# theater_tutorial
