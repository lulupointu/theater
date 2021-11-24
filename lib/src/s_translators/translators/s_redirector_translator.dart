import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../route/pushables/pushables.dart';
import '../../route/s_route_interface.dart';
import '../../s_router/s_router.dart';
import '../../web_entry/web_entry.dart';
import '../s_translator.dart';
import 'web_entry_matcher/web_entry_match.dart';
import 'web_entry_matcher/web_entry_matcher.dart';

/// A translator which can be used to redirect from a [path] to a [WebEntry]
class SRedirectorTranslator extends STranslator<SRouteInterface<SPushable>, SPushable> {
  // TODO: add doc
  SRedirectorTranslator({
    required String from,
    required this.to,
    this.replace = true,

    // Functions used to validate the different components of the url
    final bool Function(Map<String, String> pathParams)? validatePathParams,
    final bool Function(Map<String, String> queryParams)? validateQueryParams,
    final bool Function(String fragment)? validateFragment,
    final bool Function(Map<String, String> historyState)? validateHistoryState,
  }) : _matcher = WebEntryMatcher(
          path: from,
          validatePathParams: validatePathParams,
          validateQueryParams: validateQueryParams,
          validateFragment: validateFragment,
          validateHistoryState: validateHistoryState,
        );

  // TODO: add doc
  SRedirectorTranslator.static({
    required String from,
    required SRouteInterface<SPushable> to,
    this.replace = true,
  })  : _matcher = WebEntryMatcher(path: from),
        to = ((_, __) => to);

  /// The url to redirect to
  final SRouteInterface<SPushable> Function(BuildContext context, WebEntryMatch match) to;

  /// Whether the path we navigate to should replace the current history entry
  ///
  ///
  /// Defaults to true
  final bool replace;

  /// A class which determined whether a given [WebEntry] is valid
  final WebEntryMatcher _matcher;

  @override
  SRouteInterface<SPushable>? webEntryToSRoute(BuildContext context, WebEntry webEntry) {
    final match = _matcher.match(webEntry);

    // If the web entry does not match, return null
    if (match == null) {
      return null;
    }

    final destinationSRoute = to(context, match);

    // We need to wait one frame since this might be called inside
    // [SRouter] build phase
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      if (replace) {
        SRouter.of(context, listen: false).replace(destinationSRoute);
      } else {
        SRouter.of(context, listen: false).push(destinationSRoute);
      }
    });

    return destinationSRoute;
  }

  /// We must override the [routeType] so that this translator is never matched
  /// when trying to convert a [SRoute] to a [WebEntry]
  @override
  Type get routeType => Null;

  @override
  WebEntry sRouteToWebEntry(BuildContext context, SRouteInterface route) {
    throw 'This should never be called';
  }
}
