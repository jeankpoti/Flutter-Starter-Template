import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/math_markdown_widget.dart';
import '../../../common_widgets/math_symbols_widget.dart';
import '../../../common_widgets/scan_effect_loader_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../utils/responsive.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import 'firebase_collection_cubit.dart';
import 'solve_math_cubit.dart';
import 'solve_math_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false, _isCamera = false, _isGallery = false;

  // Design system spacing constants
  static const double _spacing4 = 16.0;
  static const double _spacing6 = 24.0;
  static const double _spacing8 = 32.0;
  static const double _spacing10 = 40.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSubscriptionAndSolve({
    File? imageFile,
    String? textInput,
  }) async {
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
            'Error showing subscription options. Please try again.',
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

  Future<void> _takePicture() async {
    setState(() {
      _isGallery = false;
      _isLoading = true;
      _isCamera = true;
    });

    try {
      if (Platform.isAndroid) {
        final PermissionStatus photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog('Photo Library');
          setState(() => _isLoading = false);
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        setState(() => _isLoading = false);
        return;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final String secureFilePath = path.join(appDir.path, fileName);

      final File localImage = File(secureFilePath);
      await localImage.writeAsBytes(await photo.readAsBytes());

      setState(() {
        _imageFile = localImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBarMessage(
        'Failed to take picture. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _uploadPicture() async {
    setState(() {
      _isCamera = false;
      _isLoading = true;
      _isGallery = true;
    });

    try {
      if (Platform.isAndroid) {
        final PermissionStatus cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog('Camera');
          setState(() => _isLoading = false);
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final String secureFilePath = path.join(appDir.path, fileName);

      final File localImage = File(secureFilePath);
      await localImage.writeAsBytes(await image.readAsBytes());

      setState(() {
        _imageFile = localImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBarMessage(
        'Failed to upload picture. Please try again.',
        isError: true,
      );
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: TitleLargeText('$permissionType Permission Required'),
            content: BodyMediumText(
              'Please enable $permissionType access in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: LabelLargeText(
                  'Cancel',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const LabelLargeText('Open Settings'),
              ),
            ],
          ),
    );
  }

  void _showSnackBarMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BodyMediumText(message),
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
        'Failed to share result. Please try again.',
        isError: true,
      );
    }
  }

  void _showResultDialog(bool isTablet, String result) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                    'Math Solution',
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
                  if (_imageFile != null) ...[
                    Container(
                      height: isTablet ? 300 : 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: _spacing4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.all(_spacing4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: MathMarkdownWidget(data: result),
                  ),
                  const SizedBox(height: _spacing4),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
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
                            'AI can make mistakes, so double check the solution!',
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
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: LabelLargeText(
                  'Close',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _shareResult(result, _imageFile);
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.share, size: 18),
                label: const LabelLargeText('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBarWidget(title: 'Solve Math Problem'),
      body: BlocListener<SolveMathCubit, SolveMathState>(
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
              'Error solving math problem. Please try again.',
              isError: true,
            );
          }
        },
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
                            'AI-Powered Math Solver',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 8),
                          BodyLargeText(
                            'Capture or type any math problem and get instant solutions with step-by-step explanations',
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
        tabs: const [
          Tab(icon: Icon(Icons.camera_alt_outlined), text: 'Photo', height: 60),
          Tab(icon: Icon(Icons.edit_outlined), text: 'Text', height: 60),
        ],
      ),
    );
  }

  Widget _buildPhotoTab(
    BuildContext context,
    SolveMathState state,
    bool isTablet,
  ) {
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
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.file(
                      _imageFile!,
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
                        'No image selected',
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      BodyMediumText(
                        'Capture or upload a math problem',
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),

                // Loading overlay
                if (_isLoading || state.isIdentifying)
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
                                ? 'Analyzing problem...'
                                : 'Processing image...',
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
          _buildActionButtons(isTablet, state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet, SolveMathState state) {
    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt,
                label:
                    _isCamera && _imageFile != null && state.result.isEmpty
                        ? 'Solve Problem'
                        : 'Take Photo',
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (_isCamera &&
                              _imageFile != null &&
                              state.result.isEmpty) {
                            await _handleSubscriptionAndSolve(
                              imageFile: _imageFile,
                            );
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            await _takePicture();
                          }
                        },
                isPrimary:
                    _isCamera && _imageFile != null && state.result.isEmpty,
                isLoading: _isLoading && _isCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.photo_library,
                label:
                    _isGallery && _imageFile != null && state.result.isEmpty
                        ? 'Solve Problem'
                        : 'Upload Photo',
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (_isGallery &&
                              _imageFile != null &&
                              state.result.isEmpty) {
                            await _handleSubscriptionAndSolve(
                              imageFile: _imageFile,
                            );
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            setState(() => _imageFile = null);
                            await _uploadPicture();
                          }
                        },
                isPrimary:
                    _isGallery && _imageFile != null && state.result.isEmpty,
                isLoading: _isLoading && _isGallery,
              ),
            ),
          ],
        ),

        // Reset Button
        if ((_isGallery || _isCamera) &&
            _imageFile != null &&
            state.result.isEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              icon: Icons.refresh,
              label: 'Reset',
              onPressed: () {
                setState(() {
                  _imageFile = null;
                  _isLoading = false;
                  _isCamera = false;
                  _isGallery = false;
                });
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
        label: LabelLargeText(label),
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
        label: LabelLargeText(label),
        style: OutlinedButton.styleFrom(
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
        label: LabelLargeText(label),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
                      'Type your math problem',
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
                        'Enter your math problem here...\n\nExample:\n2x + 5 = 15\nSolve for x',
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
                                  'Please enter a math problem to solve.',
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
                      state.isIdentifying ? 'Solving...' : 'Solve Problem',
                      fontWeight: FontWeight.w600,
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
              color: Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    TitleSmallText(
                      'Tips for better results',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  'Be specific with your question (e.g., "Solve for x")',
                  'Use proper mathematical notation',
                  'Include all necessary information',
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
                            color: Theme.of(context).colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: BodySmallText(
                            tip,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
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
