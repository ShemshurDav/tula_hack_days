import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  final _connectivity = connectivity.Connectivity();
  
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != connectivity.ConnectivityResult.none;
      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        notifyListeners();
      }
    });

    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != connectivity.ConnectivityResult.none;
    notifyListeners();
  }
} 