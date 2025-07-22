import 'package:flutter/material.dart';
import 'common_widgets/math_level_onboarding_dialog.dart';
import 'features/settings/data/preferences_service.dart';
import 'main_page.dart';

class MainPageWrapper extends StatefulWidget {
  const MainPageWrapper({super.key});

  @override
  State<MainPageWrapper> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState extends State<MainPageWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await PreferencesService.getInstance();
    final isFirstTime = prefs.isFirstTime();
    
    setState(() {
      _isLoading = false;
    });
    
    if (isFirstTime && mounted) {
      // Show the dialog after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMathLevelOnboarding();
      });
    }
  }

  void _showMathLevelOnboarding() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MathLevelOnboardingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const MainPage();
  }
}