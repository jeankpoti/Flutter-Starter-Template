import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_ai/common_widgets/permission_denied_dialog_widget.dart';
import '../../../l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../common/presentation/permission_cubit.dart';
import '../../common/presentation/mixins/permission_lifecycle_mixin.dart';
import '../../../utils/responsive.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import 'firebase_collection_cubit.dart';
import 'solve_math_cubit.dart';
import 'solve_math_state.dart';
import 'image_capture_cubit.dart';
import 'widgets/home/photo_tab_widget.dart';
import 'widgets/home/text_tab_widget.dart';
import 'widgets/home/result_dialog_widget.dart';
import 'widgets/home/modern_tab_bar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        PermissionLifecycleMixin {
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;

  // Design system spacing constants
  static const double _spacing4 = 16.0;
  static const double _spacing6 = 24.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize permissions
    context.read<PermissionCubit>().initializePermissions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Override from PermissionLifecycleMixin - handles showing messages
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Additional handling for permission state messages
    if (state == AppLifecycleState.resumed) {
      final permissionState = context.read<PermissionCubit>().state;
      if (permissionState.message != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ImageCaptureCubit>().resetLoadingState();
          _showSnackBarMessage(permissionState.message!);
          context.read<PermissionCubit>().clearMessage();
        });
      }
    }
  }

  Future<void> _takePicture() async {
    // Capture context-dependent values before async operation
    final imageCaptureCubit = context.read<ImageCaptureCubit>();

    // imageCaptureCubit.clearImage();

    final handled = await imageCaptureCubit.captureFromCamera();

    if (!mounted) return;

    if (!handled) {
      // Show permission dialog
      if (mounted) {
        PermissionDeniedDialogWidget.show(
          context: context,
          permissionType: 'Camera',
        );
      }
    } else if (imageCaptureCubit.state.errorMessage != null && mounted) {
      _showSnackBarMessage(
        imageCaptureCubit.state.errorMessage!,
        isError: true,
      );
    }
  }

  Future<void> _uploadPicture() async {
    // Capture context-dependent values before async operation
    final imageCaptureCubit = context.read<ImageCaptureCubit>();

    final handled = await imageCaptureCubit.selectFromGallery();

    if (!mounted) return;

    if (!handled) {
      // Show permission dialog
      if (mounted) {
        PermissionDeniedDialogWidget.show(
          context: context,
          permissionType: 'Photo Library',
        );
      }
    } else if (imageCaptureCubit.state.errorMessage != null && mounted) {
      _showSnackBarMessage(
        imageCaptureCubit.state.errorMessage!,
        isError: true,
      );
    }
  }

  Future<void> _handleSubscriptionAndSolve({String? textInput}) async {
    final imageFile = context.read<ImageCaptureCubit>().state.imageFile;
    _solveMath(imageFile: imageFile, textInput: textInput);

    final subscriptionCubit = context.read<SubscriptionCubit>();
    await subscriptionCubit.loadSubscriptionStatus();
    final isSubscribed = subscriptionCubit.state.isSubscribed;

    if (!isSubscribed) {
      try {
        await RevenueCatUI.presentPaywall();
        await subscriptionCubit.loadSubscriptionStatus();
        final newStatus = subscriptionCubit.state.isSubscribed;

        if (newStatus && mounted) {
          _solveMath(imageFile: imageFile, textInput: textInput);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBarMessage(
            AppLocalizations.of(context)!.subscriptionError,
            isError: true,
          );
        }
      }
    } else if (mounted) {
      _solveMath(imageFile: imageFile, textInput: textInput);
    }
  }

  void _solveMath({File? imageFile, String? textInput}) {
    if (imageFile != null) {
      context.read<SolveMathCubit>().solveMath(imageFile);
    } else if (textInput != null) {
      context.read<SolveMathCubit>().solveMath(textInput);
    }
  }

  void _showSnackBarMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BodyMediumText(
          message,
          color:
              isError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.surfaceContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: const EdgeInsets.all(_spacing4),
      ),
    );
  }

  Future<void> _shareResult(String result, File? imageFile) async {
    try {
      context.read<SolveMathCubit>().shareResult(imageFile!, result);
    } catch (e) {
      _showSnackBarMessage(
        AppLocalizations.of(context)!.shareError,
        isError: true,
      );
    }
  }

  void _showResultDialog(bool isTablet, String result) {
    ResultDialogWidget.show(
      context: context,
      isTablet: isTablet,
      result: result,
      onShare: _shareResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.solveMathProblem,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SolveMathCubit, SolveMathState>(
            listenWhen:
                (previous, current) =>
                    current.result.isNotEmpty &&
                    current.result != '' &&
                    !current.isIdentifying,
            listener: (context, state) {
              if (state.result.isNotEmpty &&
                  state.result != '' &&
                  !state.isIdentifying) {
                context.read<FirebaseCollectionCubit>().getCollections(
                  isRefresh: true,
                );
                _showResultDialog(isTablet, state.result);
              }
              if (state.isError) {
                _showSnackBarMessage(
                  AppLocalizations.of(context)!.mathSolvingError,
                  isError: true,
                );
              }
            },
          ),
          BlocListener<PermissionCubit, PermissionState>(
            listenWhen: (previous, current) => current.message != null,
            listener: (context, state) {
              if (state.message != null) {
                _showSnackBarMessage(state.message!);
                context.read<PermissionCubit>().clearMessage();
              }
            },
          ),
        ],
        child: SafeArea(
          child: BlocBuilder<SolveMathCubit, SolveMathState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(_spacing4),
                      padding: const EdgeInsets.all(_spacing6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            Theme.of(context).colorScheme.secondaryContainer
                                .withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          HeadlineMediumText(
                            AppLocalizations.of(context)!.aiMathSolver,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 8),
                          BodyLargeText(
                            AppLocalizations.of(context)!.mathSolverDescription,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _spacing4,
                      ),
                      child: ModernTabBarWidget(tabController: _tabController),
                    ),
                  ),

                  // Content Section
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(_spacing4),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            PhotoTabWidget(
                              isTablet: isTablet,
                              onCameraPressed: _takePicture,
                              onGalleryPressed: _uploadPicture,
                              onResetPressed: () {
                                context.read<ImageCaptureCubit>().clearImage();
                                context.read<SolveMathCubit>().emptyResult();
                              },
                              onSolvePressed: _handleSubscriptionAndSolve,
                            ),
                            TextTabWidget(
                              textController: _textController,
                              isTablet: isTablet,
                              onSolvePressed:
                                  () => _handleSubscriptionAndSolve(
                                    textInput: _textController.text.trim(),
                                  ),
                              showSnackBarMessage: _showSnackBarMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
