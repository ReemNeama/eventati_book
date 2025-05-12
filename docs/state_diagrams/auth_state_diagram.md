# Authentication State Transition Diagram

This document illustrates the state transitions in the authentication system of the Eventati Book application.

## Authentication States Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       AUTHENTICATION STATES                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Unauthenticated │                          │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                    ┌────▶│               │                              │
│                    │     │  Authenticating │                           │
│                    │     │               │                              │
│                    │     └───────┬───────┘                              │
│                    │             │                                      │
│                    │             │                                      │
│                    │             ▼                                      │
│                    │     ┌───────────────┐                              │
│                    │     │               │                              │
│                    │     │  Authentication │                           │
│                    │     │  Failed       │                              │
│                    │     │               │                              │
│                    │     └───────────────┘                              │
│                    │                                                    │
│                    │                                                    │
│                    │     ┌───────────────┐                              │
│                    │     │               │                              │
│                    └─────│  Authentication │                           │
│                          │  Error        │                              │
│                          │               │                              │
│                          └───────────────┘                              │
│                                                                         │
│                                                                         │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Authenticated │                            │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Verification │                              │
│                          │  Required     │                              │
│                          │               │                              │
│                          └───────────────┘                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Detailed State Transition Diagram

```
                                 ┌───────────────────┐
                                 │                   │
                                 │  Initial State    │
                                 │                   │
                                 └─────────┬─────────┘
                                           │
                                           │ App Launch
                                           ▼
┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │
│  Registration     │◀──────────│  Unauthenticated  │
│  Screen           │ User taps │                   │
│                   │ Register  └─────────┬─────────┘
└─────────┬─────────┘                     │
          │                               │ User taps Login
          │ Submit Registration           ▼
          │                     ┌───────────────────┐
          │                     │                   │
          │                     │  Login Screen     │
          │                     │                   │
          │                     └─────────┬─────────┘
          │                               │
          │                               │ Submit Login
          ▼                               ▼
┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │
│  Authenticating   │◀──────────┤  Authenticating   │
│  (Registration)   │           │  (Login)          │
│                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘
          │                               │
          │                               │
┌─────────┴─────────┐           ┌─────────┴─────────┐
│                   │           │                   │
│  Registration     │           │  Login            │
│  Success          │           │  Success          │
│                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘
          │                               │
          │                               │
          ▼                               ▼
┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │
│  Verification     │           │  Authenticated    │
│  Required         │           │                   │
│                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘
          │                               │
          │ Verify Email                  │ User logs out
          ▼                               ▼
┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │
│  Authenticated    │           │  Unauthenticated  │
│                   │─────────▶│                   │
│                   │           │                   │
└───────────────────┘           └───────────────────┘
```

## State Descriptions

### Unauthenticated
- **Description**: User is not logged in
- **UI State**: Shows login/register options
- **Data Access**: Limited to public information
- **Transitions**:
  - To **Login Screen** when user taps "Login"
  - To **Registration Screen** when user taps "Register"

### Login Screen
- **Description**: User is on the login form
- **UI State**: Shows email and password fields
- **Data Access**: None
- **Transitions**:
  - To **Authenticating (Login)** when user submits login form
  - To **Registration Screen** when user taps "Create Account"
  - To **Forgot Password** when user taps "Forgot Password"

### Registration Screen
- **Description**: User is on the registration form
- **UI State**: Shows registration fields
- **Data Access**: None
- **Transitions**:
  - To **Authenticating (Registration)** when user submits registration form
  - To **Login Screen** when user taps "Already have an account"

### Authenticating
- **Description**: System is processing authentication request
- **UI State**: Shows loading indicator
- **Data Access**: None
- **Transitions**:
  - To **Authentication Failed** if credentials are invalid
  - To **Authentication Error** if there's a system error
  - To **Authenticated** if login is successful
  - To **Verification Required** if registration is successful

### Authentication Failed
- **Description**: Authentication attempt failed due to invalid credentials
- **UI State**: Shows error message on login/register screen
- **Data Access**: None
- **Transitions**:
  - To **Authenticating** when user retries authentication
  - To **Forgot Password** when user taps "Forgot Password"

### Authentication Error
- **Description**: Authentication attempt failed due to system error
- **UI State**: Shows error message with retry option
- **Data Access**: None
- **Transitions**:
  - To **Authenticating** when user retries authentication

### Authenticated
- **Description**: User is successfully logged in
- **UI State**: Shows main application interface
- **Data Access**: Full access to user's data
- **Transitions**:
  - To **Unauthenticated** when user logs out
  - To **Authentication Error** if session expires or token becomes invalid

### Verification Required
- **Description**: User account created but email verification required
- **UI State**: Shows verification screen with instructions
- **Data Access**: Limited access
- **Transitions**:
  - To **Authenticated** when email is verified
  - To **Unauthenticated** when user logs out

### Forgot Password
- **Description**: User is requesting password reset
- **UI State**: Shows email input for password reset
- **Data Access**: None
- **Transitions**:
  - To **Reset Password Sent** when reset email is sent
  - To **Login Screen** when user cancels

### Reset Password Sent
- **Description**: Password reset email has been sent
- **UI State**: Shows confirmation message
- **Data Access**: None
- **Transitions**:
  - To **Login Screen** when user taps "Return to Login"

## State Variables in AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  // State variables
  AuthState _authState = AuthState.unauthenticated;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get authState => _authState;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get needsVerification => _authState == AuthState.verificationRequired;

  // State transition methods
  Future<void> login(String email, String password) async {
    _setAuthenticating();
    try {
      // Authentication logic
      _setAuthenticated(user);
    } catch (e) {
      _setAuthenticationFailed(e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setAuthenticating();
    try {
      // Registration logic
      _setVerificationRequired(user);
    } catch (e) {
      _setAuthenticationFailed(e.toString());
    }
  }

  Future<void> verifyEmail(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Verification logic
      _setAuthenticated(_currentUser);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    // Logout logic
    _setUnauthenticated();
  }

  // Private state transition helpers
  void _setUnauthenticated() {
    _authState = AuthState.unauthenticated;
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setAuthenticating() {
    _authState = AuthState.authenticating;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
  }

  void _setAuthenticated(User user) {
    _authState = AuthState.authenticated;
    _currentUser = user;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setVerificationRequired(User user) {
    _authState = AuthState.verificationRequired;
    _currentUser = user;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setAuthenticationFailed(String message) {
    _authState = AuthState.authenticationFailed;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}

enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  authenticationFailed,
  authenticationError,
  verificationRequired
}
```

## UI Response to State Changes

### Unauthenticated
```dart
if (authProvider.authState == AuthState.unauthenticated) {
  return AuthScreen(); // Shows login/register options
}
```

### Authenticating
```dart
if (authProvider.isLoading) {
  return LoadingIndicator();
}
```

### Authentication Failed
```dart
if (authProvider.authState == AuthState.authenticationFailed) {
  return ErrorMessage(message: authProvider.errorMessage);
}
```

### Authenticated
```dart
if (authProvider.isAuthenticated) {
  return MainNavigationScreen(); // Main app interface
}
```

### Verification Required
```dart
if (authProvider.needsVerification) {
  return VerificationScreen();
}
```

## Supabase Authentication Integration

When Supabase is implemented, the state transitions will be handled by Supabase Authentication:

```dart
Future<void> login(String email, String password) async {
  _setAuthenticating();
  try {
    // Supabase Authentication
    final response = await _supabase.auth
        .signInWithPassword(email: email, password: password);

    // Get user data from Supabase
    final userData = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    User user = User.fromDatabaseDoc(userData);
    _setAuthenticated(user);
  } on AuthException catch (e) {
    _setAuthenticationFailed(_mapAuthError(e.message));
  } catch (e) {
    _setAuthenticationFailed(e.toString());
  }
}
```
