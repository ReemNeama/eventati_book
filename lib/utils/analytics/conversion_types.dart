/// Define common conversion types
class ConversionTypes {
  /// User registration
  static const String registration = 'registration';
  
  /// Service booking
  static const String booking = 'booking';
  
  /// Product or service purchase
  static const String purchase = 'purchase';
  
  /// Subscription sign-up or renewal
  static const String subscription = 'subscription';
  
  /// Event creation
  static const String eventCreation = 'event_creation';
  
  /// Lead generation
  static const String leadGeneration = 'lead_generation';
  
  /// User engagement
  static const String engagement = 'engagement';
  
  /// Feature usage
  static const String featureUsage = 'feature_usage';
  
  /// Content view
  static const String contentView = 'content_view';
  
  /// Form submission
  static const String formSubmission = 'form_submission';
  
  /// Wizard completion
  static const String wizardCompletion = 'wizard_completion';
  
  /// Get a description for a conversion type
  static String getDescription(String conversionType) {
    switch (conversionType) {
      case registration:
        return 'User Registration';
      case booking:
        return 'Service Booking';
      case purchase:
        return 'Purchase';
      case subscription:
        return 'Subscription';
      case eventCreation:
        return 'Event Creation';
      case leadGeneration:
        return 'Lead Generation';
      case engagement:
        return 'User Engagement';
      case featureUsage:
        return 'Feature Usage';
      case contentView:
        return 'Content View';
      case formSubmission:
        return 'Form Submission';
      case wizardCompletion:
        return 'Wizard Completion';
      default:
        return conversionType;
    }
  }
}
