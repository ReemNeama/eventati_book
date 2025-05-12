# Eventati Book Directory Structure

This document provides an overview of the Eventati Book application's directory structure and organization.

## Root Structure

```
eventati_book/
├── android/            # Android-specific files
├── ios/                # iOS-specific files
├── lib/                # Main Dart code
├── test/               # Test files
├── web/                # Web-specific files
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Package dependencies
└── README.md           # Project README
```

## Main Code Structure (lib/)

```
lib/
├── main.dart           # Application entry point
├── di/                 # Dependency injection
├── models/             # Data models
├── providers/          # State management
├── routing/            # Routing and navigation
├── screens/            # UI screens
├── services/           # Business logic services
├── styles/             # Styling constants
├── tempDB/             # Temporary mock data
├── utils/              # Utility functions
└── widgets/            # Reusable UI components
```

## Models Directory

The models directory contains data classes that represent the application's domain objects.

```
models/
├── models.dart                 # Main barrel file
├── barrel_model.dart           # Legacy re-export file
├── README.md                   # Documentation
├── barrel_model/               # Legacy models folder
├── event_models/               # Event-related models
├── feature_models/             # Feature-specific models
│   ├── saved_comparison.dart     # Saved comparison model
│   └── comparison_annotation.dart # Comparison annotation model
├── planning_models/            # Planning tool models
├── service_models/             # Service-related models
├── service_options/            # Service options models
└── user_models/                # User-related models
```

## Providers Directory

The providers directory contains state management classes using the Provider pattern.

```
providers/
├── providers.dart              # Main barrel file
├── README.md                   # Documentation
├── core_providers/             # Core providers
├── feature_providers/          # Feature-specific providers
└── planning_providers/         # Planning tool providers
```

## Screens Directory

The screens directory contains all UI screens (pages) of the application.

```
screens/
├── screens.dart                # Main barrel file
├── main_navigation_screen.dart # Main navigation
├── README.md                   # Documentation
├── authentications/            # Authentication screens
├── booking/                    # Booking screens
├── events/                     # Event screens
├── event_planning/             # Event planning tool screens
│   ├── budget/                 # Budget management screens
│   ├── guest_list/             # Guest list management screens
│   ├── messaging/              # Vendor messaging screens
│   ├── milestones/             # Milestone tracking screens
│   └── timeline/               # Timeline and checklist screens
├── event_wizard/               # Event wizard screens
├── homepage/                   # Homepage screens
├── profile/                    # Profile screens
└── services/                   # Service screens
    ├── common/                 # Common service screens
    ├── venue/                  # Venue screens
    ├── catering/               # Catering screens
    ├── photographer/           # Photographer screens
    ├── planner/                # Planner screens
    └── comparison/             # Comparison screens
            ├── service_comparison_screen.dart  # Service comparison screen
            └── saved_comparisons_screen.dart   # Saved comparisons screen
```

## Dependency Injection Directory

The di directory contains classes for dependency injection.

```
di/
├── README.md                   # Documentation
├── service_locator.dart        # Service locator for services
└── providers_manager.dart      # Manager for providers
```

## Services Directory

The services directory contains business logic services.

```
services/
├── README.md                   # Documentation
├── analytics/                  # Analytics services
├── auth/                       # Authentication services
├── booking/                    # Booking services
├── comparison/                 # Comparison services
├── event/                      # Event services
├── search/                     # Search services
├── suggestion/                 # Suggestion services
├── task_template_service.dart  # Task template service
├── wizard_connection_service.dart # Wizard connection service
└── wizard/                    # Wizard-related services
    ├── README.md                   # Documentation
    ├── budget_items_builder.dart   # Budget items builder
    └── guest_groups_builder.dart   # Guest groups builder
```

## Styles Directory

The styles directory contains styling constants and themes.

```
styles/
├── app_colors.dart             # Color constants
├── app_colors_dark.dart        # Dark mode colors
├── app_theme.dart              # Theme configuration
├── text_styles.dart            # Text style constants
└── wizard_styles.dart          # Wizard-specific styles
```

## TempDB Directory

The tempDB directory contains temporary mock data for development.

```
tempDB/
├── README.md                   # Documentation
├── services.dart               # Mock service data
├── users.dart                  # Mock user data
└── venues.dart                 # Mock venue data
```

## Utils Directory

The utils directory contains utility functions and constants.

```
utils/
├── utils.dart                  # Main barrel file
├── README.md                   # Documentation
├── core/                       # Core utilities
├── formatting/                 # Formatting utilities
├── service/                    # Service-related utilities
│   ├── file_utils.dart           # File handling utilities
│   └── pdf_export_utils.dart     # PDF export utilities
├── ui/                         # UI-related utilities
└── [various utility files]     # Legacy utility files
```

## Widgets Directory

The widgets directory contains reusable UI components.

```
widgets/
├── widgets.dart                # Main barrel file
├── README.md                   # Documentation
├── auth/                       # Authentication widgets
├── booking/                    # Booking widgets
├── common/                     # Common widgets
├── details/                    # Detail screen widgets
├── event_planning/             # Event planning widgets
│   └── messaging/              # Event planning messaging widgets
├── event_wizard/               # Event wizard widgets
├── messaging/                  # General messaging widgets
├── milestones/                 # Milestone widgets
├── responsive/                 # Responsive design widgets
└── services/                   # Service widgets
    └── comparison/             # Comparison widgets
        └── annotation_dialog.dart  # Annotation dialog widget
```

## File Naming Conventions

- **Screens**: Use the suffix `_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: Use descriptive names without a specific suffix (e.g., `auth_button.dart`)
- **Models**: Use singular nouns (e.g., `user.dart`, `venue.dart`)
- **Providers**: Use the suffix `_provider.dart` (e.g., `auth_provider.dart`)
- **Services**: Use the suffix `_service.dart` (e.g., `task_template_service.dart`)
- **Utils**: Use the suffix `_utils.dart` (e.g., `date_utils.dart`)
- **Barrel Files**: Use either the directory name (e.g., `widgets.dart`) or `index.dart`

## Where to Place New Files

When adding new files to the project, follow these guidelines:

1. **New Models**: Add to the appropriate subfolder in `models/`
2. **New Providers**: Add to the appropriate subfolder in `providers/`
3. **New Screens**: Add to the appropriate subfolder in `screens/`
4. **New Widgets**: Add to the appropriate subfolder in `widgets/`
5. **New Utilities**: Add to the appropriate subfolder in `utils/`
6. **New Services**: Add to the `services/` directory
7. **New Styles**: Add to the `styles/` directory
8. **New Mock Data**: Add to the `tempDB/` directory

## Barrel Files

Barrel files are used to simplify imports by exporting multiple files from a single import. The naming convention for barrel files is:

- Use the directory name (e.g., `widgets.dart` in the `widgets/` directory)
- Use `index.dart` for subfolders (e.g., `index.dart` in the `widgets/auth/` directory)

## Import Guidelines

When importing files, follow these guidelines:

1. **Use Barrel Files**: Import barrel files when possible to reduce the number of import statements
2. **Absolute Imports**: Use absolute imports (e.g., `package:eventati_book/widgets/widgets.dart`)
3. **Specific Imports**: Use specific imports when only a few items are needed from a large barrel file
4. **Avoid Circular Dependencies**: Be careful not to create circular dependencies between files

## Supabase Implementation

The application uses Supabase for backend services:

1. **Supabase Services**: Supabase-specific services are in the `services/supabase/` directory
2. **Database**: Supabase provides the database functionality
3. **Authentication**: Supabase handles user authentication
4. **Storage**: Supabase Storage is used for file storage
