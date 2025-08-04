// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../permission_cubit.dart';

// mixin PermissionLifecycleMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Check permissions when app comes back to foreground
//     if (state == AppLifecycleState.resumed || state == AppLifecycleState.inactive) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           context.read<PermissionCubit>().checkPendingPermissions();
//         }
//       });
//     }
//   }
// }
