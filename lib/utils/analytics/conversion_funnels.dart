/// Define common conversion funnels
class ConversionFunnels {
  /// Booking funnel steps
  static const String bookingFunnel = 'booking_funnel';
  static const int bookingSearch = 1;
  static const int bookingDetails = 2;
  static const int bookingDateSelection = 3;
  static const int bookingCheckout = 4;
  static const int bookingPayment = 5;
  static const int bookingConfirmation = 6;
  
  /// Registration funnel steps
  static const String registrationFunnel = 'registration_funnel';
  static const int registrationStart = 1;
  static const int registrationForm = 2;
  static const int registrationVerification = 3;
  static const int registrationComplete = 4;
  
  /// Event creation funnel steps
  static const String eventCreationFunnel = 'event_creation_funnel';
  static const int eventTypeSelection = 1;
  static const int eventBasicInfo = 2;
  static const int eventDateSelection = 3;
  static const int eventGuestEstimation = 4;
  static const int eventBudgetEstimation = 5;
  static const int eventComplete = 6;
  
  /// Wizard funnel steps
  static const String wizardFunnel = 'wizard_funnel';
  static const int wizardStart = 1;
  static const int wizardStepComplete = 2;
  static const int wizardComplete = 3;
  
  /// Get step name for a funnel
  static String getStepName(String funnelName, int stepNumber) {
    switch (funnelName) {
      case bookingFunnel:
        return _getBookingStepName(stepNumber);
      case registrationFunnel:
        return _getRegistrationStepName(stepNumber);
      case eventCreationFunnel:
        return _getEventCreationStepName(stepNumber);
      case wizardFunnel:
        return _getWizardStepName(stepNumber);
      default:
        return 'Step $stepNumber';
    }
  }
  
  /// Get booking step name
  static String _getBookingStepName(int stepNumber) {
    switch (stepNumber) {
      case bookingSearch:
        return 'Search';
      case bookingDetails:
        return 'Details';
      case bookingDateSelection:
        return 'Date Selection';
      case bookingCheckout:
        return 'Checkout';
      case bookingPayment:
        return 'Payment';
      case bookingConfirmation:
        return 'Confirmation';
      default:
        return 'Step $stepNumber';
    }
  }
  
  /// Get registration step name
  static String _getRegistrationStepName(int stepNumber) {
    switch (stepNumber) {
      case registrationStart:
        return 'Start';
      case registrationForm:
        return 'Form';
      case registrationVerification:
        return 'Verification';
      case registrationComplete:
        return 'Complete';
      default:
        return 'Step $stepNumber';
    }
  }
  
  /// Get event creation step name
  static String _getEventCreationStepName(int stepNumber) {
    switch (stepNumber) {
      case eventTypeSelection:
        return 'Type Selection';
      case eventBasicInfo:
        return 'Basic Info';
      case eventDateSelection:
        return 'Date Selection';
      case eventGuestEstimation:
        return 'Guest Estimation';
      case eventBudgetEstimation:
        return 'Budget Estimation';
      case eventComplete:
        return 'Complete';
      default:
        return 'Step $stepNumber';
    }
  }
  
  /// Get wizard step name
  static String _getWizardStepName(int stepNumber) {
    switch (stepNumber) {
      case wizardStart:
        return 'Start';
      case wizardStepComplete:
        return 'Step Complete';
      case wizardComplete:
        return 'Complete';
      default:
        return 'Step $stepNumber';
    }
  }
}
