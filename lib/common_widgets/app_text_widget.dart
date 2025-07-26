import 'package:flutter/material.dart';

/// A comprehensive reusable text widget that handles all text styling needs
/// Use this as the base for all text in the app to ensure consistency
class AppTextWidget extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// Text style from theme - determines font size, weight, etc.
  final TextStyle? style;
  
  /// Override color (will use theme color if not provided)
  final Color? color;
  
  /// Text alignment
  final TextAlign? textAlign;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Text overflow behavior
  final TextOverflow? overflow;
  
  /// Whether text should wrap
  final bool? softWrap;
  
  /// Font weight override
  final FontWeight? fontWeight;
  
  /// Font size override
  final double? fontSize;
  
  /// Text decoration (underline, etc.)
  final TextDecoration? decoration;
  
  /// Line height multiplier
  final double? height;
  
  /// Letter spacing
  final double? letterSpacing;
  
  /// Word spacing
  final double? wordSpacing;
  
  /// Text direction
  final TextDirection? textDirection;
  
  /// Locale for text
  final Locale? locale;
  
  /// Selection color
  final Color? selectionColor;
  
  /// Whether text should be selectable
  final bool selectable;
  
  /// Callback when text is tapped (only for selectable text)
  final VoidCallback? onTap;

  const AppTextWidget(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.fontWeight,
    this.fontSize,
    this.decoration,
    this.height,
    this.letterSpacing,
    this.wordSpacing,
    this.textDirection,
    this.locale,
    this.selectionColor,
    this.selectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Build the text style with all customizations
    final effectiveStyle = (style ?? theme.textTheme.bodyMedium!).copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
    );

    if (selectable) {
      return SelectableText(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        textDirection: textDirection,
        onTap: onTap,
      );
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
    );
  }
}

/// Specific text widgets for common use cases
/// These use the theme's text styles and provide semantic meaning

class DisplayLargeText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const DisplayLargeText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.displayLarge,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class DisplayMediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const DisplayMediumText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.displayMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class DisplaySmallText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const DisplaySmallText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.displaySmall,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class HeadlineLargeText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const HeadlineLargeText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.headlineLarge,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class HeadlineMediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const HeadlineMediumText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class HeadlineSmallText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const HeadlineSmallText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class TitleLargeText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const TitleLargeText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.titleLarge,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class TitleMediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const TitleMediumText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.titleMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class TitleSmallText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const TitleSmallText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.titleSmall,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class BodyLargeText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const BodyLargeText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class BodyMediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const BodyMediumText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class BodySmallText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const BodySmallText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.bodySmall,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class LabelLargeText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const LabelLargeText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.labelLarge,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class LabelMediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const LabelMediumText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.labelMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}

class LabelSmallText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const LabelSmallText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextWidget(
      text,
      style: Theme.of(context).textTheme.labelSmall,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }
}