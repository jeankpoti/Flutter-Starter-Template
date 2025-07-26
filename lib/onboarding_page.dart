import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main.dart';
import 'common_widgets/text_widgets.dart';

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
      title: 'Your Personal AI Math Tutor',
      subtitle: 'Solve any math problem instantly',
      description:
          'Take a photo of math problems and get step-by-step solutions powered by Google Gemini AI. From basic arithmetic to advanced calculus.',
      animationAsset: 'assets/images/fox2.png',
      icon: FontAwesomeIcons.camera,
      features: [
        FeatureItem(
          icon: FontAwesomeIcons.camera,
          title: 'Photo Recognition',
          description: 'Snap any math problem',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.robot,
          title: 'AI-Powered',
          description: 'Google Gemini 2.5 Flash',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.listOl,
          title: 'Step-by-Step',
          description: 'Detailed explanations',
        ),
      ],
    ),
    OnboardingItem(
      title: 'Smart Study Materials',
      subtitle: 'Organize & analyze your content',
      description:
          'Upload study materials and let AI extract key topics, assess difficulty, and create personalized learning paths just for you.',
      animationAsset: 'assets/images/facts.png',
      icon: FontAwesomeIcons.bookOpen,
      features: [
        FeatureItem(
          icon: FontAwesomeIcons.upload,
          title: 'Easy Upload',
          description: 'Images, PDFs, notes',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.brain,
          title: 'AI Analysis',
          description: 'Auto topic extraction',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.chartLine,
          title: 'Progress Tracking',
          description: 'Monitor improvement',
        ),
      ],
    ),
    OnboardingItem(
      title: 'AI-Generated Quizzes',
      subtitle: 'Test your knowledge effectively',
      description:
          'Generate personalized quizzes from your study materials. Track performance, identify weak spots, and improve faster.',
      animationAsset: 'assets/images/quiz.png',
      icon: FontAwesomeIcons.graduationCap,
      features: [
        FeatureItem(
          icon: FontAwesomeIcons.circleQuestion,
          title: 'Smart Questions',
          description: 'AI creates relevant tests',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.chartBar,
          title: 'Performance Analytics',
          description: 'Detailed progress insights',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.bullseye,
          title: 'Adaptive Learning',
          description: 'Questions match your level',
        ),
      ],
    ),
    OnboardingItem(
      title: 'Unlock Your Math Potential',
      subtitle: 'Premium features await',
      description:
          'Join thousands of students who improved their math skills with unlimited AI tutoring, advanced features, and personalized learning.',
      animationAsset: 'assets/images/fox.png',
      icon: FontAwesomeIcons.crown,
      isPremium: true,
      features: [
        FeatureItem(
          icon: FontAwesomeIcons.infinity,
          title: 'Unlimited Problems',
          description: 'Solve as many as you need',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.cloud,
          title: 'Cloud Sync',
          description: 'Access anywhere, anytime',
        ),
        FeatureItem(
          icon: FontAwesomeIcons.chartLine,
          title: 'Advanced Analytics',
          description: 'Detailed learning insights',
        ),
      ],
      premiumBenefits: [
        'Unlimited math problem solving',
        'AI-generated quizzes from your materials',
        'Advanced study material organization',
        'Detailed performance analytics and insights',
        'Cross-device synchronization',
        'Priority customer support',
        'Ad-free experience',
      ],
    ),
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
            content: BodyMediumText(
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
              top: 60,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _navigateToSubscriptionPage,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: LabelMediumText(
                    'Skip',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingItems.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      activeDotColor: Theme.of(context).colorScheme.secondary,
                      dotColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == _onboardingItems.length - 1
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      elevation: _currentPage == _onboardingItems.length - 1 ? 8 : 2,
                      shadowColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage == _onboardingItems.length - 1) ...[
                          Icon(
                            FontAwesomeIcons.crown,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        TitleMediumText(
                          _currentPage < _onboardingItems.length - 1
                              ? 'Continue'
                              : 'Start Free Trial',
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        if (_currentPage < _onboardingItems.length - 1) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Secondary Button for Premium Page
                if (_currentPage == _onboardingItems.length - 1) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () async {
                        if (!mounted) return;
                        final currentContext = context;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasSeenOnboarding', true);
                        if (mounted) {
                          currentContext.goNamed(AppRoute.signUpPage.name);
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: BodyLargeText(
                        'Continue with Free Version',
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {

    return Container(
      decoration: BoxDecoration(
        gradient: item.isPremium
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ],
              )
            : null,
        color: item.isPremium ? null : Theme.of(context).colorScheme.surface,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Section
              _buildHeroSection(item),
              
              const SizedBox(height: 32),
              
              // Features Grid
              if (item.features.isNotEmpty) ...[
                _buildFeaturesGrid(item.features),
                const SizedBox(height: 32),
              ],
              
              // Premium Benefits List
              if (item.isPremium && item.premiumBenefits != null) ...[
                _buildPremiumBenefitsList(item.premiumBenefits!),
                const SizedBox(height: 24),
              ],
              
              // Social Proof for Premium
              if (item.isPremium) ...[
                _buildSocialProof(),
                const SizedBox(height: 32),
              ],
              
              // Bottom spacing for navigation
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeroSection(OnboardingItem item) {
    return Column(
      children: [
        // Icon/Image Section
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: item.isPremium 
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            item.icon,
            size: 48,
            color: item.isPremium 
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        HeadlineMediumText(
          item.title,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        TitleMediumText(
          item.subtitle,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Description
        BodyLargeText(
          item.description,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildFeaturesGrid(List<FeatureItem> features) {
    return Column(
      children: features.map((feature) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleSmallText(
                    feature.title,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  BodyMediumText(
                    feature.description,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  
  Widget _buildPremiumBenefitsList(List<String> benefits) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.crown,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              TitleMediumText(
                'Premium Benefits',
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BodyMediumText(
                    benefit,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildSocialProof() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            )),
          ),
          
          const SizedBox(height: 8),
          
          TitleSmallText(
            '10,000+ students improved their math grades',
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          BodyMediumText(
            '"This app helped me understand calculus for the first time!"',
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final String animationAsset;
  final IconData icon;
  final bool isPremium;
  final List<FeatureItem> features;
  final List<String>? premiumBenefits;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.animationAsset,
    required this.icon,
    this.isPremium = false,
    this.features = const [],
    this.premiumBenefits,
  });
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
