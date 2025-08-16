import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common_widgets/permission_denied_dialog_widget.dart';
import '../../../l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../data/services/image_cropper_service.dart';
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
  DateTime? _lastResultShownTimestamp;

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
    final cropperService = ImageCropperService();

    // Clear any previous result to prevent double dialog
    await context.read<SolveMathCubit>().emptyResult();

    // imageCaptureCubit.clearImage();

    final handled = await imageCaptureCubit.captureFromCamera(
      onImageCaptured: (capturedFile) async {
        // Use the captured context for cropping
        if (!mounted) return null;
        return await cropperService.cropImage(
          imageFile: capturedFile,
          context: context,
        );
      },
    );

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
    final cropperService = ImageCropperService();

    // Clear any previous result to prevent double dialog
    await context.read<SolveMathCubit>().emptyResult();

    final handled = await imageCaptureCubit.selectFromGallery(
      onImageSelected: (selectedFile) async {
        // Use the captured context for cropping
        if (!mounted) return null;
        return await cropperService.cropImage(
          imageFile: selectedFile,
          context: context,
        );
      },
    );

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

    return GestureDetector(
      onTap: () {
        // Unfocus any text field when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.solveMathProblem,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<SolveMathCubit, SolveMathState>(
              listenWhen:
                  (previous, current) =>
                      // previous.result != current.result &&
                      // current.result.isNotEmpty &&
                      // current.result != '' &&
                      // !current.isIdentifying &&
                      // !current.resultShown,
                      (previous.isIdentifying &&
                          !current.isIdentifying &&
                          current.isSuccess) ||
                      // Also detect errors
                      (previous.isIdentifying &&
                          !current.isIdentifying &&
                          current.isError),
              listener: (context, state) {
                if (state.result.isNotEmpty &&
                    state.result != '' &&
                    !state.isIdentifying
                //  &&
                // !state.resultShown &&
                // state.resultTimestamp != null &&
                // state.resultTimestamp != _lastResultShownTimestamp
                ) {
                  log('Result shown');
                  // Track the timestamp to prevent showing the same result twice
                  _lastResultShownTimestamp = state.resultTimestamp;

                  // Mark result as shown immediately to prevent duplicate dialogs
                  context.read<SolveMathCubit>().markResultAsShown();

                  context.read<FirebaseCollectionCubit>().getCollections(
                    isRefresh: true,
                  );
                  _showResultDialog(isTablet, state.result);
                  // Clear the selected image after successful solving
                  context.read<ImageCaptureCubit>().clearImage();
                  // Clear the text input as well
                  _textController.clear();
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
                return Column(
                  children: [
                    // Tab Bar at the top
                    Container(
                      padding: const EdgeInsets.only(
                        left: _spacing4,
                        right: _spacing4,
                        top: _spacing4,
                      ),
                      child: ModernTabBarWidget(tabController: _tabController),
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Photo Tab with its own scroll
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(_spacing4),
                            child: Column(
                              children: [
                                // Header Section for Photo Tab
                                Container(
                                  padding: const EdgeInsets.all(_spacing6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                            .withValues(alpha: 0.3),
                                        Theme.of(context).colorScheme.tertiary
                                            .withValues(alpha: 0.2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 28,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 12),
                                          HeadlineSmallText(
                                            AppLocalizations.of(
                                              context,
                                            )!.aiMathSolver,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      BodyMediumText(
                                        AppLocalizations.of(
                                          context,
                                        )!.mathSolverDescription,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.8),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: _spacing6),
                                PhotoTabWidget(
                                  isTablet: isTablet,
                                  onCameraPressed: _takePicture,
                                  onGalleryPressed: _uploadPicture,
                                  onResetPressed: () {
                                    context
                                        .read<ImageCaptureCubit>()
                                        .clearImage();
                                    context
                                        .read<SolveMathCubit>()
                                        .emptyResult();
                                  },
                                  onSolvePressed: _handleSubscriptionAndSolve,
                                ),
                              ],
                            ),
                          ),

                          // Text Tab with its own scroll
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(_spacing4),
                            child: Column(
                              children: [
                                // Header Section for Text Tab
                                // Container(
                                //   padding: const EdgeInsets.all(_spacing6),
                                //   decoration: BoxDecoration(
                                //     gradient: LinearGradient(
                                //       colors: [
                                //         Theme.of(context)
                                //             .colorScheme
                                //             .secondaryContainer
                                //             .withValues(alpha: 0.3),
                                //         Theme.of(context).colorScheme.tertiary
                                //             .withValues(alpha: 0.2),
                                //       ],
                                //       begin: Alignment.topLeft,
                                //       end: Alignment.bottomRight,
                                //     ),
                                //     borderRadius: BorderRadius.circular(16.0),
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       Row(
                                //         children: [
                                //           Icon(
                                //             Icons.auto_awesome,
                                //             size: 28,
                                //             color:
                                //                 Theme.of(
                                //                   context,
                                //                 ).colorScheme.secondary,
                                //           ),
                                //           const SizedBox(width: 12),
                                //           HeadlineSmallText(
                                //             AppLocalizations.of(
                                //               context,
                                //             )!.aiMathSolver,
                                //             fontWeight: FontWeight.bold,
                                //             color:
                                //                 Theme.of(
                                //                   context,
                                //                 ).colorScheme.onSurface,
                                //           ),
                                //         ],
                                //       ),

                                //       const SizedBox(height: 8),
                                //       BodyMediumText(
                                //         AppLocalizations.of(
                                //           context,
                                //         )!.mathSolverDescription,
                                //         color: Theme.of(context)
                                //             .colorScheme
                                //             .onSurface
                                //             .withValues(alpha: 0.8),
                                //         textAlign: TextAlign.center,
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(height: _spacing6),
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
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
