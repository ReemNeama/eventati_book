# Eventati Book - Development Tracker

## How to use this tracker
- [ ] Unchecked task (not started or in progress)
- [x] Checked task (completed)
- Add notes or comments below tasks as needed

---

## Phase 1: Core Functionality Enhancement

### Week 1: Review & Fix
- [x] Audit existing code and identify bugs or incomplete features
- [ ] Fix text input visibility issue on login page
- [x] Ensure dark/light theme toggle works properly across all screens
- [x] Test navigation flows between all existing screens

### Week 2: Complete Basic Features
- [ ] Finalize any incomplete screens in event planning tools
- [ ] Implement data persistence for all features (using Firebase or local storage)
- [x] Complete the bottom navigation integration
- [x] Ensure all service browsing screens are fully functional

### Week 3: Polish & Stabilize
- [x] Implement consistent error handling throughout the app
- [x] Add loading states for all data operations
- [ ] Ensure responsive design works on different screen sizes
- [x] Create a consistent styling system using your styles folder

## Phase 2: Event Wizard Implementation

### Week 1: Wizard Flow Design
- [ ] Create wizard_start_screen.dart for gathering event basics
- [ ] Design the wizard UI flow with progress indicators
- [ ] Implement event type selection with visual options
- [ ] Build the event details input forms

### Week 2: Suggestion System
- [ ] Create event_template.dart model for different event types
- [ ] Implement suggestion.dart model for recommendations
- [ ] Build wizard_provider.dart to manage the wizard state
- [ ] Develop algorithms for generating appropriate suggestions

### Week 3: Progress Tracking
- [ ] Create wizard_progress_screen.dart to visualize completion
- [ ] Implement progress calculation across all planning areas
- [ ] Build visual progress indicators (charts, progress bars)
- [ ] Add achievement/milestone tracking

### Week 4: Integration
- [ ] Connect wizard to timeline/checklist to populate tasks
- [ ] Link to budget with suggested budget items
- [ ] Integrate with guest list for capacity planning
- [ ] Connect to services screens for recommended vendors

## Phase 3: Service Booking & Purchasing

### Week 1: Booking System Design
- [ ] Create booking_form.dart component for all service types
- [ ] Implement date/time selection with availability checking
- [ ] Design booking confirmation screens
- [ ] Build booking_provider.dart to manage booking state

### Week 2-3: Payment Processing
- [ ] Integrate a payment gateway (Stripe, PayPal, etc.)
- [ ] Create payment_widget.dart for secure payment processing
- [ ] Implement payment confirmation and receipts
- [ ] Build secure storage for payment information

### Week 4: Booking Management
- [ ] Create "My Bookings" section in user profile
- [ ] Implement booking details screen
- [ ] Add booking modification and cancellation functionality
- [ ] Build booking history and status tracking

### Week 5: Notification System
- [ ] Implement in-app notifications for booking updates
- [ ] Add email notification functionality
- [ ] Create reminder system for upcoming bookings
- [ ] Build notification preferences settings

## Phase 4: Comparison & Integration Features

### Week 1: Comparison Selection
- [ ] Add "Compare" checkbox to service list items
- [ ] Create comparison_provider.dart to manage selected items
- [ ] Implement comparison floating action button
- [ ] Build comparison selection management

### Week 2: Comparison Screens
- [ ] Create service_comparison_screen.dart for side-by-side comparison
- [ ] Implement comparison_item_card.dart for individual services
- [ ] Build feature-by-feature comparison tables
- [ ] Add visual indicators for better/worse features

### Week 3: Saving & Sharing
- [ ] Implement saving comparison results to events
- [ ] Add sharing functionality (PDF, email, etc.)
- [ ] Create comparison history in user profile
- [ ] Build comparison notes and annotations

### Week 4: Enhanced Integration
- [ ] Improve connections between all app sections
- [ ] Implement deep linking between related features
- [ ] Create a unified dashboard for event overview
- [ ] Build cross-feature search functionality

## Phase 5: Testing & Refinement

### Week 1: Comprehensive Testing
- [ ] Create and execute test plans for all features
- [ ] Perform cross-device testing
- [ ] Test all user flows and edge cases
- [ ] Fix any identified bugs or issues

### Week 2: UI/UX Refinement
- [ ] Conduct usability review
- [ ] Improve animations and transitions
- [ ] Enhance visual design consistency
- [ ] Optimize for accessibility

### Week 3: Final Polish
- [ ] Perform performance optimization
- [ ] Reduce app size and loading times
- [ ] Prepare for app store submission
- [ ] Create marketing materials and screenshots

---

## Notes & Issues

### Current Blockers
-

### Ideas for Future Enhancements
-

### Completed Milestones
- Basic app structure with navigation, screens, and styling system
- Dark/light theme toggle functionality
- Service browsing screens with filtering and sorting
- Error handling and loading states

---

## Technical Requirements Checklist

### Backend Setup
- [ ] Firebase Authentication configured
- [ ] Cloud Firestore or Realtime Database setup
- [ ] Firebase Cloud Functions implemented (if needed)
- [ ] Firebase Cloud Messaging configured for notifications

### Third-Party Integrations
- [ ] Payment gateway integration
- [ ] Calendar integration
- [ ] Email service setup
- [ ] Social sharing APIs implemented

### Development Environment
- [x] Flutter SDK updated to latest stable version
- [x] Provider package properly implemented
- [ ] Firebase Flutter plugins installed
- [ ] Testing frameworks configured
