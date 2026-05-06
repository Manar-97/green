import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/reset_password.dart';

class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;
  StreamSubscription? _sub;

  DeepLinkService(this.navigatorKey);

  Future<void> init() async {
    final appLinks = AppLinks();

    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleUri(initialUri);
    }

    _sub = appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint("📩 DEEP LINK: $uri");

    if (uri.host == "reset-callback") {
      final error = uri.queryParameters['error'];

      if (error != null) {
        debugPrint("❌ LINK ERROR: $error");
        return;
      }

      navigatorKey.currentState?.pushNamed(ResetPasswordPage.routeName);
    }
  }

  void dispose() => _sub?.cancel();
}
