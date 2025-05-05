# Refactoring Guide

This guide provides detailed instructions on how to refactor code to address the issues identified in the style guide implementation tracker. It explains the techniques and patterns to use when refactoring code to improve its quality and maintainability.

## Table of Contents

1. [Breaking Down Long Methods](#breaking-down-long-methods)
2. [Reducing Cyclomatic Complexity](#reducing-cyclomatic-complexity)
3. [Improving Maintainability](#improving-maintainability)
4. [Replacing Non-null Assertions](#replacing-non-null-assertions)
5. [Removing Unused Parameters](#removing-unused-parameters)
6. [Simplifying Nested Conditional Expressions](#simplifying-nested-conditional-expressions)
7. [Using Conditional Expressions](#using-conditional-expressions)
8. [Alternatives to Late Keyword](#alternatives-to-late-keyword)

## Breaking Down Long Methods

Long methods are difficult to understand, test, and maintain. They often have multiple responsibilities and can be broken down into smaller, more focused methods.

### Technique: Extract Method

1. Identify logical sections within the long method
2. Extract each section into a separate private method
3. Pass necessary parameters to the extracted method
4. Call the extracted method from the original method

### Example

Before:
```dart
void processOrder(Order order) {
  // Validate order
  if (order.items.isEmpty) {
    throw Exception('Order must have at least one item');
  }
  if (order.customer == null) {
    throw Exception('Order must have a customer');
  }
  
  // Calculate total
  double total = 0;
  for (var item in order.items) {
    total += item.price * item.quantity;
  }
  
  // Apply discounts
  if (order.hasPromoCode) {
    total *= 0.9; // 10% discount
  }
  if (order.items.length > 10) {
    total *= 0.95; // Additional 5% discount
  }
  
  // Process payment
  paymentGateway.processPayment(order.customer, total);
  
  // Update inventory
  for (var item in order.items) {
    inventory.reduceStock(item.id, item.quantity);
  }
  
  // Send confirmation
  emailService.sendOrderConfirmation(order.customer.email, order);
}
```

After:
```dart
void processOrder(Order order) {
  _validateOrder(order);
  double total = _calculateTotal(order);
  total = _applyDiscounts(order, total);
  _processPayment(order, total);
  _updateInventory(order);
  _sendConfirmation(order);
}

void _validateOrder(Order order) {
  if (order.items.isEmpty) {
    throw Exception('Order must have at least one item');
  }
  if (order.customer == null) {
    throw Exception('Order must have a customer');
  }
}

double _calculateTotal(Order order) {
  double total = 0;
  for (var item in order.items) {
    total += item.price * item.quantity;
  }
  return total;
}

double _applyDiscounts(Order order, double total) {
  if (order.hasPromoCode) {
    total *= 0.9; // 10% discount
  }
  if (order.items.length > 10) {
    total *= 0.95; // Additional 5% discount
  }
  return total;
}

void _processPayment(Order order, double total) {
  paymentGateway.processPayment(order.customer, total);
}

void _updateInventory(Order order) {
  for (var item in order.items) {
    inventory.reduceStock(item.id, item.quantity);
  }
}

void _sendConfirmation(Order order) {
  emailService.sendOrderConfirmation(order.customer.email, order);
}
```

## Reducing Cyclomatic Complexity

Cyclomatic complexity measures the number of linearly independent paths through a method. High cyclomatic complexity makes code difficult to understand and test.

### Techniques

1. **Extract Method**: Break complex logic into smaller methods
2. **Replace Nested Conditionals with Guard Clauses**: Return early for edge cases
3. **Replace Conditionals with Polymorphism**: Use inheritance or strategy pattern
4. **Use Map Lookups Instead of Switch Statements**: Replace switch statements with map lookups
5. **Use Functional Programming**: Use higher-order functions like `map`, `filter`, and `reduce`

### Example: Replace Nested Conditionals with Guard Clauses

Before:
```dart
String getPaymentDescription(Payment payment) {
  String result = '';
  if (payment != null) {
    if (payment.type == PaymentType.creditCard) {
      if (payment.status == PaymentStatus.processed) {
        result = 'Processed credit card payment';
      } else if (payment.status == PaymentStatus.pending) {
        result = 'Pending credit card payment';
      } else {
        result = 'Failed credit card payment';
      }
    } else if (payment.type == PaymentType.bankTransfer) {
      if (payment.status == PaymentStatus.processed) {
        result = 'Processed bank transfer';
      } else if (payment.status == PaymentStatus.pending) {
        result = 'Pending bank transfer';
      } else {
        result = 'Failed bank transfer';
      }
    } else {
      result = 'Unknown payment type';
    }
  } else {
    result = 'No payment information';
  }
  return result;
}
```

After:
```dart
String getPaymentDescription(Payment? payment) {
  if (payment == null) {
    return 'No payment information';
  }
  
  if (payment.type == PaymentType.creditCard) {
    return _getCreditCardDescription(payment);
  }
  
  if (payment.type == PaymentType.bankTransfer) {
    return _getBankTransferDescription(payment);
  }
  
  return 'Unknown payment type';
}

String _getCreditCardDescription(Payment payment) {
  switch (payment.status) {
    case PaymentStatus.processed:
      return 'Processed credit card payment';
    case PaymentStatus.pending:
      return 'Pending credit card payment';
    default:
      return 'Failed credit card payment';
  }
}

String _getBankTransferDescription(Payment payment) {
  switch (payment.status) {
    case PaymentStatus.processed:
      return 'Processed bank transfer';
    case PaymentStatus.pending:
      return 'Pending bank transfer';
    default:
      return 'Failed bank transfer';
  }
}
```

## Improving Maintainability

Maintainability is a measure of how easy it is to understand, modify, and extend code. Low maintainability makes code difficult to work with.

### Techniques

1. **Use Descriptive Names**: Use clear, descriptive names for variables, methods, and classes
2. **Keep Methods Short and Focused**: Each method should do one thing and do it well
3. **Use Comments Judiciously**: Add comments to explain why, not what
4. **Follow Consistent Patterns**: Use consistent patterns throughout the codebase
5. **Avoid Magic Numbers**: Replace magic numbers with named constants
6. **Use Enums Instead of String Constants**: Use enums for type safety
7. **Extract Complex Expressions**: Extract complex expressions into variables with descriptive names

### Example: Extract Complex Expressions

Before:
```dart
bool isEligibleForDiscount(Customer customer, Order order) {
  return (customer.membershipLevel == MembershipLevel.gold || 
          customer.membershipLevel == MembershipLevel.platinum || 
          (customer.membershipLevel == MembershipLevel.silver && 
           customer.registrationDate.isBefore(DateTime.now().subtract(Duration(days: 365))))) && 
         order.total > 100 && 
         !order.hasAppliedDiscount && 
         order.items.any((item) => item.category == ItemCategory.electronics);
}
```

After:
```dart
bool isEligibleForDiscount(Customer customer, Order order) {
  final bool isPremiumMember = customer.membershipLevel == MembershipLevel.gold || 
                              customer.membershipLevel == MembershipLevel.platinum;
  
  final bool isLongTermSilverMember = customer.membershipLevel == MembershipLevel.silver && 
                                     customer.registrationDate.isBefore(DateTime.now().subtract(Duration(days: 365)));
  
  final bool hasQualifyingMembership = isPremiumMember || isLongTermSilverMember;
  
  final bool hasMinimumOrderValue = order.total > 100;
  
  final bool hasNoExistingDiscount = !order.hasAppliedDiscount;
  
  final bool hasElectronicsItem = order.items.any((item) => item.category == ItemCategory.electronics);
  
  return hasQualifyingMembership && 
         hasMinimumOrderValue && 
         hasNoExistingDiscount && 
         hasElectronicsItem;
}
```

## Replacing Non-null Assertions

Non-null assertions (`!`) are a code smell in Dart's null safety system. They bypass the null safety checks and can lead to runtime errors.

### Techniques

1. **Use Null-aware Operators**: Replace `!` with `?.`, `??`, or `??=`
2. **Use Conditional Statements**: Check for null before accessing properties
3. **Use the `late` Keyword Judiciously**: Use `late` for variables that are initialized after declaration
4. **Redesign to Avoid Nullability**: Redesign the code to avoid nullability altogether

### Example: Use Null-aware Operators

Before:
```dart
void processUser(User? user) {
  final name = user!.name;
  final email = user.email!;
  
  print('Processing user: $name with email: $email');
}
```

After:
```dart
void processUser(User? user) {
  if (user == null) {
    print('No user to process');
    return;
  }
  
  final name = user.name;
  final email = user.email ?? 'No email provided';
  
  print('Processing user: $name with email: $email');
}
```

## Removing Unused Parameters

Unused parameters make code harder to understand and maintain. They can also indicate design problems.

### Techniques

1. **Remove the Parameter**: If the parameter is truly unused, remove it
2. **Make the Parameter Optional**: If the parameter might be used in the future, make it optional
3. **Redesign the Method**: If the parameter is required by the interface but not used, consider redesigning the method

### Example: Remove the Parameter

Before:
```dart
void saveUser(User user, bool sendNotification) {
  database.saveUser(user);
  // sendNotification parameter is never used
}
```

After:
```dart
void saveUser(User user) {
  database.saveUser(user);
}
```

## Simplifying Nested Conditional Expressions

Nested conditional expressions are difficult to read and understand. They can often be simplified.

### Techniques

1. **Extract Method**: Extract complex conditions into separate methods
2. **Use Conditional (Ternary) Operator**: Replace simple if-else statements with conditional operators
3. **Use Null-aware Operators**: Use `?.`, `??`, or `??=` for null checks
4. **Use Switch Statements**: Replace complex if-else chains with switch statements

### Example: Extract Method

Before:
```dart
Widget build(BuildContext context) {
  return Container(
    child: isLoading 
      ? CircularProgressIndicator() 
      : hasError 
        ? Text(error != null ? error : 'An error occurred') 
        : data != null 
          ? ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(data[index].title),
              ),
            ) 
          : Text('No data available'),
  );
}
```

After:
```dart
Widget build(BuildContext context) {
  return Container(
    child: _buildContent(),
  );
}

Widget _buildContent() {
  if (isLoading) {
    return CircularProgressIndicator();
  }
  
  if (hasError) {
    return Text(error ?? 'An error occurred');
  }
  
  if (data != null) {
    return _buildDataList();
  }
  
  return Text('No data available');
}

Widget _buildDataList() {
  return ListView.builder(
    itemCount: data!.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(data![index].title),
    ),
  );
}
```

## Using Conditional Expressions

Conditional expressions (ternary operators) can make code more concise and readable when used appropriately.

### Techniques

1. **Replace Simple If-Else Statements**: Use conditional expressions for simple if-else statements
2. **Avoid Nesting**: Avoid nesting conditional expressions
3. **Use for Assignment**: Use conditional expressions for variable assignment

### Example: Replace Simple If-Else Statements

Before:
```dart
String getStatusText(Status status) {
  if (status == Status.active) {
    return 'Active';
  } else {
    return 'Inactive';
  }
}
```

After:
```dart
String getStatusText(Status status) {
  return status == Status.active ? 'Active' : 'Inactive';
}
```

## Alternatives to Late Keyword

The `late` keyword can be useful but should be used judiciously. It can lead to runtime errors if the variable is accessed before initialization.

### Techniques

1. **Initialize at Declaration**: Initialize variables at declaration when possible
2. **Use Factory Constructors**: Use factory constructors for complex initialization
3. **Use Nullable Types with Null Checks**: Use nullable types and check for null before access
4. **Use Lazy Loading Pattern**: Implement a lazy loading pattern for expensive resources

### Example: Initialize at Declaration

Before:
```dart
class UserViewModel {
  late User user;
  
  void loadUser(int userId) {
    user = userRepository.getUser(userId);
  }
}
```

After:
```dart
class UserViewModel {
  User? user;
  
  Future<void> loadUser(int userId) async {
    user = await userRepository.getUser(userId);
  }
  
  bool get isUserLoaded => user != null;
}
```

## Conclusion

Refactoring is an ongoing process that improves code quality over time. By following these guidelines, you can make your code more maintainable, readable, and robust. Remember to:

1. Make small, incremental changes
2. Run tests after each change
3. Commit frequently
4. Document your changes
5. Review your code with others

Happy refactoring!
