import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  ConnectivityService._();

  static final instance = ConnectivityService._();

  StreamSubscription? _subscription;

  bool _wasOffline = false;
  bool _dialogShown = false;

  void init(GlobalKey<NavigatorState> navKey) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final isOffline = result == ConnectivityResult.none;

      if (isOffline) {
        _wasOffline = true;
        _dialogShown = false;
        return;
      }

      if (_wasOffline && !_dialogShown) {
        _wasOffline = false;
        _dialogShown = true;

        final context = navKey.currentContext;
        if (context == null) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🎉 رجع الإنترنت"),
            content: const Text("تم استعادة الاتصال"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("تمام"),
              ),
            ],
          ),
        );
      }
    });
  }

  // 🔥 دي اللي ناقصاك
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
