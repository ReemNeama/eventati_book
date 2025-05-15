# Supabase Model Updates Plan

*Created: June 11, 2024*

## Overview

This document outlines the plan for updating our models to be properly uploaded to Supabase. The goal is to ensure that our Supabase database schema matches our existing models, rather than modifying our models to match Supabase.

## Current Status

- We have successfully migrated from Firebase to Supabase
- All Firebase dependencies and code have been removed from the codebase
- Models have been updated with proper Supabase field mappings
- All models have proper toJson and fromJson methods
- toDatabaseDoc methods have been added to all models for Supabase compatibility
- We have generated SQL schema from existing models using update_supabase_schema.dart

## Tasks

### 1. Update Models for Supabase Compatibility

- [x] Ensure all models have proper toJson and fromJson methods
- [x] Add toDatabaseDoc methods to all models for Supabase compatibility
- [x] Update field names to follow Supabase naming conventions (snake_case)
- [x] Ensure all models have proper type mappings for Supabase
- [ ] Verify all relationships between models are correctly defined
- [ ] Add any missing fields required by Supabase

### 2. Generate and Apply SQL Schema

- [x] Generate SQL schema from existing models using update_supabase_schema.dart
- [ ] Review generated SQL schema for any issues or inconsistencies
- [ ] Apply SQL schema to Supabase project
- [ ] Verify all tables are created correctly in Supabase
- [ ] Check for any missing tables or fields

### 3. Implement Row Level Security (RLS) Policies

- [ ] Define RLS policies for all tables
- [ ] Implement user-based access control
- [ ] Test RLS policies to ensure proper access control
- [ ] Document RLS policies for future reference

### 4. Test Data Persistence

- [ ] Create test data for all models
- [ ] Test CRUD operations for all models
- [ ] Verify data integrity and relationships
- [ ] Test edge cases and error handling
- [ ] Document any issues or limitations

### 5. Update Git Repository

- [ ] Commit all changes to the firebase-implementation branch
- [ ] Create a pull request for review
- [ ] Address any feedback or issues
- [ ] Merge changes to master branch

## Model-Specific Updates

### Task Model

The Task model needs special attention due to its complexity and relationships:

```dart
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskStatus status;
  final String categoryId;
  final String? assignedTo;
  final bool isImportant;
  final String? notes;
  final DateTime? completedDate;
  final TaskPriority priority;
  final bool isServiceRelated;
  final String? serviceId;
  final List<String> dependencies;
  final String? eventId;
  final String? service;
  
  // Methods...
}
```

Ensure the following for the Task model:
- Proper mapping of TaskStatus and TaskPriority enums to Supabase
- Correct handling of dependencies as an array field
- Proper relationships with TaskCategory and other related models

### TaskDependency Model

The TaskDependency model represents relationships between tasks:

```dart
class TaskDependency {
  final String prerequisiteTaskId;
  final String dependentTaskId;
  final DependencyType type;
  final int offsetDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Methods...
}
```

Ensure the following for the TaskDependency model:
- Proper mapping of DependencyType enum to Supabase
- Correct handling of composite primary key (prerequisiteTaskId, dependentTaskId)
- Proper relationships with the Task model

## Supabase Schema

The generated SQL schema should include:

1. Table creation statements for all models
2. Proper field types and constraints
3. Primary key definitions
4. Foreign key relationships
5. Indexes for performance optimization

## Testing Strategy

1. Unit tests for model serialization/deserialization
2. Integration tests for database operations
3. End-to-end tests for critical user flows
4. Performance testing for complex queries

## Timeline

- Day 1: Update models and generate SQL schema
- Day 2: Apply SQL schema and implement RLS policies
- Day 3: Test data persistence and fix any issues
- Day 4: Update Git repository and documentation

## Resources

- Supabase Project URL: https://zyycmxzabfadkyzpsper.supabase.co
- Project ID: zyycmxzabfadkyzpsper
- update_supabase_schema.dart script
- Generated SQL schema: scripts/supabase_schema.sql
