import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_ai/common_widgets/permission_denied_dialog_widget.dart';
import '../../../l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/math_markdown_widget.dart';
import '../../../common_widgets/math_symbols_widget.dart';
import '../../../common_widgets/scan_effect_loader_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/report_content_dialog_widget.dart';
import '../../common/domain/models/content_report.dart';
import '../../common/presentation/permission_cubit.dart';
import '../../common/presentation/mixins/permission_lifecycle_mixin.dart';
import '../../../utils/responsive.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import 'firebase_collection_cubit.dart';
import 'solve_math_cubit.dart';
import 'solve_math_state.dart';
import 'image_capture_cubit.dart';

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

  // void _showPermissionDeniedDialog(String permissionType) {
  //   if (!mounted) return;
  //   showDialog(
  //     context: context,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: Text('$permissionType Permission Denied'),
  //           content: Text(
  //             'Please enable $permissionType access in your device settings to use this feature.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(ctx).pop();
  //                 if (mounted) {
  //                   context.read<ImageCaptureCubit>().resetLoadingState();
  //                 }
  //               },
  //               child: const Text('Close'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 context.read<PermissionCubit>().openSettings();
  //                 Navigator.of(ctx).pop();
  //               },
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.of(ctx).pop();
  //                   openAppSettings();
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Theme.of(context).colorScheme.secondary,
  //                   foregroundColor: Theme.of(context).colorScheme.onSecondary,
  //                 ),
  //                 child: LabelLargeText(
  //                   AppLocalizations.of(context)!.openSettings,
  //                   color: Theme.of(context).colorScheme.onSecondary,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //   );
  // }

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
    showDialog(
      context: context,
      builder:
          (ctx) => BlocBuilder<ImageCaptureCubit, ImageCaptureState>(
            builder:
                (context, imageCaptureState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HeadlineSmallText(
                          AppLocalizations.of(context)!.mathSolution,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageCaptureState.imageFile != null) ...[
                          Container(
                            height: isTablet ? 300 : 150,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: _spacing4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              image: DecorationImage(
                                image: FileImage(imageCaptureState.imageFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.all(_spacing4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: MathMarkdownWidget(data: result),
                        ),
                        const SizedBox(height: _spacing4),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BodySmallText(
                                  AppLocalizations.of(context)!.aiDisclaimer,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: LabelLargeText(
                                AppLocalizations.of(context)!.close,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final imageFile =
                                    context
                                        .read<ImageCaptureCubit>()
                                        .state
                                        .imageFile;
                                _shareResult(result, imageFile);
                                Navigator.of(ctx).pop();
                              },
                              icon: const Icon(Icons.share, size: 16),
                              label: LabelMediumText(
                                AppLocalizations.of(context)!.share,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ReportContentDialogWidget.show(
                              context: context,
                              contentId:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              contentType: ContentType.mathSolution,
                              contentSnapshot: result,
                              contentTitle:
                                  AppLocalizations.of(context)!.mathSolution,
                            );
                          },
                          icon: const Icon(Icons.flag_outlined, size: 16),
                          label: LabelMediumText(
                            AppLocalizations.of(context)!.reportContent,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
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
                      child: _buildModernTabBar(),
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
                            _buildPhotoTab(context, state, isTablet),
                            _buildTextTab(context, state, isTablet),
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

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacing6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            icon: const Icon(Icons.camera_alt_outlined),
            text: AppLocalizations.of(context)!.photo,
            height: 60,
          ),
          Tab(
            icon: const Icon(Icons.edit_outlined),
            text: AppLocalizations.of(context)!.text,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTab(
    BuildContext context,
    SolveMathState state,
    bool isTablet,
  ) {
    return BlocBuilder<ImageCaptureCubit, ImageCaptureState>(
      builder: (context, imageCaptureState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Image Preview Container
              Container(
                width: double.infinity,
                height: isTablet ? 400 : 300,
                margin: const EdgeInsets.only(bottom: _spacing6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (imageCaptureState.imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          imageCaptureState.imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: isTablet ? 80 : 60,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          BodyLargeText(
                            AppLocalizations.of(context)!.noImageSelected,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          BodyMediumText(
                            AppLocalizations.of(context)!.captureOrUpload,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),

                    // Loading overlay
                    if (imageCaptureState.isLoading || state.isIdentifying)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ModernScanEffectLoader(
                                size: isTablet ? 120 : 80,
                                duration: const Duration(milliseconds: 1500),
                              ),
                              const SizedBox(height: _spacing4),
                              BodyMediumText(
                                state.isIdentifying
                                    ? AppLocalizations.of(
                                      context,
                                    )!.analyzingProblem
                                    : AppLocalizations.of(
                                      context,
                                    )!.processingImage,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Action Buttons
              _buildActionButtons(isTablet, state, imageCaptureState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    bool isTablet,
    SolveMathState state,
    ImageCaptureState imageCaptureState,
  ) {
    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt,
                label:
                    imageCaptureState.isCamera &&
                            imageCaptureState.imageFile != null &&
                            state.result.isEmpty
                        ? AppLocalizations.of(context)!.solveProblem
                        : AppLocalizations.of(context)!.takePhoto,
                onPressed:
                    imageCaptureState.isLoading
                        ? null
                        : () async {
                          if (imageCaptureState.isCamera &&
                              imageCaptureState.imageFile != null &&
                              state.result.isEmpty) {
                            await _handleSubscriptionAndSolve();
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            await _takePicture();
                          }
                        },
                isPrimary:
                    imageCaptureState.isCamera &&
                    imageCaptureState.imageFile != null &&
                    state.result.isEmpty,
                isLoading:
                    imageCaptureState.isLoading && imageCaptureState.isCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.photo_library,
                label:
                    imageCaptureState.isGallery &&
                            imageCaptureState.imageFile != null &&
                            state.result.isEmpty
                        ? AppLocalizations.of(context)!.solveProblem
                        : AppLocalizations.of(context)!.uploadPhoto,
                onPressed:
                    imageCaptureState.isLoading
                        ? null
                        : () async {
                          if (imageCaptureState.isGallery &&
                              imageCaptureState.imageFile != null &&
                              state.result.isEmpty) {
                            await _handleSubscriptionAndSolve();
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            context.read<ImageCaptureCubit>().clearImage();
                            await _uploadPicture();
                          }
                        },
                isPrimary:
                    imageCaptureState.isGallery &&
                    imageCaptureState.imageFile != null &&
                    state.result.isEmpty,
                isLoading:
                    imageCaptureState.isLoading && imageCaptureState.isGallery,
              ),
            ),
          ],
        ),

        // Reset Button
        if ((imageCaptureState.isGallery || imageCaptureState.isCamera) &&
            imageCaptureState.imageFile != null &&
            state.result.isEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              icon: Icons.refresh,
              label: AppLocalizations.of(context)!.reset,
              onPressed: () {
                context.read<ImageCaptureCubit>().clearImage();
                context.read<SolveMathCubit>().emptyResult();
              },
              isSecondary: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isSecondary = false,
    bool isLoading = false,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
                : Icon(icon, size: 20),
        label: LabelLargeText(
          label,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
        ),
      );
    } else if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: LabelLargeText(
          label,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    } else {
      return FilledButton.icon(
        onPressed: onPressed,
        icon:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
                : Icon(icon, size: 20),
        label: LabelLargeText(
          label,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    }
  }

  Widget _buildTextTab(
    BuildContext context,
    SolveMathState state,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(_spacing6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    TitleMediumText(
                      AppLocalizations.of(context)!.typeMathProblem,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: _spacing4),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        '${AppLocalizations.of(context)!.enterMathProblem}\n\n${AppLocalizations.of(context)!.exampleProblem}',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.all(_spacing4),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: _spacing4),

                // Math Symbols Widget
                MathSymbolsWidget(controller: _textController),

                const SizedBox(height: _spacing6),

                // Solve Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        state.isIdentifying
                            ? null
                            : () async {
                              if (_textController.text.trim().isEmpty) {
                                _showSnackBarMessage(
                                  AppLocalizations.of(
                                    context,
                                  )!.enterMathProblemError,
                                  isError: true,
                                );
                                return;
                              }
                              await _handleSubscriptionAndSolve(
                                textInput: _textController.text.trim(),
                              );
                            },
                    icon:
                        state.isIdentifying
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                            : const Icon(Icons.auto_awesome, size: 20),
                    label: LabelLargeText(
                      state.isIdentifying
                          ? AppLocalizations.of(context)!.solving
                          : AppLocalizations.of(context)!.solveProblem,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tips Section
          const SizedBox(height: _spacing6),
          Container(
            padding: const EdgeInsets.all(_spacing4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    TitleSmallText(
                      AppLocalizations.of(context)!.tipsForBetterResults,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  AppLocalizations.of(context)!.beSpecificTip,
                  AppLocalizations.of(context)!.useProperNotationTip,
                  AppLocalizations.of(context)!.includeNecessaryInfoTip,
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8, right: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: BodySmallText(
                            tip,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
