import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:math_ai/common_widgets/app_snackbar_widget.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main.dart';
import 'common_widgets/text_widgets.dart';
import 'common_widgets/ai_demo_animation_widget.dart';
import 'l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingItem> _getOnboardingItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingItem(
        title: l10n.solveAnyMathProblemInstantly,
        subtitle: l10n.seeAiMagicInAction,
        description: l10n.aiDemoDescription,
        animationAsset: '',
        icon: FontAwesomeIcons.robot,
        showDemo: true,
      ),
      OnboardingItem(
        title: l10n.smartStudyMaterials,
        subtitle: l10n.organizeAnalyzeContent,
        description: l10n.uploadStudyDescription,
        animationAsset: '',
        icon: FontAwesomeIcons.bookOpen,
        features: [
          FeatureItem(
            icon: FontAwesomeIcons.upload,
            title: l10n.easyUpload,
            description: l10n.imagesNotesUpload,
          ),
          FeatureItem(
            icon: FontAwesomeIcons.brain,
            title: l10n.aiAnalysis,
            description: l10n.autoTopicExtraction,
          ),
          FeatureItem(
            icon: FontAwesomeIcons.chartLine,
            title: l10n.progressTracking,
            description: l10n.monitorImprovement,
          ),
        ],
      ),
      OnboardingItem(
        title: l10n.aiGeneratedQuizzes,
        subtitle: l10n.testKnowledgeEffectively,
        description: l10n.generatePersonalizedQuizzes,
        animationAsset: '',
        icon: FontAwesomeIcons.graduationCap,
        features: [
          FeatureItem(
            icon: FontAwesomeIcons.circleQuestion,
            title: l10n.smartQuestions,
            description: l10n.aiCreatesTests,
          ),
          FeatureItem(
            icon: FontAwesomeIcons.chartBar,
            title: l10n.performanceAnalytics,
            description: l10n.detailedProgressInsights,
          ),
          FeatureItem(
            icon: FontAwesomeIcons.bullseye,
            title: l10n.adaptiveLearning,
            description: l10n.questionsMatchLevel,
          ),
        ],
      ),
      OnboardingItem(
        title: l10n.unlockMathPotential,
        subtitle: l10n.premiumFeaturesAwait,
        description: l10n.joinThousandsStudents,
        animationAsset: '',
        icon: FontAwesomeIcons.crown,
        isPremium: true,
        features: [
          // FeatureItem(
          //   icon: FontAwesomeIcons.infinity,
          //   title: l10n.unlimitedProblems,
          //   description: l10n.solveAsMany,
          // ),
          // FeatureItem(
          //   icon: FontAwesomeIcons.cloud,
          //   title: l10n.cloudSync,
          //   description: l10n.accessAnywhere,
          // ),
          // FeatureItem(
          //   icon: FontAwesomeIcons.chartLine,
          //   title: l10n.advancedAnalytics,
          //   description: l10n.detailedLearningInsights,
          // ),
        ],
        premiumBenefits: [
          l10n.unlimitedMathProblemSolving,
          l10n.aiGeneratedQuizzesFromMaterials,
          l10n.advancedStudyOrganization,
          l10n.detailedPerformanceAnalytics,
          l10n.crossDeviceSynchronization,
          l10n.priorityCustomerSupport,
          l10n.adFreeExperience,
        ],
      ),
    ];
  }

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
    final items = _getOnboardingItems(context);
    if (_currentPage < items.length - 1) {
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
      await RevenueCatUI.presentPaywall();

      // After the paywall is dismissed, navigate to the main app page
      if (mounted) {
        context.goNamed(AppRoute.signUpPage.name);
      }
    } catch (e) {
      // If there's an error, show a message and still proceed
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Something went wrong. Please try again later.',
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
            itemCount: _getOnboardingItems(context).length,
            itemBuilder: (context, index) {
              final items = _getOnboardingItems(context);
              return _buildOnboardingPage(items[index]);
            },
          ),
          // Skip button at the top right
          if (_currentPage < _getOnboardingItems(context).length - 1)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _navigateToSubscriptionPage,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: LabelMediumText(
                    AppLocalizations.of(context)!.skip,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _getOnboardingItems(context).length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      activeDotColor: Theme.of(context).colorScheme.secondary,
                      dotColor: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
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
                      backgroundColor:
                          _currentPage ==
                                  _getOnboardingItems(context).length - 1
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      elevation:
                          _currentPage ==
                                  _getOnboardingItems(context).length - 1
                              ? 8
                              : 2,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage ==
                            _getOnboardingItems(context).length - 1) ...[
                          Icon(
                            FontAwesomeIcons.crown,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        TitleMediumText(
                          // _currentPage == 0
                          //     ? AppLocalizations.of(
                          //       context,
                          //     )!.tryYourFirstProblemFree
                          //     :
                          _currentPage < _getOnboardingItems(context).length - 1
                              ? AppLocalizations.of(context)!.continueText
                              : AppLocalizations.of(
                                context,
                              )!.tryYourFirstProblemFree,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        if (_currentPage <
                            _getOnboardingItems(context).length - 1) ...[
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
        gradient:
            item.isPremium
                ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    Theme.of(context).colorScheme.surface,
                    Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero Section
              _buildHeroSection(item),
              // AI Demo Animation (only for first page)
              if (item.showDemo) ...[
                const SizedBox(height: 16),
                const AIDemoAnimationWidget(),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 24),
              ],

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
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(OnboardingItem item) {
    return Column(
      children: [
        const SizedBox(height: 50),

        // Title
        TitleMediumText(
          item.title,
          color: Theme.of(context).colorScheme.onSurface,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeaturesGrid(List<FeatureItem> features) {
    return Column(
      children:
          features
              .map(
                (feature) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.05),
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
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.3),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
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
                AppLocalizations.of(context)!.premiumBenefits,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...benefits.map(
            (benefit) => Padding(
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProof() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(Icons.star, color: Colors.amber, size: 20),
            ),
          ),

          const SizedBox(height: 8),

          TitleSmallText(
            AppLocalizations.of(context)!.studentsImprovedGrades,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          BodyMediumText(
            AppLocalizations.of(context)!.testimonialCalculus,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
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
  final bool showDemo;
  final List<FeatureItem> features;
  final List<String>? premiumBenefits;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.animationAsset,
    required this.icon,
    this.isPremium = false,
    this.showDemo = false,
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
