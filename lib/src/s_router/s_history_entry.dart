import 'package:equatable/equatable.dart';

import '../browser/web_entry.dart';
import '../routes/framework.dart';
import '../routes/s_nested.dart';

/// An SHistoryEntry is simply a tuple containing a [WebEntry] and a
/// [SRoute]
class SHistoryEntry extends Equatable {
  /// The [WebEntry] of this history entry
  final WebEntry webEntry;

  /// The [SRoute] of this history entry
  final SRouteBase<NotSNested> route;

  // ignore: public_member_api_docs
  SHistoryEntry({required this.webEntry, required this.route});

  @override
  List<Object?> get props => [webEntry, route];
}
