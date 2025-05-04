# Barrel Model Directory

This directory contains re-export files for backward compatibility. These files re-export models from their respective subfolders to maintain compatibility with existing code that imports directly from the models directory.

## Usage

We recommend using the main models.dart barrel file for imports instead of these individual re-export files:

```dart
import 'package:eventati_book/models/models.dart';

// Now you can use any model
final venue = Venue(...);
final user = User(...);
```

## Future Plans

Once all imports throughout the codebase have been updated to use the models.dart barrel file, these re-export files may be removed.
