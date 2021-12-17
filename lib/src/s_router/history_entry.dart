import 'package:equatable/equatable.dart';

import '../browser/web_entry.dart';
import '../page_stack/framework.dart';
import '../page_stack/nested_stack.dart';

/// An SHistoryEntry is simply a tuple containing a [WebEntry] and a
/// [PageStack]
class HistoryEntry extends Equatable {
  /// The [WebEntry] of this history entry
  final WebEntry webEntry;

  /// The [PageStack] of this history entry
  final PageStackBase<NonNestedStack> pageStack;

  // ignore: public_member_api_docs
  HistoryEntry({required this.webEntry, required this.pageStack});

  @override
  List<Object?> get props => [webEntry, pageStack];
}
