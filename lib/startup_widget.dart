import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_ai/features/common/presentation/permission_cubit.dart';
import 'package:math_ai/features/solve_math/presentation/home_page.dart';
import 'package:math_ai/features/ads/presentation/ad_cubit.dart';
import 'package:math_ai/core/services/version_check_service.dart';
import 'package:math_ai/common_widgets/force_update_dialog.dart';

class StartupWidget extends StatefulWidget {
  const StartupWidget({super.key});

  @override
  State<StartupWidget> createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  @override
  void initState() {
    super.initState();
    _initializePermissions();
    _initializeAds();
    _checkVersion();
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

  Future<void> _initializeAds() async {
    // Initialize ads for free users
    final adCubit = context.read<AdCubit>();
    await adCubit.initializeAds();
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
