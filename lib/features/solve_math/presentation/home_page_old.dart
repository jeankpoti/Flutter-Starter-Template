import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/body_small_text_widget.dart';
import '../../../common_widgets/elevated_button_widget.dart';
import '../../../common_widgets/glitch_widget.dart';
import '../../../common_widgets/loader_widget.dart';
import '../../../common_widgets/scan_effect_loader_widget.dart';
import '../../../utils/responsive.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import 'solve_math_cubit.dart';
import 'solve_math_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false, _isCamera = false, _isGallery = false;

  Future<void> _takePicture() async {
    setState(() {
      _isGallery = false;
      _isLoading = true;
      _isCamera = true;
    });

    try {
      // Request camera permission
      if (Platform.isAndroid) {
        final PermissionStatus photosStatus = await Permission.photos.request();

        if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog('Photo Library');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Take the picture
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85, // Adjust quality for size/bandwidth concerns
      );

      if (photo == null) {
        // User canceled the picker
        setState(() => _isLoading = false);
        return;
      }

      // Create secure local path to save the image
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final String secureFilePath = path.join(appDir.path, fileName);

      // Copy the image to the secure location
      final File localImage = File(secureFilePath);
      await localImage.writeAsBytes(await photo.readAsBytes());

      setState(() {
        _imageFile = localImage;
        _isLoading = false;
      });

      // Here you would typically process the image for animal identification
      // processImage(_imageFile);
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
      // Request photo library permission
      if (Platform.isAndroid) {
        final PermissionStatus cameraStatus = await Permission.camera.request();

        if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog('Camera');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Pick from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) {
        // User canceled the picker
        setState(() => _isLoading = false);
        return;
      }

      // Create secure local path
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final String secureFilePath = path.join(appDir.path, fileName);

      // Copy the image to secure location
      final File localImage = File(secureFilePath);
      await localImage.writeAsBytes(await image.readAsBytes());

      setState(() {
        _imageFile = localImage;
        _isLoading = false;
      });

      // Process the image
      // processImage(_imageFile);
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

  Future<void> _shareIdentificationResult(
    String result,
    File? imageFile,
  ) async {
    try {
      context.read<SolveMathCubit>().shareResult(imageFile!, result);
    } catch (e) {
      _showErrorDialog('Failed to share');
    }
  }

  void _showIdentificationResultDialog(bool isTablet) {
    final state = context.read<SolveMathCubit>().state;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Animal Identification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_imageFile != null)
                    Container(
                      height: isTablet ? 600 : 200,

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
                  MarkdownBody(
                    data: state.result,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      p: Theme.of(context).textTheme.bodyMedium,
                      h1: Theme.of(context).textTheme.titleLarge,
                      h2: Theme.of(context).textTheme.titleMedium,
                      h3: Theme.of(context).textTheme.titleSmall,
                      listBullet: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 45),
                  Center(
                    child: BodySmallTextWidget(
                      text:
                          'Snap Animal AI can make mistakes, so double check it!',
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
                  _shareIdentificationResult(state.result, _imageFile);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Share'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 5,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBarWidget(title: 'Identify Animal'),
      body: BlocListener<SolveMathCubit, SolveMathState>(
        listenWhen:
            (previous, current) =>
                current.result.isNotEmpty &&
                current.result != '' &&
                !current.isIdentifying,

        // current.result != previous.result,
        // previous.isIdentifying != current.isIdentifying ||
        // previous.isError != current.isError ||
        // (current.isSuccess && !previous.isSuccess),
        listener: (context, state) {
          if (state.result.isNotEmpty &&
              state.result != '' &&
              !state.isIdentifying) {
            _showIdentificationResultDialog(isTablet);
          }
          if (state.isError) {
            _showErrorDialog('Error identifying animal');
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: isTablet ? double.infinity : 350,
                              height: isTablet ? 600 : 300,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                      0,
                                      3,
                                    ), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                                  // _isLoading || state.isIdentifying
                                  //     ? Center(
                                  //       child: ModernScanEffectLoader(
                                  //         size: 200, // Adjust size as needed
                                  //         // color:
                                  //         //     Theme.of(
                                  //         //       context,
                                  //         //     ).colorScheme.secondary,
                                  //         duration: const Duration(
                                  //           milliseconds: 1500,
                                  //         ),
                                  //       ),
                                  //       // LoaderWidget(),
                                  //     )
                                  _imageFile != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          _imageFile!,
                                          width:
                                              isTablet ? double.infinity : 300,
                                          height: isTablet ? 600 : 300,
                                          fit: BoxFit.cover,
                                          color:
                                              _isLoading || state.isIdentifying
                                                  ? Colors.red
                                                  : Colors.transparent,
                                          colorBlendMode: BlendMode.overlay,
                                        ),

                                        // GlitchImageWidget(
                                        //   imagePath: _imageFile!,
                                        //   width:
                                        //       isTablet ? double.infinity : 300,
                                        //   height: isTablet ? 600 : 300,
                                        //   // fit: BoxFit.cover,
                                        // ),
                                      )
                                      : Icon(
                                        CupertinoIcons.photo_camera,
                                        size: isTablet ? 500 : 250,
                                        color: Colors.black,
                                      ),
                            ),
                            _isLoading || state.isIdentifying
                                ? Center(
                                  child: ModernScanEffectLoader(
                                    size:
                                        isTablet
                                            ? 500
                                            : 250, // Adjust size as needed
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                  ),
                                )
                                : SizedBox.shrink(),
                          ],
                        ),
                        SizedBox(height: isTablet ? 90 : 45),
                        // Take a picture button
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SizedBox(
                              width: isTablet ? 600 : 350,
                              child: ElevatedButtonWidget(
                                text:
                                    _isCamera &&
                                            _imageFile != null &&
                                            state.result.isEmpty
                                        ? 'Identify Animal'
                                        : 'Take a picture',
                                onPressed: () async {
                                  if (_isLoading) {
                                    return;
                                  } else {
                                    if (_isCamera &&
                                        _imageFile != null &&
                                        state.result.isEmpty) {
                                      // Check subscription status first
                                      final subscriptionCubit =
                                          context.read<SubscriptionCubit>();
                                      await subscriptionCubit
                                          .loadSubscriptionStatus();
                                      final isSubscribed =
                                          subscriptionCubit.state.isSubscribed;

                                      if (!isSubscribed) {
                                        // Show paywall if not subscribed
                                        try {
                                          await RevenueCatUI.presentPaywall();
                                          // After paywall is dismissed, check subscription status again
                                          await subscriptionCubit
                                              .loadSubscriptionStatus();
                                          final newStatus =
                                              subscriptionCubit
                                                  .state
                                                  .isSubscribed;

                                          if (newStatus) {
                                            // User subscribed, proceed with identification
                                            if (mounted) {
                                              context
                                                  .read<SolveMathCubit>()
                                                  .solveMath(_imageFile);
                                            }
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error showing subscription options: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        // Already subscribed, proceed with identification
                                        context
                                            .read<SolveMathCubit>()
                                            .solveMath(_imageFile);
                                      }
                                    } else {
                                      context
                                          .read<SolveMathCubit>()
                                          .emptyResult();
                                      // This is the 'Take a picture' button - no subscription check needed
                                      _takePicture();
                                    }
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                CupertinoIcons.star_circle_fill,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        BodyMediumTextWidget(text: 'Or'),

                        const SizedBox(height: 20),
                        // Upload a picture button
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SizedBox(
                              width: isTablet ? 600 : 350,
                              child: ElevatedButtonWidget(
                                text:
                                    _isGallery &&
                                            _imageFile != null &&
                                            state.result.isEmpty
                                        ? 'Identify Animal'
                                        : 'Upload a picture',
                                onPressed: () async {
                                  if (_isLoading) {
                                    return;
                                  } else {
                                    if (_isGallery &&
                                        _imageFile != null &&
                                        state.result.isEmpty) {
                                      // Check subscription status first
                                      final subscriptionCubit =
                                          context.read<SubscriptionCubit>();
                                      await subscriptionCubit
                                          .loadSubscriptionStatus();
                                      final isSubscribed =
                                          subscriptionCubit.state.isSubscribed;

                                      if (!isSubscribed) {
                                        // Show paywall if not subscribed
                                        try {
                                          await RevenueCatUI.presentPaywall();
                                          // After paywall is dismissed, check subscription status again
                                          await subscriptionCubit
                                              .loadSubscriptionStatus();
                                          final newStatus =
                                              subscriptionCubit
                                                  .state
                                                  .isSubscribed;

                                          if (newStatus) {
                                            // User subscribed, proceed with identification
                                            if (mounted) {
                                              context
                                                  .read<SolveMathCubit>()
                                                  .solveMath(_imageFile);
                                            }
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error showing subscription options: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        context
                                            .read<SolveMathCubit>()
                                            .emptyResult();
                                        // Already subscribed, proceed with identification
                                        context
                                            .read<SolveMathCubit>()
                                            .solveMath(_imageFile);
                                      }
                                    } else {
                                      context
                                          .read<SolveMathCubit>()
                                          .emptyResult();
                                      _imageFile = null;
                                      _uploadPicture();
                                    }
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                CupertinoIcons.star_circle_fill,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 90 : 45),
                        _isGallery &&
                                    _imageFile != null &&
                                    state.result.isEmpty ||
                                _isCamera &&
                                    _imageFile != null &&
                                    state.result.isEmpty
                            ? SizedBox(
                              width: isTablet ? 600 : 350,
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
                            )
                            : const SizedBox.shrink(),
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
}
