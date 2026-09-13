import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T>(
    String route, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      route,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T>(
    String route, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, T>(
      route,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }
}