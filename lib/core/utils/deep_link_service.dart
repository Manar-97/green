import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/reset_password.dart';
import '../../features/user/presentation/pages/home.dart';

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

    debugPrint("HOST: ${uri.host}");
    debugPrint("QUERY: ${uri.queryParameters}");

    if (uri.host == "reset-callback") {
      navigatorKey.currentState?.pushNamed(ResetPasswordPage.routeName);
      return;
    }
    if (uri.host == "login-callback") {
      debugPrint("🟡 GOOGLE CALLBACK RECEIVED (ignored)");

      // Supabase already handled session via onAuthStateChange
      return;
    }
    debugPrint("⚠️ UNKNOWN DEEP LINK");
  }

  void dispose() => _sub?.cancel();
}
