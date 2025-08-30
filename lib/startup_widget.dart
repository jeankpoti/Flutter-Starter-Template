import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_ai/common_widgets/tracking_permission_dialog.dart';
import 'package:math_ai/features/common/presentation/permission_cubit.dart';
import 'package:math_ai/features/solve_math/presentation/home_page.dart';

class StartupWidget extends StatefulWidget {
  const StartupWidget({super.key});

  @override
  State<StartupWidget> createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestTracking();
  }

  Future<void> _checkAndRequestTracking() async {
    // Initialize permissions
    final permissionCubit = context.read<PermissionCubit>();
    await permissionCubit.initializePermissions();
    
    // Check if we should request tracking permission
    if (permissionCubit.shouldRequestTracking()) {
      // Add a small delay to ensure the UI is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const TrackingPermissionDialog(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}