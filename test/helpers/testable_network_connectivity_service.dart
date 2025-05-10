import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Testable version of NetworkConnectivityService
class TestableNetworkConnectivityService {
  /// Connectivity instance
  final Connectivity _connectivity;

  /// Internet connection checker instance
  final InternetConnectionChecker _connectionChecker;

  /// Stream controller for connectivity status
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// Current connectivity status
  bool _isConnected = true;

  /// Constructor with dependency injection for testing
  TestableNetworkConnectivityService({
    required Connectivity connectivity,
    required InternetConnectionChecker connectionChecker,
  }) : _connectivity = connectivity,
       _connectionChecker = connectionChecker {
    // Initialize
    _init();
  }

  /// Initialize the service
  void _init() async {
    // Check initial connectivity
    _isConnected = await _checkConnection();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Listen for internet connection changes
    _connectionChecker.onStatusChange.listen(_updateInternetStatus);

    // Add initial status to stream
    _connectionStatusController.add(_isConnected);

    Logger.d(
      'NetworkConnectivityService initialized, isConnected: $_isConnected',
      tag: 'NetworkConnectivityService',
    );
  }

  /// Update connection status based on connectivity change
  void _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _isConnected = false;
      _connectionStatusController.add(false);
      Logger.d(
        'Connectivity changed: No connection',
        tag: 'NetworkConnectivityService',
      );
    } else {
      // Double-check with actual internet connectivity
      final hasInternet = await _connectionChecker.hasConnection;
      _isConnected = hasInternet;
      _connectionStatusController.add(hasInternet);
      Logger.d(
        'Connectivity changed: ${result.name}, has internet: $hasInternet',
        tag: 'NetworkConnectivityService',
      );
    }
  }

  /// Update internet status based on connection checker
  void _updateInternetStatus(InternetConnectionStatus status) {
    final hasInternet = status == InternetConnectionStatus.connected;
    if (_isConnected != hasInternet) {
      _isConnected = hasInternet;
      _connectionStatusController.add(hasInternet);
      Logger.d(
        'Internet status changed: $hasInternet',
        tag: 'NetworkConnectivityService',
      );
    }
  }

  /// Check if device is connected to the internet
  Future<bool> _checkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return await _connectionChecker.hasConnection;
    } catch (e) {
      Logger.e(
        'Error checking connection: $e',
        tag: 'NetworkConnectivityService',
      );
      return false;
    }
  }

  /// Check if device is currently connected to the internet
  Future<bool> isConnected() async {
    return await _checkConnection();
  }

  /// Get the current connection status
  bool get connectionStatus => _isConnected;

  /// Get a stream of connection status changes
  Stream<bool> get connectionStream => _connectionStatusController.stream;

  /// Dispose the service
  void dispose() {
    _connectionStatusController.close();
  }
}
