import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _initializePermissions();
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