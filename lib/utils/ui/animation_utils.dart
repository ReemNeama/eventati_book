import 'package:flutter/material.dart';

/// Types of animations
enum AnimationType {
  /// Fade in animation
  fadeIn,

  /// Fade out animation
  fadeOut,

  /// Slide in from bottom animation
  slideUp,

  /// Slide in from top animation
  slideDown,

  /// Slide in from left animation
  slideRight,

  /// Slide in from right animation
  slideLeft,

  /// Scale up animation
  scaleUp,

  /// Scale down animation
  scaleDown,

  /// Pulse animation
  pulse,

  /// Bounce animation
  bounce,
}

/// Utility class for animations
class AnimationUtils {
  /// Apply an animation to a widget
  static Widget applyAnimation(
    Widget child, {
    required AnimationType type,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    bool repeat = false,
    bool reverse = false,
  }) {
    switch (type) {
      case AnimationType.fadeIn:
        return _buildFadeInAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.fadeOut:
        return _buildFadeOutAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.slideUp:
        return _buildSlideUpAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.slideDown:
        return _buildSlideDownAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.slideRight:
        return _buildSlideRightAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.slideLeft:
        return _buildSlideLeftAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.scaleUp:
        return _buildScaleUpAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.scaleDown:
        return _buildScaleDownAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.pulse:
        return _buildPulseAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
      case AnimationType.bounce:
        return _buildBounceAnimation(
          child,
          duration: duration,
          curve: curve,
          repeat: repeat,
          reverse: reverse,
        );
    }
  }

  /// Build fade-in animation
  static Widget _buildFadeInAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  /// Build fade-out animation
  static Widget _buildFadeOutAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  /// Build slide-up animation
  static Widget _buildSlideUpAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }

  /// Build slide-down animation
  static Widget _buildSlideDownAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }

  /// Build slide-right animation
  static Widget _buildSlideRightAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }

  /// Build slide-left animation
  static Widget _buildSlideLeftAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }

  /// Build scale-up animation
  static Widget _buildScaleUpAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// Build scale-down animation
  static Widget _buildScaleDownAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.5, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// Build pulse animation
  static Widget _buildPulseAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    if (repeat) {
      return _buildRepeatingPulseAnimation(
        child,
        duration: duration,
        curve: curve,
        reverse: reverse,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.05),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// Build repeating pulse animation
  static Widget _buildRepeatingPulseAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool reverse,
  }) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) {
          // Calculate a sine wave for the pulse effect
          final pulseValue =
              1.0 + 0.05 * (reverse ? -1 : 1) * (0.5 + 0.5 * (2 * value - 1));

          return Transform.scale(scale: pulseValue, child: child);
        },
        child: child,
      ),
    );
  }

  /// Build bounce animation
  static Widget _buildBounceAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool repeat,
    required bool reverse,
  }) {
    if (repeat) {
      return _buildRepeatingBounceAnimation(
        child,
        duration: duration,
        curve: curve,
        reverse: reverse,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value) * (reverse ? -1 : 1)),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Build repeating bounce animation
  static Widget _buildRepeatingBounceAnimation(
    Widget child, {
    required Duration duration,
    required Curve curve,
    required bool reverse,
  }) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) {
          // Calculate a sine wave for the bounce effect
          final bounceValue =
              10 * (reverse ? -1 : 1) * (0.5 + 0.5 * (2 * value - 1));

          return Transform.translate(
            offset: Offset(0, bounceValue),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
