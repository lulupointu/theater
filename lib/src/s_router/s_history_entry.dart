import 'package:equatable/equatable.dart';

import '../route/pushables/pushables.dart';
import '../route/s_route_interface.dart';
import '../web_entry/web_entry.dart';

/// An SHistoryEntry is simply a tuple containing a [WebEntry] and a
/// [SRoute]
class SHistoryEntry extends Equatable {
  /// The [WebEntry] of this history entry
  final WebEntry webEntry;

  /// The [SRoute] of this history entry
  final SRouteInterface<SPushable> route;

  // ignore: public_member_api_docs
  SHistoryEntry({required this.webEntry, required this.route});

  @override
  List<Object?> get props => [webEntry, route];
}
