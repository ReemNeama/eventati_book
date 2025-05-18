import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:eventati_book/utils/logger.dart';

/// Service for handling biometric authentication
class BiometricAuthService {
  /// Local authentication instance
  final LocalAuthentication _localAuth;

  /// Secure storage instance
  final FlutterSecureStorage _secureStorage;

  /// Storage key for email
  static const String _emailKey = 'biometric_auth_email';

  /// Storage key for password
  static const String _passwordKey = 'biometric_auth_password';

  /// Storage key for biometric auth enabled flag
  static const String _biometricEnabledKey = 'biometric_auth_enabled';

  /// Constructor
  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if biometrics are available on the device
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      return canAuthenticate;
    } on PlatformException catch (e) {
      Logger.e(
        'Error checking biometric availability: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    } catch (e) {
      Logger.e(
        'Unexpected error checking biometric availability: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      Logger.e(
        'Error getting available biometrics: $e',
        tag: 'BiometricAuthService',
      );
      return [];
    } catch (e) {
      Logger.e(
        'Unexpected error getting available biometrics: $e',
        tag: 'BiometricAuthService',
      );
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to sign in',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        Logger.e(
          'Biometric authentication not available',
          tag: 'BiometricAuthService',
        );
      } else if (e.code == auth_error.notEnrolled) {
        Logger.e(
          'No biometrics enrolled on this device',
          tag: 'BiometricAuthService',
        );
      } else if (e.code == auth_error.lockedOut) {
        Logger.e(
          'Biometric authentication locked out',
          tag: 'BiometricAuthService',
        );
      } else if (e.code == auth_error.permanentlyLockedOut) {
        Logger.e(
          'Biometric authentication permanently locked out',
          tag: 'BiometricAuthService',
        );
      } else {
        Logger.e(
          'Error authenticating with biometrics: $e',
          tag: 'BiometricAuthService',
        );
      }
      return false;
    } catch (e) {
      Logger.e(
        'Unexpected error authenticating with biometrics: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    }
  }

  /// Save credentials for biometric authentication
  Future<bool> saveCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
      return true;
    } catch (e) {
      Logger.e('Error saving credentials: $e', tag: 'BiometricAuthService');
      return false;
    }
  }

  /// Get saved credentials
  Future<Map<String, String?>> getCredentials() async {
    try {
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      return {'email': email, 'password': password};
    } catch (e) {
      Logger.e('Error getting credentials: $e', tag: 'BiometricAuthService');
      return {'email': null, 'password': null};
    }
  }

  /// Delete saved credentials
  Future<bool> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
      return true;
    } catch (e) {
      Logger.e('Error deleting credentials: $e', tag: 'BiometricAuthService');
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      Logger.e(
        'Error checking if biometric auth is enabled: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
      return true;
    } catch (e) {
      Logger.e(
        'Error setting biometric auth enabled: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final credentials = await getCredentials();
      return credentials['email'] != null && credentials['password'] != null;
    } catch (e) {
      Logger.e(
        'Error checking if credentials are saved: $e',
        tag: 'BiometricAuthService',
      );
      return false;
    }
  }
}
