import '../browser/s_browser.dart';
import '../browser/s_url_strategy.dart';

/// Use [sUrlStrategy] on the web to describe whether a hash (#) should be used
/// at the beginning of your url path.
///
/// Read the [SUrlStrategy] class documentation for more details.
void initializeSRouter({SUrlStrategy sUrlStrategy = SUrlStrategy.hash}) {
  SBrowser.initialize(sUrlStrategy: sUrlStrategy);
}
