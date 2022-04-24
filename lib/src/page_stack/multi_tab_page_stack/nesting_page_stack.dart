import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tabXIn.dart';

/// The state of [NestingPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [NestingPageStack] is pushed)
@immutable
class NestedState extends MultiTabState {
  /// {@macro srouter.framework.STabsState.constructor}
  NestedState({
    required this.activeIndex,
    required this.nestedPageStack,
  }) : super(
          activeIndex: activeIndex,
          tabsPageStacks: [nestedPageStack].lock,
        );

  @override
  final int activeIndex;

  /// The [PageStackBase] which is nested
  ///
  /// [nestedPageStack] must implement the [NestedPageStack] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with NestedPageStack<MyNestingPageStack> {...}
  /// ```
  final NestedPageStack nestedPageStack;

  /// A list of 2 widgets, one for each tab
  ///
  /// Each widget correspond to a navigator which has the [Page] stack created
  /// by the [PageStackBase] of the given index
  @override
  late final List<Widget> tabs;

  /// Builds a copy of this [NestedState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  NestedState copyWith({
    int? activeIndex,
    NestedPageStack<NestingPageStack>? nestedPageStack,
  }) {
    return NestedState(
      activeIndex: activeIndex ?? this.activeIndex,
      nestedPageStack: nestedPageStack ?? this.nestedPageStack,
    );
  }

  /// Creates a [NestedState] from a [_STabsState], internal use only
  factory NestedState._fromSTabsState(
    int activeIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      NestedState(
        activeIndex: activeIndex,
        nestedPageStack: sRoutes[0] as NestedPageStack<NestingPageStack>,
      );
}

/// An implementation of [MultiTabPageStack] which makes it easy nest a
/// [PageStackBase] inside another
///
/// TODO: more doc
abstract class NestingPageStack extends MultiTabPageStack<NestedState> {
  /// TODO: more doc
  @mustCallSuper
  NestingPageStack(StateBuilder<NestedState> stateBuilder)
      : super(stateBuilder, NestedState._fromSTabsState);
}
