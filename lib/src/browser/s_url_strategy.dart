/// The two strategies which are available when it comes to displaying the url.
///
/// They describe whether a hash (#) should be used at the beginning of your url
/// path.
///
///
/// ### IMPORTANT CONSIDERATION
/// Web browsers do not contact a server if a hash changes. This
/// means that if your application is already launched in the browser, when the
/// user manually types in a new url within your website:
///   - If you are using [SUrlStrategy.hash], the application will update
///   - If you are using [SUrlStrategy.history], the browser will fetch your
///   ^ application from your server, which will cause it to restart entirely
/// Both will result in the same outcome, the second will simply be slower due
/// to the app having to be re-fetched from your server
/// This is the only difference I know (apart from the presence/absence of the #
/// of course). If you know something else, please enlighten me
enum SUrlStrategy {
  /// This is the default, the url will be serverAddress/#/localUrl
  hash,

  /// This will display the url in the way we are used to, without the #.
  /// However note that you will need to configure your server to make this work.
  /// Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  ///
  ///
  /// DO read the IMPORTANT CONSIDERATION above before choosing this option
  history,
}
