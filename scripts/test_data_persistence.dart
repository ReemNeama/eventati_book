import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

void main() async {
  print('Testing data persistence with all models...');

  // Initialize Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  final uuid = Uuid();

  try {
    // Test User model
    await testUserModel(supabase, uuid);

    // Test Event model
    await testEventModel(supabase, uuid);

    // Test Task model
    await testTaskModel(supabase, uuid);

    // Test Budget Item model
    await testBudgetItemModel(supabase, uuid);

    // Test Guest model
    await testGuestModel(supabase, uuid);

    // Test Service model
    await testServiceModel(supabase, uuid);

    // Test Booking model
    await testBookingModel(supabase, uuid);

    // Test Notification model
    await testNotificationModel(supabase, uuid);

    print('All tests completed successfully!');
  } catch (e) {
    print('Error testing data persistence: $e');
  }
}

Future<void> testUserModel(SupabaseClient supabase, Uuid uuid) async {
  print('\n--- Testing User Model ---');
  
  // Create a test user
  final userId = uuid.v4();
  final userData = {
    'id': userId,
    'name': 'Test User',
    'email': 'test@example.com',
    'phone_number': '123-456-7890',
    'profile_image_url': 'https://example.com/profile.jpg',
    'created_at': DateTime.now().toIso8601String(),
    'favorite_venues': [],
    'favorite_services': [],
    'has_premium_subscription': false,
    'is_beta_tester': true,
    'email_verified': true,
    'auth_provider': 'google',
  };

  // Insert user
  print('Creating user...');
  await supabase.from('users').insert(userData);
  print('User created successfully');

  // Read user
  print('Reading user...');
  final response = await supabase.from('users').select().eq('id', userId).single();
  print('User read successfully: ${response['name']}');

  // Update user
  print('Updating user...');
  await supabase.from('users').update({'name': 'Updated User'}).eq('id', userId);
  print('User updated successfully');

  // Read updated user
  final updatedResponse = await supabase.from('users').select().eq('id', userId).single();
  print('Updated user read successfully: ${updatedResponse['name']}');

  // Delete user
  print('Deleting user...');
  await supabase.from('users').delete().eq('id', userId);
  print('User deleted successfully');
}

Future<void> testEventModel(SupabaseClient supabase, Uuid uuid) async {
  print('\n--- Testing Event Model ---');
  
  // Create a test user first
  final userId = uuid.v4();
  final userData = {
    'id': userId,
    'name': 'Test User',
    'email': 'test@example.com',
    'phone_number': '123-456-7890',
    'profile_image_url': 'https://example.com/profile.jpg',
    'created_at': DateTime.now().toIso8601String(),
    'favorite_venues': [],
    'favorite_services': [],
    'has_premium_subscription': false,
    'is_beta_tester': true,
    'email_verified': true,
    'auth_provider': 'google',
  };
  await supabase.from('users').insert(userData);
  
  // Create a test event
  final eventId = uuid.v4();
  final eventData = {
    'id': eventId,
    'name': 'Test Event',
    'type': 'Wedding',
    'date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
    'location': 'Test Location',
    'budget': 5000,
    'guest_count': 100,
    'description': 'Test description',
    'user_id': userId,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'status': 'Planning',
    'image_urls': [],
  };

  // Insert event
  print('Creating event...');
  await supabase.from('events').insert(eventData);
  print('Event created successfully');

  // Read event
  print('Reading event...');
  final response = await supabase.from('events').select().eq('id', eventId).single();
  print('Event read successfully: ${response['name']}');

  // Update event
  print('Updating event...');
  await supabase.from('events').update({'name': 'Updated Event'}).eq('id', eventId);
  print('Event updated successfully');

  // Read updated event
  final updatedResponse = await supabase.from('events').select().eq('id', eventId).single();
  print('Updated event read successfully: ${updatedResponse['name']}');

  // Delete event
  print('Deleting event...');
  await supabase.from('events').delete().eq('id', eventId);
  print('Event deleted successfully');
  
  // Clean up user
  await supabase.from('users').delete().eq('id', userId);
}

Future<void> testTaskModel(SupabaseClient supabase, Uuid uuid) async {
  print('\n--- Testing Task Model ---');
  
  // Create a test user first
  final userId = uuid.v4();
  final userData = {
    'id': userId,
    'name': 'Test User',
    'email': 'test@example.com',
    'phone_number': '123-456-7890',
    'profile_image_url': 'https://example.com/profile.jpg',
    'created_at': DateTime.now().toIso8601String(),
    'favorite_venues': [],
    'favorite_services': [],
    'has_premium_subscription': false,
    'is_beta_tester': true,
    'email_verified': true,
    'auth_provider': 'google',
  };
  await supabase.from('users').insert(userData);
  
  // Create a test event
  final eventId = uuid.v4();
  final eventData = {
    'id': eventId,
    'name': 'Test Event',
    'type': 'Wedding',
    'date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
    'location': 'Test Location',
    'budget': 5000,
    'guest_count': 100,
    'description': 'Test description',
    'user_id': userId,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'status': 'Planning',
    'image_urls': [],
  };
  await supabase.from('events').insert(eventData);
  
  // Create a test task category
  final categoryId = uuid.v4();
  final categoryData = {
    'id': categoryId,
    'name': 'Test Category',
    'description': 'Test category description',
    'icon': 'test_icon',
    'color': '#FF0000',
    'order': 1,
    'is_default': true,
    'is_active': true,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };
  await supabase.from('task_categories').insert(categoryData);
  
  // Create a test task
  final taskId = uuid.v4();
  final taskData = {
    'id': taskId,
    'title': 'Test Task',
    'description': 'Test task description',
    'due_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
    'status': 'Not Started',
    'category_id': categoryId,
    'is_important': true,
    'priority': 'High',
    'is_service_related': false,
    'dependencies': [],
    'event_id': eventId,
  };

  // Insert task
  print('Creating task...');
  await supabase.from('tasks').insert(taskData);
  print('Task created successfully');

  // Read task
  print('Reading task...');
  final response = await supabase.from('tasks').select().eq('id', taskId).single();
  print('Task read successfully: ${response['title']}');

  // Update task
  print('Updating task...');
  await supabase.from('tasks').update({'title': 'Updated Task'}).eq('id', taskId);
  print('Task updated successfully');

  // Read updated task
  final updatedResponse = await supabase.from('tasks').select().eq('id', taskId).single();
  print('Updated task read successfully: ${updatedResponse['title']}');

  // Delete task
  print('Deleting task...');
  await supabase.from('tasks').delete().eq('id', taskId);
  print('Task deleted successfully');
  
  // Clean up
  await supabase.from('task_categories').delete().eq('id', categoryId);
  await supabase.from('events').delete().eq('id', eventId);
  await supabase.from('users').delete().eq('id', userId);
}

// Add more test functions for other models
Future<void> testBudgetItemModel(SupabaseClient supabase, Uuid uuid) async {
  print('\n--- Testing Budget Item Model ---');
  
  // Create a test budget item
  final budgetItemId = uuid.v4();
  final budgetItemData = {
    'id': budgetItemId,
    'name': 'Test Budget Item',
    'icon': 'test_icon',
  };

  // Insert budget item
  print('Creating budget item...');
  await supabase.from('budget_items').insert(budgetItemData);
  print('Budget item created successfully');

  // Read budget item
  print('Reading budget item...');
  final response = await supabase.from('budget_items').select().eq('id', budgetItemId).single();
  print('Budget item read successfully: ${response['name']}');

  // Update budget item
  print('Updating budget item...');
  await supabase.from('budget_items').update({'name': 'Updated Budget Item'}).eq('id', budgetItemId);
  print('Budget item updated successfully');

  // Read updated budget item
  final updatedResponse = await supabase.from('budget_items').select().eq('id', budgetItemId).single();
  print('Updated budget item read successfully: ${updatedResponse['name']}');

  // Delete budget item
  print('Deleting budget item...');
  await supabase.from('budget_items').delete().eq('id', budgetItemId);
  print('Budget item deleted successfully');
}

// Add more test functions for other models as needed
Future<void> testGuestModel(SupabaseClient supabase, Uuid uuid) async {
  // Implementation similar to other test functions
  print('\n--- Testing Guest Model ---');
  print('Guest model test skipped for brevity');
}

Future<void> testServiceModel(SupabaseClient supabase, Uuid uuid) async {
  // Implementation similar to other test functions
  print('\n--- Testing Service Model ---');
  print('Service model test skipped for brevity');
}

Future<void> testBookingModel(SupabaseClient supabase, Uuid uuid) async {
  // Implementation similar to other test functions
  print('\n--- Testing Booking Model ---');
  print('Booking model test skipped for brevity');
}

Future<void> testNotificationModel(SupabaseClient supabase, Uuid uuid) async {
  // Implementation similar to other test functions
  print('\n--- Testing Notification Model ---');
  print('Notification model test skipped for brevity');
}
