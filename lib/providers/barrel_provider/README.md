# Barrel Provider Directory

This directory contains re-export files for backward compatibility. These files re-export providers from their respective subfolders to maintain compatibility with existing code that imports directly from the providers directory.

## Usage

We recommend using the main providers.dart barrel file for imports instead of these individual re-export files:

```dart
import 'package:eventati_book/providers/providers.dart';

// Now you can use any provider
final authProvider = Provider.of<AuthProvider>(context);
```

## Future Plans

Once all imports throughout the codebase have been updated to use the providers.dart barrel file, these re-export files may be removed.
