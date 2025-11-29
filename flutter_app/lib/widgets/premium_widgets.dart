import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/apple_theme.dart';

/// Premium card with subtle shadow and rounded corners
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius = AppleRadius.xl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppleColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppleShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppleSpacing.cardPadding),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}


/// Premium button with gradient background and scale animation
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double height;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final String? semanticLabel;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.height = 50,
    this.width,
    this.isLoading = false,
    this.icon,
    this.semanticLabel,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppleColors.redGradient;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      label: widget.semanticLabel ?? widget.text,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppleRadius.mdAll,
            boxShadow: AppleShadows.buttonShadow(AppleColors.primaryRed),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppleColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: AppleColors.white, size: 20),
                        const SizedBox(width: AppleSpacing.sm),
                      ],
                      Text(
                        widget.text,
                        style: AppleTypography.headline.copyWith(
                          color: AppleColors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
    );
  }
}

/// Premium outline button with gold accent
class PremiumOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final double height;
  final double? width;
  final IconData? icon;

  const PremiumOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.height = 50,
    this.width,
    this.icon,
  });

  @override
  State<PremiumOutlineButton> createState() => _PremiumOutlineButtonState();
}

class _PremiumOutlineButtonState extends State<PremiumOutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.borderColor ?? AppleColors.accentGold;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: AppleRadius.mdAll,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: color, size: 20),
                  const SizedBox(width: AppleSpacing.sm),
                ],
                Text(
                  widget.text,
                  style: AppleTypography.headline.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/// Premium text field with clean design
class PremiumTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final int? maxLength;
  final String? errorText;

  const PremiumTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? AppleColors.error
        : _isFocused
            ? AppleColors.primaryRed
            : AppleColors.systemGray4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppleTypography.subhead.copyWith(
              color: AppleColors.labelSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppleSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppleColors.white,
            borderRadius: AppleRadius.mdAll,
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            style: AppleTypography.body,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppleTypography.body.copyWith(
                color: AppleColors.systemGray,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppleColors.primaryRed
                          : AppleColors.systemGray,
                      size: 22,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppleSpacing.base,
                vertical: AppleSpacing.md,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppleSpacing.xs),
          Text(
            widget.errorText!,
            style: AppleTypography.caption1.copyWith(color: AppleColors.error),
          ),
        ],
      ],
    );
  }
}


/// Premium floating search bar
class PremiumSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const PremiumSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppleColors.white,
        borderRadius: AppleRadius.mdAll,
        boxShadow: AppleShadows.elevated,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppleTypography.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppleTypography.body.copyWith(
            color: AppleColors.systemGray,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppleColors.systemGray,
            size: 22,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppleColors.systemGray,
                    size: 20,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppleSpacing.base,
            vertical: AppleSpacing.md,
          ),
        ),
      ),
    );
  }
}


/// Premium chip for selection
class PremiumChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final VoidCallback? onClose;

  const PremiumChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppleDurations.base,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppleSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppleColors.goldAccentGradient : null,
          color: isSelected ? null : AppleColors.systemGray6,
          borderRadius: AppleRadius.fullAll,
          border: isSelected
              ? Border.all(color: AppleColors.accentGold.withValues(alpha: 0.5), width: 2)
              : Border.all(color: AppleColors.systemGray5, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppleColors.accentGold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppleColors.labelPrimary
                    : AppleColors.labelSecondary,
              ),
              const SizedBox(width: AppleSpacing.xs),
            ],
            Text(
              label,
              style: AppleTypography.subhead.copyWith(
                color: isSelected
                    ? AppleColors.labelPrimary
                    : AppleColors.labelSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onClose != null) ...[
              const SizedBox(width: AppleSpacing.xs),
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isSelected
                      ? AppleColors.labelPrimary
                      : AppleColors.labelSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium bottom sheet helper
class PremiumBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;

  const PremiumBottomSheet({
    super.key,
    required this.child,
    this.height,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      isScrollControlled: true,
      builder: (context) => PremiumBottomSheet(
        height: height,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppleColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppleRadius.xl),
        ),
        border: Border(
          top: BorderSide(
            color: AppleColors.accentGold.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppleSpacing.sm),
            // Drag indicator
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppleColors.systemGray3,
                borderRadius: AppleRadius.fullAll,
              ),
            ),
            const SizedBox(height: AppleSpacing.base),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Status badge
class PremiumStatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const PremiumStatusBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppleSpacing.sm,
        vertical: AppleSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppleRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppleSpacing.xs),
          Text(
            text,
            style: AppleTypography.caption1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading overlay
class PremiumLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const PremiumLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppleColors.white.withValues(alpha: 0.8),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppleColors.primaryRed,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}

/// Floating action button with premium styling
class PremiumFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Gradient? gradient;

  const PremiumFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.gradient,
  });

  @override
  State<PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<PremiumFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppleColors.redGradient,
            shape: BoxShape.circle,
            boxShadow: AppleShadows.floating,
          ),
          child: Icon(
            widget.icon,
            color: AppleColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}


/// Skeleton loading placeholder
class PremiumSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PremiumSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = AppleRadius.sm,
  });

  @override
  State<PremiumSkeleton> createState() => _PremiumSkeletonState();
}

class _PremiumSkeletonState extends State<PremiumSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppleColors.systemGray5.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Empty state widget
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppleSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppleColors.systemGray6,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppleColors.systemGray,
              ),
            ),
            const SizedBox(height: AppleSpacing.lg),
            Text(
              title,
              style: AppleTypography.title3,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppleSpacing.sm),
              Text(
                subtitle!,
                style: AppleTypography.callout,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppleSpacing.xl),
              PremiumButton(
                text: actionText!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton card for loading states
class PremiumSkeletonCard extends StatelessWidget {
  const PremiumSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppleSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PremiumSkeleton(width: 48, height: 48, borderRadius: AppleRadius.md),
              const SizedBox(width: AppleSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    PremiumSkeleton(width: 120, height: 18),
                    SizedBox(height: AppleSpacing.sm),
                    PremiumSkeleton(width: 180, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
