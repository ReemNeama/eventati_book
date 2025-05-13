import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/wizard_connection_service.dart';
import 'package:eventati_book/services/supabase/database/task_database_service.dart';
import 'package:eventati_book/services/supabase/database/budget_database_service.dart';
import 'package:eventati_book/services/supabase/database/guest_database_service.dart';
import 'package:eventati_book/services/supabase/database/wizard_connection_database_service.dart';
import 'package:eventati_book/models/planning_models/task_category.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockTaskDatabaseService extends Mock implements TaskDatabaseService {}

class MockBudgetDatabaseService extends Mock implements BudgetDatabaseService {}

class MockGuestDatabaseService extends Mock implements GuestDatabaseService {}

class MockWizardConnectionDatabaseService extends Mock
    implements WizardConnectionDatabaseService {}

// Mock Supabase singleton
class MockSupabase {
  static final MockSupabase _instance = MockSupabase._internal();
  factory MockSupabase() => _instance;
  MockSupabase._internal();

  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late MockUser currentUser;
  bool _initialized = false;

  void initialize() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    currentUser = MockUser();

    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(currentUser);
    when(() => currentUser.id).thenReturn('test_user_id');

    _initialized = true;
  }

  bool get initialized => _initialized;
}

// Override the Supabase.instance getter
@pragma('vm:entry-point')
SupabaseClient get mockSupabaseClient => MockSupabase().client;

void main() {
  // Initialize mock Supabase before tests
  setUpAll(() {
    MockSupabase().initialize();
  });
  group('WizardConnectionService', () {
    late Map<String, dynamic> mockWizardData;

    setUp(() {
      // Create mock wizard data for testing
      mockWizardData = {
        'eventName': 'Test Event',
        'selectedEventType': 'Wedding',
        'eventDate': DateTime.now().add(const Duration(days: 180)),
        'guestCount': 100,
        'selectedServices': {
          'Venue': true,
          'Catering': true,
          'Photography': true,
          'Decoration': false,
          'Entertainment': false,
        },
        'eventDuration': 1,
        'needsSetup': true,
        'setupHours': 2,
        'needsTeardown': true,
        'teardownHours': 2,
      };
    });

    testWidgets('connectToBudget should create budget items', (
      WidgetTester tester,
    ) async {
      // Create a test widget with the BudgetProvider
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => BudgetProvider(eventId: 'test_event'),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      WizardConnectionService.connectToBudget(
                        context,
                        mockWizardData,
                      );
                    },
                    child: const Text('Connect to Budget'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to connect to budget
      await tester.tap(find.text('Connect to Budget'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Get the BudgetProvider
      final budgetProvider = Provider.of<BudgetProvider>(
        tester.element(find.text('Connect to Budget')),
        listen: false,
      );

      // Verify that budget items were created
      expect(budgetProvider.items.isNotEmpty, true);

      // Verify that venue items were created
      final venueItems = budgetProvider.getItemsByCategory('1');
      expect(venueItems.isNotEmpty, true);

      // Verify that catering items were created
      final cateringItems = budgetProvider.getItemsByCategory('2');
      expect(cateringItems.isNotEmpty, true);

      // Verify that photography items were created
      final photographyItems = budgetProvider.getItemsByCategory('3');
      expect(photographyItems.isNotEmpty, true);
    });

    testWidgets('connectToGuestList should create guest groups', (
      WidgetTester tester,
    ) async {
      // Create a test widget with the GuestListProvider
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => GuestListProvider(eventId: 'test_event'),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      WizardConnectionService.connectToGuestList(
                        context,
                        mockWizardData,
                      );
                    },
                    child: const Text('Connect to Guest List'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to connect to guest list
      await tester.tap(find.text('Connect to Guest List'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Get the GuestListProvider
      final guestListProvider = Provider.of<GuestListProvider>(
        tester.element(find.text('Connect to Guest List')),
        listen: false,
      );

      // Verify that guest groups were created
      expect(guestListProvider.groups.isNotEmpty, true);

      // Verify that expected guest count was set
      expect(guestListProvider.expectedGuestCount, 100);

      // Verify that RSVP deadline was set
      expect(guestListProvider.rsvpDeadline != null, true);
    });

    testWidgets('connectToTimeline should create tasks', (
      WidgetTester tester,
    ) async {
      // Create mock database services
      final mockTaskDatabaseService = MockTaskDatabaseService();

      // Set up mock responses
      when(
        () => mockTaskDatabaseService.getTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockTaskDatabaseService.addTask(any(), any()),
      ).thenAnswer((_) async => 'task_id');

      // Create mock task categories
      final mockCategories = [
        TaskCategory(
          id: '1',
          name: 'Venue',
          description: 'Venue tasks',
          icon: 'location_on',
          color: '#4CAF50',
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TaskCategory(
          id: '2',
          name: 'Catering',
          description: 'Catering tasks',
          icon: 'restaurant',
          color: '#FF9800',
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(
        () => mockTaskDatabaseService.getTaskCategories(any()),
      ).thenAnswer((_) async => mockCategories);

      // Create a test widget with the TaskProvider
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create:
                  (_) => TaskProvider(
                    eventId: 'test_event',
                    taskDatabaseService: mockTaskDatabaseService,
                    loadFromDatabase: false,
                  ),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      WizardConnectionService.connectToTimeline(
                        context,
                        mockWizardData,
                      );
                    },
                    child: const Text('Connect to Timeline'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to connect to timeline
      await tester.tap(find.text('Connect to Timeline'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Get the TaskProvider
      final taskProvider = Provider.of<TaskProvider>(
        tester.element(find.text('Connect to Timeline')),
        listen: false,
      );

      // Verify that tasks were created
      expect(taskProvider.tasks.isNotEmpty, true);

      // Print the tasks for debugging
      for (final task in taskProvider.tasks) {
        debugPrint('Task: ${task.title}, Category: ${task.categoryId}');
      }

      // Check for specific task titles that should be created
      final hasBudgetTask = taskProvider.tasks.any(
        (task) =>
            task.title.toLowerCase().contains('venue') ||
            task.title.toLowerCase().contains('catering'),
      );

      expect(hasBudgetTask, true);
    });

    testWidgets('connectToAllPlanningTools should connect to all tools', (
      WidgetTester tester,
    ) async {
      // Create mock database services
      final mockTaskDatabaseService = MockTaskDatabaseService();
      final mockBudgetDatabaseService = MockBudgetDatabaseService();
      final mockGuestDatabaseService = MockGuestDatabaseService();
      final mockWizardConnectionDatabaseService =
          MockWizardConnectionDatabaseService();

      // Set up mock responses for task service
      when(
        () => mockTaskDatabaseService.getTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockTaskDatabaseService.addTask(any(), any()),
      ).thenAnswer((_) async => 'task_id');

      // Create mock task categories
      final mockCategories = [
        TaskCategory(
          id: '1',
          name: 'Venue',
          description: 'Venue tasks',
          icon: 'location_on',
          color: '#4CAF50',
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TaskCategory(
          id: '2',
          name: 'Catering',
          description: 'Catering tasks',
          icon: 'restaurant',
          color: '#FF9800',
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(
        () => mockTaskDatabaseService.getTaskCategories(any()),
      ).thenAnswer((_) async => mockCategories);

      // Set up mock responses for budget service
      when(
        () => mockBudgetDatabaseService.getBudgetItems(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockBudgetDatabaseService.addBudgetItem(any(), any()),
      ).thenAnswer((_) async => 'budget_item_id');

      // Set up mock responses for guest service
      when(
        () => mockGuestDatabaseService.getGuestGroups(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockGuestDatabaseService.addGuestGroup(any(), any()),
      ).thenAnswer((_) async => 'guest_group_id');

      // Set up mock responses for wizard connection service
      when(
        () => mockWizardConnectionDatabaseService.saveWizardConnection(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      // Create a test widget with all providers
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => BudgetProvider(eventId: 'test_event'),
                ),
                ChangeNotifierProvider(
                  create: (_) => GuestListProvider(eventId: 'test_event'),
                ),
                ChangeNotifierProvider(
                  create:
                      (_) => TaskProvider(
                        eventId: 'test_event',
                        taskDatabaseService: mockTaskDatabaseService,
                        loadFromDatabase: false, // Use mock data for tests
                      ),
                ),
                ChangeNotifierProvider(
                  create: (_) => ServiceRecommendationProvider(),
                ),
                ChangeNotifierProvider(create: (_) => WizardProvider()),
              ],
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      WizardConnectionService.connectToAllPlanningTools(
                        context,
                        mockWizardData,
                      );
                    },
                    child: const Text('Connect to All Planning Tools'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to connect to all planning tools
      await tester.tap(find.text('Connect to All Planning Tools'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Get the providers
      final budgetProvider = Provider.of<BudgetProvider>(
        tester.element(find.text('Connect to All Planning Tools')),
        listen: false,
      );

      final guestListProvider = Provider.of<GuestListProvider>(
        tester.element(find.text('Connect to All Planning Tools')),
        listen: false,
      );

      final taskProvider = Provider.of<TaskProvider>(
        tester.element(find.text('Connect to All Planning Tools')),
        listen: false,
      );

      // Verify that budget items were created
      expect(budgetProvider.items.isNotEmpty, true);

      // Verify that guest groups were created
      expect(guestListProvider.expectedGuestCount, 100);

      // Verify that tasks were created
      final venueTasks = taskProvider.getTasksByCategory('1');
      final cateringTasks = taskProvider.getTasksByCategory('2');
      expect(venueTasks.isNotEmpty, true);
      expect(cateringTasks.isNotEmpty, true);
    });
  });
}
