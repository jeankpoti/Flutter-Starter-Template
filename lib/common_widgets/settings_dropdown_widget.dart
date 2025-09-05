import 'package:flutter/material.dart';
import 'text_widgets.dart';
import '../features/settings/domain/models/math_level.dart';
import '../l10n/app_localizations.dart';

class SettingsDropdown<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T selectedValue;
  final List<T> options;
  final String Function(T) getDisplayText;
  final String? Function(T)? getSubtitle;
  final void Function(T) onChanged;
  final Widget? icon;

  const SettingsDropdown({
    super.key,
    required this.title,
    this.subtitle,
    required this.selectedValue,
    required this.options,
    required this.getDisplayText,
    this.getSubtitle,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 12)],
              Expanded(
                child: AppTextWidget(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            AppTextWidget(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedValue,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                items:
                    options.map<DropdownMenuItem<T>>((T value) {
                      final subtitle = getSubtitle?.call(value);
                      return DropdownMenuItem<T>(
                        value: value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppTextWidget(
                              getDisplayText(value),
                              style: Theme.of(context).textTheme.bodyMedium,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                              // AppTextWidget(
                              //   subtitle,
                              //   style: Theme.of(context).textTheme.bodySmall,
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.onSurface.withValues(alpha: 0.6),
                              //   maxLines: 5,
                              //   overflow: TextOverflow.ellipsis,
                              //   softWrap: true,
                              // ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (T? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MathLevelDropdown extends StatelessWidget {
  final MathLevel selectedLevel;
  final bool isLoading;
  final void Function(MathLevel) onChanged;

  const MathLevelDropdown({
    super.key,
    required this.selectedLevel,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SettingsDropdown<MathLevel>(
      title: AppLocalizations.of(context)!.mathLevel,
      subtitle: AppLocalizations.of(context)!.mathLevelDescription,
      selectedValue: selectedLevel,
      options: MathLevel.values,
      getDisplayText: (level) => _getMathLevelDisplayName(context, level),
      getSubtitle:
          (level) =>
              '${_getMathLevelAgeRange(context, level)} - ${_getMathLevelDescription(context, level)}',
      onChanged: onChanged,
      icon: Icon(
        Icons.school,
        color: Theme.of(context).colorScheme.secondary,
        size: 24,
      ),
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final Locale selectedLocale;
  final void Function(String) onChanged;

  const LanguageDropdown({
    super.key,
    required this.selectedLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'en'},
      {'code': 'fr'},
      {'code': 'es'},
    ];

    return SettingsDropdown<Map<String, String>>(
      title: AppLocalizations.of(context)!.language,
      subtitle: AppLocalizations.of(context)!.choosePreferredLanguage,
      selectedValue: languages.firstWhere(
        (lang) => lang['code'] == selectedLocale.languageCode,
        orElse: () => languages[0], // Default to English
      ),
      options: languages,
      getDisplayText: (lang) => _getLanguageName(context, lang['code']!),
      getSubtitle: (lang) => _getLanguageNativeName(lang['code']!),
      onChanged: (selectedLang) => onChanged(selectedLang['code']!),
      icon: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.secondary,
        size: 24,
      ),
    );
  }
}

// Helper functions for MathLevel translations
String _getMathLevelDisplayName(BuildContext context, MathLevel level) {
  final localizations = AppLocalizations.of(context)!;
  switch (level) {
    case MathLevel.elementary:
      return localizations.elementary;
    case MathLevel.middleSchool:
      return localizations.middleSchool;
    case MathLevel.highSchool:
      return localizations.highSchool;
    case MathLevel.college:
      return localizations.college;
  }
}

String _getMathLevelAgeRange(BuildContext context, MathLevel level) {
  final localizations = AppLocalizations.of(context)!;
  switch (level) {
    case MathLevel.elementary:
      return localizations.elementaryAgeRange;
    case MathLevel.middleSchool:
      return localizations.middleSchoolAgeRange;
    case MathLevel.highSchool:
      return localizations.highSchoolAgeRange;
    case MathLevel.college:
      return localizations.collegeAgeRange;
  }
}

String _getMathLevelDescription(BuildContext context, MathLevel level) {
  final localizations = AppLocalizations.of(context)!;
  switch (level) {
    case MathLevel.elementary:
      return localizations.elementaryDescription;
    case MathLevel.middleSchool:
      return localizations.middleSchoolDescription;
    case MathLevel.highSchool:
      return localizations.highSchoolDescription;
    case MathLevel.college:
      return localizations.collegeDescription;
  }
}

// Helper functions for Language translations
String _getLanguageName(BuildContext context, String languageCode) {
  final localizations = AppLocalizations.of(context)!;
  switch (languageCode) {
    case 'en':
      return localizations.englishLanguage;
    case 'fr':
      return localizations.frenchLanguage;
    case 'es':
      return localizations.spanishLanguage;
    default:
      return languageCode.toUpperCase(); // Fallback
  }
}

String _getLanguageNativeName(String languageCode) {
  switch (languageCode) {
    case 'en':
      return 'English';
    case 'fr':
      return 'Français';
    case 'es':
      return 'Español';
    default:
      return languageCode.toUpperCase(); // Fallback
  }
}
