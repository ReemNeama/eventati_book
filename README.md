# Eventati Book

A comprehensive event planning and venue booking application built with Flutter.

## Project Vision

Eventati Book is designed to help users advertise and manage venues for different events (business events, celebrations, weddings), providing an enhanced user experience through a complete event planning solution.

### Core Concepts

1. **Event Wizard with Guided Planning**
   - Users can create an event to receive suggestions on what they should do next
   - The wizard provides a guided experience based on event type
   - Progress tracking with checklists helps users know what's completed and what's next
   - Creates a supportive experience for users who aren't sure where to start

2. **Flexible Service Discovery & Purchasing**
   - Users can browse venues, catering, photography, and planning services independently
   - Direct purchasing/booking functionality without requiring the wizard
   - Gives users freedom to either follow the guided wizard approach or self-direct their planning

3. **Comprehensive All-in-One Platform**
   - Users can compare different services (venues, caterers, photographers)
   - Everything is integrated in one place - browsing, purchasing, and management
   - The unified experience makes event planning significantly easier

## Technical Architecture

- **Frontend**: Flutter for cross-platform mobile development
- **State Management**: Provider pattern
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **Design Pattern**: Feature-first architecture with clean separation of concerns

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic services
├── styles/         # Theme and styling
├── tempDB/         # Temporary mock data
├── utils/          # Utility functions
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

For a more detailed overview of the project structure, see [DIRECTORY_STRUCTURE.md](DIRECTORY_STRUCTURE.md).

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Application Architecture](docs/app_architecture.md)**: Overall application architecture
- **[Services Flow](docs/services_flow.md)**: Service screens flow and components
- **[Booking Integration](docs/booking_integration.md)**: Booking system integration with services
- **[Event Planning Tools](docs/event_planning_tools.md)**: Event planning tools flow and components
- **[Event Wizard Flow](docs/event_wizard_flow.md)**: Event wizard flow and components

## Development Recommendations

1. **Phase-Based Development Approach**
   - Complete core functionality before adding new features
   - Implement the Event Wizard as the first major feature
   - Add booking and payment processing capabilities
   - Implement comparison features last

2. **Technical Recommendations**
   - Use Firebase for authentication and data persistence
   - Implement proper error handling and loading states
   - Ensure responsive design works across different devices
   - Maintain consistent styling using the styles system

3. **Testing Strategy**
   - Write unit tests for business logic
   - Create widget tests for UI components
   - Perform integration tests for critical user flows
   - Test on multiple device sizes and platforms

## Getting Started

1. Clone the repository
   ```
   git clone git@github.com:ReemNeama/eventati_book.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run the app
   ```
   flutter run
   ```

## Development Guidelines

To maintain code quality and consistency, please follow the guidelines in these documents:

- [Development Guidelines](DEVELOPMENT_GUIDELINES.md) - Comprehensive coding standards and best practices
- [Code Review Checklist](CODE_REVIEW_CHECKLIST.md) - Quick checklist to use before committing code
- [Documentation Standards](docs/DOCUMENTATION_STANDARDS.md) - Guidelines for documenting code

### Code Quality Tools

Run the code quality check script before committing:

```
# On Windows
.\check_code.bat

# On macOS/Linux
chmod +x check_code.sh
./check_code.sh
```

### Documentation

Generate documentation for the project:

```
# Generate documentation
dart run tool/generate_docs.dart

# Clean and regenerate documentation
dart run tool/generate_docs.dart --clean
```

View the generated documentation in the [docs](docs/documentation.md) directory.

## Development Progress

Track development progress in the [Development Tracker](eventati_book_development_tracker.md).
