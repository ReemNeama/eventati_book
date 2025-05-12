/// PostHog configuration options for analytics and error tracking
class PostHogOptions {
  /// PostHog API key
  static const String apiKey =
      'phc_plJfFF7ols5rRx3lQOLgM1WDETHd92TSfjMKI2LfHSn';

  /// PostHog API host
  static const String apiHost = 'https://us.i.posthog.com';

  /// Whether to enable debug mode
  static const bool debug = true;

  /// Whether to capture application lifecycle events automatically
  static const bool captureAppLifecycleEvents = true;

  /// Whether to capture deep links automatically
  static const bool captureDeepLinks = true;

  /// Whether to record screen views automatically
  static const bool recordScreenViews = true;

  /// Whether to use the PostHog session replay feature
  static const bool sessionReplay = false;

  /// Whether to flush events on background
  static const bool flushOnBackground = true;

  /// The maximum number of events to queue before sending to PostHog
  static const int maxQueueSize = 20;

  /// The maximum batch size when sending events to PostHog
  static const int maxBatchSize = 20;

  /// The flush interval in seconds
  static const int flushInterval = 30;
}
