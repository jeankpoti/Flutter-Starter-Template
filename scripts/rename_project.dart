// ignore_for_file: avoid_print

import 'dart:io';

/// Flutter Project Rename Script
///
/// Usage:
/// ```bash
/// dart run scripts/rename_project.dart \
///   --package-name=new_app \
///   --app-name="New App Name" \
///   --bundle-id=com.company.newapp \
///   --dry-run
/// ```

void main(List<String> args) {
  final config = _parseArguments(args);

  if (config == null) {
    _printUsage();
    exit(1);
  }

  print('');
  print('='.padRight(60, '='));
  print('Flutter Project Rename Script');
  print('='.padRight(60, '='));
  print('');
  print('New Package Name: ${config.packageName}');
  print('New App Name:     ${config.appName}');
  print('New Bundle ID:    ${config.bundleId}');
  print('Dry Run:          ${config.dryRun}');
  print('');

  final renamer = ProjectRenamer(config);
  renamer.run();
}

class RenameConfig {
  final String packageName;
  final String appName;
  final String bundleId;
  final bool dryRun;

  RenameConfig({
    required this.packageName,
    required this.appName,
    required this.bundleId,
    required this.dryRun,
  });
}

RenameConfig? _parseArguments(List<String> args) {
  String? packageName;
  String? appName;
  String? bundleId;
  bool dryRun = false;

  for (final arg in args) {
    if (arg.startsWith('--package-name=')) {
      packageName = arg.substring('--package-name='.length);
    } else if (arg.startsWith('--app-name=')) {
      appName = arg.substring('--app-name='.length);
    } else if (arg.startsWith('--bundle-id=')) {
      bundleId = arg.substring('--bundle-id='.length);
    } else if (arg == '--dry-run') {
      dryRun = true;
    } else if (arg == '--help' || arg == '-h') {
      return null;
    }
  }

  if (packageName == null || appName == null || bundleId == null) {
    print('Error: Missing required arguments');
    return null;
  }

  // Validate package name (lowercase, underscores, no special chars)
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(packageName)) {
    print('Error: Invalid package name "$packageName"');
    print('Package name must be lowercase, start with a letter, ');
    print('and contain only letters, numbers, and underscores.');
    return null;
  }

  // Validate bundle ID format
  if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$', caseSensitive: false)
      .hasMatch(bundleId)) {
    print('Error: Invalid bundle ID "$bundleId"');
    print('Bundle ID must be in format: com.company.appname');
    return null;
  }

  return RenameConfig(
    packageName: packageName,
    appName: appName,
    bundleId: bundleId,
    dryRun: dryRun,
  );
}

void _printUsage() {
  print('''
Usage: dart run scripts/rename_project.dart [options]

Required options:
  --package-name=NAME    New Dart package name (snake_case)
                         Example: my_new_app

  --app-name=NAME        New app display name
                         Example: "My New App"

  --bundle-id=ID         New bundle identifier
                         Example: com.mycompany.mynewapp

Optional flags:
  --dry-run              Preview changes without modifying files
  --help, -h             Show this help message

Example:
  dart run scripts/rename_project.dart \\
    --package-name=my_app \\
    --app-name="My App" \\
    --bundle-id=com.mycompany.myapp

  dart run scripts/rename_project.dart \\
    --package-name=my_app \\
    --app-name="My App" \\
    --bundle-id=com.mycompany.myapp \\
    --dry-run
''');
}

class ProjectRenamer {
  final RenameConfig config;
  final String projectRoot;

  // Current values (detected from project)
  late String currentPackageName;
  late String currentBundleIdAndroid;
  late String currentBundleIdIos;

  ProjectRenamer(this.config)
      : projectRoot = Directory.current.path;

  void run() {
    _detectCurrentValues();

    print('Current Package Name:  $currentPackageName');
    print('Current Android ID:    $currentBundleIdAndroid');
    print('Current iOS Bundle ID: $currentBundleIdIos');
    print('');

    if (config.dryRun) {
      print('[DRY RUN MODE - No files will be modified]');
      print('');
    }

    _updatePubspec();
    _updateAndroidBuildGradle();
    _updateAndroidManifest();
    _updateAndroidStrings();
    _updateAndroidKotlin();
    _updateIosInfoPlist();
    _updateIosProjectPbxproj();
    _updateMacosProjectPbxproj();
    _updateDartImports();
    _updateHardcodedAppIds();
    _clearFirebaseConfig();

    print('');
    print('='.padRight(60, '='));
    if (config.dryRun) {
      print('DRY RUN COMPLETE - No files were modified');
    } else {
      print('RENAME COMPLETE');
    }
    print('='.padRight(60, '='));
    print('');

    if (!config.dryRun) {
      _printPostRenameInstructions();
    }
  }

  void _detectCurrentValues() {
    // Read current package name from pubspec.yaml
    final pubspecFile = File('$projectRoot/pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true)
        .firstMatch(pubspecContent);
    currentPackageName = nameMatch?.group(1) ?? 'flutter_starter';

    // Read current Android application ID from build.gradle.kts
    final buildGradleFile =
        File('$projectRoot/android/app/build.gradle.kts');
    if (buildGradleFile.existsSync()) {
      final gradleContent = buildGradleFile.readAsStringSync();
      final appIdMatch =
          RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradleContent);
      currentBundleIdAndroid =
          appIdMatch?.group(1) ?? 'com.example.flutter_starter';
    } else {
      currentBundleIdAndroid = 'com.example.flutter_starter';
    }

    // Read current iOS bundle ID from project.pbxproj
    final pbxprojFile = File(
        '$projectRoot/ios/Runner.xcodeproj/project.pbxproj');
    if (pbxprojFile.existsSync()) {
      final pbxprojContent = pbxprojFile.readAsStringSync();
      final bundleIdMatch =
          RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);')
              .firstMatch(pbxprojContent);
      currentBundleIdIos =
          bundleIdMatch?.group(1)?.trim() ?? 'com.example.flutterStarter';
    } else {
      currentBundleIdIos = 'com.example.flutterStarter';
    }
  }

  void _updatePubspec() {
    final path = '$projectRoot/pubspec.yaml';
    _replaceInFile(
      path,
      RegExp(r'^name:\s*\S+', multiLine: true),
      'name: ${config.packageName}',
      'pubspec.yaml name field',
    );
  }

  void _updateAndroidBuildGradle() {
    final path = '$projectRoot/android/app/build.gradle.kts';
    _replaceInFile(
      path,
      RegExp(r'namespace\s*=\s*"[^"]+"'),
      'namespace = "${config.bundleId}"',
      'Android namespace',
    );
    _replaceInFile(
      path,
      RegExp(r'applicationId\s*=\s*"[^"]+"'),
      'applicationId = "${config.bundleId}"',
      'Android applicationId',
    );
  }

  void _updateAndroidManifest() {
    final path = '$projectRoot/android/app/src/main/AndroidManifest.xml';
    _replaceInFile(
      path,
      RegExp(r'android:label="[^"]+"'),
      'android:label="${config.appName}"',
      'Android app label',
    );
  }

  void _updateAndroidStrings() {
    final path = '$projectRoot/android/app/src/main/res/values/strings.xml';
    _replaceInFile(
      path,
      RegExp(r'<string name="app_name">[^<]+</string>'),
      '<string name="app_name">${config.appName}</string>',
      'Android app_name string',
    );
  }

  void _updateAndroidKotlin() {
    // Find the current Kotlin directory
    final kotlinBaseDir =
        Directory('$projectRoot/android/app/src/main/kotlin');
    if (!kotlinBaseDir.existsSync()) {
      print('  [SKIP] Kotlin directory not found');
      return;
    }

    // Find MainActivity.kt
    final mainActivityFiles = kotlinBaseDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('MainActivity.kt'))
        .toList();

    if (mainActivityFiles.isEmpty) {
      print('  [SKIP] MainActivity.kt not found');
      return;
    }

    final mainActivityFile = mainActivityFiles.first;

    // Update package declaration in MainActivity.kt
    _replaceInFile(
      mainActivityFile.path,
      RegExp(r'^package\s+\S+', multiLine: true),
      'package ${config.bundleId}',
      'Kotlin package declaration',
    );

    // Move the Kotlin directory structure
    final newKotlinPath =
        '${kotlinBaseDir.path}/${config.bundleId.replaceAll('.', '/')}';
    final newKotlinDir = Directory(newKotlinPath);

    if (config.dryRun) {
      print(
          '  [DRY RUN] Would move Kotlin files to: $newKotlinPath');
    } else {
      // Create new directory structure
      newKotlinDir.createSync(recursive: true);

      // Move MainActivity.kt to new location
      final newMainActivityPath = '$newKotlinPath/MainActivity.kt';
      mainActivityFile.copySync(newMainActivityPath);

      // Remove old directory structure (find the top-level package dir)
      final oldPackageParts = currentBundleIdAndroid.split('.');
      if (oldPackageParts.isNotEmpty) {
        final oldTopDir =
            Directory('${kotlinBaseDir.path}/${oldPackageParts.first}');
        if (oldTopDir.existsSync() &&
            oldTopDir.path != newKotlinDir.path) {
          oldTopDir.deleteSync(recursive: true);
          print('  [OK] Moved Kotlin package structure');
        }
      }
    }
  }

  void _updateIosInfoPlist() {
    final path = '$projectRoot/ios/Runner/Info.plist';
    _replaceInPlist(
      path,
      'CFBundleDisplayName',
      config.appName,
      'iOS bundle display name',
    );
    _replaceInPlist(
      path,
      'CFBundleName',
      config.packageName,
      'iOS bundle name',
    );
  }

  void _updateIosProjectPbxproj() {
    final path = '$projectRoot/ios/Runner.xcodeproj/project.pbxproj';
    // Update main app bundle ID
    _replaceInFile(
      path,
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;'),
      'PRODUCT_BUNDLE_IDENTIFIER = ${config.bundleId};',
      'iOS bundle identifier',
      replaceAll: true,
    );
  }

  void _updateMacosProjectPbxproj() {
    final path = '$projectRoot/macos/Runner.xcodeproj/project.pbxproj';
    if (!File(path).existsSync()) {
      print('  [SKIP] macOS project not found');
      return;
    }
    _replaceInFile(
      path,
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;'),
      'PRODUCT_BUNDLE_IDENTIFIER = ${config.bundleId};',
      'macOS bundle identifier',
      replaceAll: true,
    );
  }

  void _updateDartImports() {
    final libDir = Directory('$projectRoot/lib');
    final testDir = Directory('$projectRoot/test');

    final dartFiles = <File>[
      ...libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
      if (testDir.existsSync())
        ...testDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
    ];

    int updatedCount = 0;
    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final newContent = content.replaceAll(
        'package:$currentPackageName/',
        'package:${config.packageName}/',
      );

      if (content != newContent) {
        updatedCount++;
        if (config.dryRun) {
          print('  [DRY RUN] Would update imports in: ${_relativePath(file.path)}');
        } else {
          file.writeAsStringSync(newContent);
        }
      }
    }

    if (updatedCount > 0) {
      print('  [OK] Updated imports in $updatedCount Dart files');
    } else {
      print('  [SKIP] No Dart imports to update');
    }
  }

  void _updateHardcodedAppIds() {
    final filesToUpdate = [
      '$projectRoot/lib/core/services/app_review_service.dart',
      '$projectRoot/lib/common_widgets/update_banner_widget.dart',
      '$projectRoot/lib/common_widgets/force_update_dialog.dart',
    ];

    for (final path in filesToUpdate) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }

      // Replace the old Android app ID with the new one
      _replaceInFile(
        path,
        RegExp(RegExp.escape(currentBundleIdAndroid)),
        config.bundleId,
        'Hardcoded app ID in ${_relativePath(path)}',
        replaceAll: true,
      );
    }
  }

  void _clearFirebaseConfig() {
    final firebaseFiles = [
      '$projectRoot/android/app/google-services.json',
      '$projectRoot/ios/Runner/GoogleService-Info.plist',
      '$projectRoot/macos/Runner/GoogleService-Info.plist',
      '$projectRoot/lib/firebase_options.dart',
    ];

    print('');
    print('Firebase Configuration:');

    for (final path in firebaseFiles) {
      final file = File(path);
      if (file.existsSync()) {
        if (config.dryRun) {
          print('  [DRY RUN] Would delete: ${_relativePath(path)}');
        } else {
          file.deleteSync();
          print('  [DELETED] ${_relativePath(path)}');
        }
      }
    }
  }

  void _replaceInFile(
    String path,
    Pattern pattern,
    String replacement,
    String description, {
    bool replaceAll = false,
  }) {
    final file = File(path);
    if (!file.existsSync()) {
      print('  [SKIP] File not found: ${_relativePath(path)}');
      return;
    }

    final content = file.readAsStringSync();
    final newContent = replaceAll
        ? content.replaceAll(pattern, replacement)
        : content.replaceFirst(pattern, replacement);

    if (content != newContent) {
      if (config.dryRun) {
        print('  [DRY RUN] Would update: $description');
      } else {
        file.writeAsStringSync(newContent);
        print('  [OK] Updated: $description');
      }
    } else {
      print('  [SKIP] No change needed: $description');
    }
  }

  void _replaceInPlist(
    String path,
    String key,
    String value,
    String description,
  ) {
    final file = File(path);
    if (!file.existsSync()) {
      print('  [SKIP] File not found: ${_relativePath(path)}');
      return;
    }

    final content = file.readAsStringSync();
    // Match the key followed by a string value on the next line
    final pattern = RegExp(
      '<key>$key</key>\\s*<string>[^<]*</string>',
    );
    final replacement = '<key>$key</key>\n\t<string>$value</string>';

    final newContent = content.replaceFirst(pattern, replacement);

    if (content != newContent) {
      if (config.dryRun) {
        print('  [DRY RUN] Would update: $description');
      } else {
        file.writeAsStringSync(newContent);
        print('  [OK] Updated: $description');
      }
    } else {
      print('  [SKIP] No change needed: $description');
    }
  }

  String _relativePath(String path) {
    return path.replaceFirst('$projectRoot/', '');
  }

  void _printPostRenameInstructions() {
    print('''
Next Steps:
-----------

1. Reconfigure Firebase (REQUIRED):
   flutterfire configure

2. Clean and rebuild:
   flutter clean
   flutter pub get

3. Verify the build:
   flutter analyze
   flutter build apk --debug
   flutter build ios --debug --no-codesign

4. Update external services (if applicable):
   - RevenueCat: Update app identifiers
   - AdMob: Update app IDs in AdMob console
   - App Store Connect / Google Play: Create new app entries

''');
  }
}
