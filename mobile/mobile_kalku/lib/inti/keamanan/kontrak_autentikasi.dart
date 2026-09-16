import 'package:flutter/material.dart';
import '../../data/model/pengguna.dart';

/// Contract for navigation to the authenticated portion of the app.
/// This prevents SplashPage and LoginPage from hardcoding a dependency 
/// on MainShellPage (which belongs to Developer 2).
typedef AuthenticatedPageBuilder = Widget Function(BuildContext context, User user);
