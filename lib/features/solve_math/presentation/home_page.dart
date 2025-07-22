import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/body_small_text_widget.dart';
import '../../../common_widgets/elevated_button_widget.dart';
import '../../../common_widgets/math_markdown_widget.dart';
import '../../../common_widgets/math_symbols_widget.dart';
import '../../../common_widgets/scan_effect_loader_widget.dart';
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
    context.read<SolveMathCubit>().solveMath(imageFile);
    context.read<SolveMathCubit>().solveMath(textInput);

    final subscriptionCubit = context.read<SubscriptionCubit>();
    await subscriptionCubit.loadSubscriptionStatus();
    final isSubscribed = subscriptionCubit.state.isSubscribed;

    if (!isSubscribed) {
      try {
        await RevenueCatUI.presentPaywall();
        await subscriptionCubit.loadSubscriptionStatus();
        final newStatus = subscriptionCubit.state.isSubscribed;

        if (newStatus && mounted) {
          if (imageFile != null) {
            context.read<SolveMathCubit>().solveMath(imageFile);
          } else if (textInput != null) {
            context.read<SolveMathCubit>().solveMath(textInput);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error showing subscription options: $e')),
          );
        }
      }
    } else if (mounted) {
      if (imageFile != null) {
        context.read<SolveMathCubit>().solveMath(imageFile);
      } else if (textInput != null) {
        context.read<SolveMathCubit>().solveMath(textInput);
      }
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
      _showErrorDialog('Failed to take picture: ${e.toString()}');
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
      _showErrorDialog('Failed to upload picture: ${e.toString()}');
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('$permissionType Permission Denied'),
            content: Text(
              'Please enable $permissionType access in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _shareResult(String result, File? imageFile) async {
    try {
      context.read<SolveMathCubit>().shareResult(imageFile!, result);
    } catch (e) {
      _showErrorDialog('Failed to share');
    }
  }

  void _showResultDialog(bool isTablet) {
    final state = context.read<SolveMathCubit>().state;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Math Solution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_imageFile != null)
                    Container(
                      height: isTablet ? 300 : 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  MathMarkdownWidget(data: state.result),
                  const SizedBox(height: 16),
                  Center(
                    child: BodySmallTextWidget(
                      text:
                          'AI can make mistakes, so double check the solution!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  _shareResult(state.result, _imageFile);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Share'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 5,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
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
            // Refresh collections after solving a problem
            context.read<FirebaseCollectionCubit>().getCollections(
              isRefresh: true,
            );
            _showResultDialog(isTablet);
          }
          if (state.isError) {
            _showErrorDialog('Error solving math problem');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: BlocBuilder<SolveMathCubit, SolveMathState>(
              builder: (context, state) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tab Bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            labelColor: Theme.of(context).colorScheme.onPrimary,
                            unselectedLabelColor:
                                Theme.of(context).colorScheme.onSurface,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(icon: Icon(Icons.camera_alt), text: 'Photo'),
                              Tab(icon: Icon(Icons.edit), text: 'Text'),
                            ],
                          ),
                        ),
                        // Tab Bar View
                        SizedBox(
                          height: isTablet ? 700 : 600,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPhotoTab(context, state, isTablet),
                              _buildTextTab(context, state, isTablet),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: isTablet ? 400 : 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _imageFile!,
                            width: isTablet ? double.infinity : 300,
                            height: isTablet ? 400 : 300,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Icon(
                          Icons.calculate_outlined,
                          size: isTablet ? 200 : 150,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
              ),
              if (_isLoading || state.isIdentifying)
                ModernScanEffectLoader(
                  size: isTablet ? 300 : 200,
                  duration: const Duration(milliseconds: 1000),
                ),
            ],
          ),
          SizedBox(height: isTablet ? 40 : 30),
          // Take a picture button
          SizedBox(
            width: isTablet ? 400 : 300,
            child: ElevatedButtonWidget(
              text:
                  _isCamera && _imageFile != null && state.result.isEmpty
                      ? 'Solve Math Problem'
                      : 'Take a picture',
              onPressed: () async {
                if (_isLoading) return;

                if (_isCamera && _imageFile != null && state.result.isEmpty) {
                  await _handleSubscriptionAndSolve(imageFile: _imageFile);
                } else {
                  context.read<SolveMathCubit>().emptyResult();
                  _takePicture();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          BodyMediumTextWidget(text: 'Or'),
          const SizedBox(height: 16),
          // Upload a picture button
          SizedBox(
            width: isTablet ? 400 : 300,
            child: ElevatedButtonWidget(
              text:
                  _isGallery && _imageFile != null && state.result.isEmpty
                      ? 'Solve Math Problem'
                      : 'Upload a picture',
              onPressed: () async {
                if (_isLoading) return;

                if (_isGallery && _imageFile != null && state.result.isEmpty) {
                  await _handleSubscriptionAndSolve(imageFile: _imageFile);
                } else {
                  context.read<SolveMathCubit>().emptyResult();
                  _imageFile = null;
                  _uploadPicture();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Reset button
          if ((_isGallery && _imageFile != null && state.result.isEmpty) ||
              (_isCamera && _imageFile != null && state.result.isEmpty))
            SizedBox(
              width: isTablet ? 400 : 300,
              child: ElevatedButtonWidget(
                text: 'Reset',
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _isLoading = false;
                    _isCamera = false;
                    _isGallery = false;
                  });
                  context.read<SolveMathCubit>().emptyResult();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextTab(
    BuildContext context,
    SolveMathState state,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isTablet ? 600 : 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type your math question:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Enter your math problem here...\ne.g., Solve for x: 2x + 5 = 15',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MathSymbolsWidget(controller: _textController),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButtonWidget(
                        text: 'Solve Math Problem',
                        onPressed: () async {
                          if (_textController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter a math problem to solve.',
                                ),
                              ),
                            );
                            return;
                          }

                          await _handleSubscriptionAndSolve(
                            textInput: _textController.text.trim(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Loading overlay
              if (state.isIdentifying)
                Container(
                  width: isTablet ? 600 : 350,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ModernScanEffectLoader(
                          size: 80,
                          duration: const Duration(milliseconds: 1000),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Solving your math problem...',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
