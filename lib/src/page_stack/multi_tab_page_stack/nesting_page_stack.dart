import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../framework.dart';
import 'tab_x_in.dart';

/// The state of [NestingPageStack], which will be updated each time [StateBuilder]
/// is called (i.e. each time a new [NestingPageStack] is pushed)
@immutable
class NestedState extends MultiTabState {
  /// {@macro theater.framework.MultiTabState.constructor}
  NestedState({
    required this.nestedPageStack,
  }) : super(
          currentIndex: 0,
          tabsPageStacks: [nestedPageStack].lock,
        );

  /// The [PageStackBase] which is nested
  ///
  /// [nestedPageStack] must implement the [NestedPageStack] mixin as follows:
  /// ```dart
  /// class MyPageStack extends PageStack with NestedPageStack<MyNestingPageStack> {...}
  /// ```
  final NestedPageStack nestedPageStack;

  /// Builds a copy of this [NestedState] where the given attributes have been
  /// replaced
  ///
  /// Use this is [StateBuilder] to easily return the new state
  NestedState withNestedStack(
    NestedPageStack<NestingPageStack> nestedPageStack,
  ) {
    return NestedState(
      nestedPageStack: nestedPageStack,
    );
  }

  /// Creates a [NestedState] from a [_MultiTabState], internal use only
  factory NestedState._fromMultiTabState(
    int currentIndex,
    IList<PageStackBase> sRoutes,
  ) =>
      NestedState(
        nestedPageStack: sRoutes[0] as NestedPageStack<NestingPageStack>,
      );
}

/// An implementation of [MultiTabsPageStack] which makes it easy nest a
/// [PageStackBase] inside another
///
/// TODO: more doc
abstract class NestingPageStack extends MultiTabsPageStack<NestedState> {
  /// TODO: more doc
  const NestingPageStack(StateBuilder<NestedState> stateBuilder)
      : super(stateBuilder, NestedState._fromMultiTabState);
}
