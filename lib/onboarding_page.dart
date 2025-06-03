import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/title_large_text_widget.dart';
import 'main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Identify Any Animal',
      description:
          'Take a photo or upload an image to instantly identify animals with our advanced AI technology',
      animationAsset: 'assets/images/fox2.png',
      backgroundColor: Colors.black,
      textColor: Colors.white,
    ),
    OnboardingItem(
      title: 'Learn Fascinating Facts',
      description:
          'Discover interesting facts about animals, their habitats, and behaviors',
      animationAsset: 'assets/images/facts.png',
      // animationAsset: 'assets/animations/animal_facts.json',
      backgroundColor: Colors.white,
      textColor: Colors.black,
    ),
    OnboardingItem(
      title: 'Test Your Knowledge',
      description:
          'Challenge yourself with fun quizzes and become an animal expert',
      animationAsset: 'assets/images/quiz.png',
      // animationAsset: 'assets/animations/animal_quiz.json',
      backgroundColor: Colors.white,
      textColor: Colors.black,
    ),
    // OnboardingItem(
    //   title: 'Unlock Premium Features',
    //   description:
    //       'Subscribe to access unlimited identifications, remove ads, and get exclusive content',
    //   animationAsset: 'assets/images/fox.png',

    //   // animationAsset: 'assets/animations/premium_features.json',
    //   backgroundColor: Colors.white,
    //   textColor: Colors.black,
    //   isPremium: true,
    // ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToNextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSubscriptionPage();
    }
  }

  void _navigateToSubscriptionPage() async {
    try {
      // Set the onboarding completion flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      // Show the RevenueCat paywall
      // await RevenueCatUI.presentPaywall();

      // After the paywall is dismissed, navigate to the main app page
      if (mounted) {
        context.goNamed(AppRoute.signUpPage.name);
      }
    } catch (e) {
      // If there's an error, show a message and still proceed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error showing subscription options: ${e.toString()}',
            ),
          ),
        );
        context.goNamed(AppRoute.signUpPage.name);
      }
    }
  }

  // void _navigateToSubscriptionPage() {
  //   Navigator.of(
  //     context,
  //   ).push(MaterialPageRoute(builder: (context) => const SubscriptionPage()));
  // }

  // void _skipOnboarding() {
  //   context.goNamed(AppRoute.mainPage.name);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingItems.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingItems[index]);
            },
          ),
          // Skip button at the top right
          if (_currentPage < _onboardingItems.length - 1)
            Positioned(
              top: 20,
              right: 10,
              child: TextButton(
                onPressed: _navigateToSubscriptionPage,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _onboardingItems.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Theme.of(context).colorScheme.secondary,
                    // _onboardingItems[_currentPage].textColor,
                    dotColor: Colors.black,
                    //  _onboardingItems[_currentPage].textColor
                    // .withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _navigateToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      //     _onboardingItems[_currentPage].backgroundColor ==
                      //             Colors.black
                      //         ? Colors.white
                      //         : Colors.black,
                      // foregroundColor:
                      //     _onboardingItems[_currentPage].backgroundColor ==
                      //             Colors.black
                      //         ? Colors.black
                      //         : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: BodyMediumTextWidget(
                      text:
                          _currentPage < _onboardingItems.length - 1
                              ? 'Next'
                              : 'Get Started',
                      color: Colors.white,
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

  Widget _buildOnboardingPage(OnboardingItem item) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.6; // 60% of screen height

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Full-width image at the top
          SizedBox(
            width: double.infinity,
            height: imageHeight,
            child: Image.asset(item.animationAsset, fit: BoxFit.cover),
          ),

          // Content below image
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleLargeTextWidget(text: item.title),
                  const SizedBox(height: 15),
                  BodyMediumTextWidget(
                    text: item.description,
                    textAlign: TextAlign.center,
                  ),
                  // if (item.isPremium) ...[
                  //   const SizedBox(height: 24),
                  //   _buildPremiumFeaturesList(item.textColor),
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturesList(Color textColor) {
    return Column(
      children: [
        Text(
          'Premium Benefits:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          Icons.check_circle,
          'Unlimited animal identifications',
          textColor,
        ),
        _buildFeatureItem(Icons.check_circle, 'No advertisements', textColor),
        _buildFeatureItem(
          Icons.check_circle,
          'Exclusive animal facts and content',
          textColor,
        ),
        _buildFeatureItem(
          Icons.check_circle,
          'Advanced quiz challenges',
          textColor,
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontFamily: 'Merriweather',
            ),
            children: const [
              TextSpan(text: 'Start with a '),
              TextSpan(
                text: '3-day free trial',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: textColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String animationAsset;
  final Color backgroundColor;
  final Color textColor;
  final bool isPremium;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.animationAsset,
    required this.backgroundColor,
    required this.textColor,
    this.isPremium = false,
  });
}
