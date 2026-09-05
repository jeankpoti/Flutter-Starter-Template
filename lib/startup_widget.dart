import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/config/firebase_config.dart';
import 'package:flutter_starter/core/services/analytics_service.dart';
import 'package:flutter_starter/features/common/presentation/permission_cubit.dart';
import 'package:flutter_starter/features/home/presentation/home_page.dart';
import 'package:flutter_starter/core/services/version_check_service.dart';
import 'package:flutter_starter/common_widgets/force_update_dialog.dart';

class StartupWidget extends StatefulWidget {
  const StartupWidget({super.key});

  @override
  State<StartupWidget> createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  @override
  void initState() {
    super.initState();
    _identifyUser();
    _initializePermissions();
    _checkVersion();
    _requestTrackingAndLogAppOpen();
  }

  Future<void> _requestTrackingAndLogAppOpen() async {
    // Request App Tracking Transparency (iOS 14+) for ad attribution
    await AnalyticsService.requestTrackingAuthorization();

    // Log app open for engagement tracking
    await AnalyticsService.logAppOpen();
  }

  Future<void> _identifyUser() async {
    if (!FirebaseConfig.isInitialized) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await AnalyticsService.setUserId(user.uid);
    }
  }

  Future<void> _checkVersion() async {
    final needsForceUpdate =
        await VersionCheckService().isForceUpdateRequired();
    if (needsForceUpdate && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ForceUpdateDialog(),
      );
    }
  }

  Future<void> _initializePermissions() async {
    // Initialize permissions (camera and gallery state)
    final permissionCubit = context.read<PermissionCubit>();
    await permissionCubit.initializePermissions();
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
