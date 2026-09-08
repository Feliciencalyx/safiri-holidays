import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Apple iOS-Style Frosted Glass Card Container
class IosGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurSigma;
  final bool isDark;
  final Border? customBorder;

  const IosGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 32.0,
    this.blurSigma = 22.0,
    this.isDark = false,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.fromLTRB(24, 32, 24, 32);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E2638).withValues(alpha: 0.88),
                      const Color(0xFF121722).withValues(alpha: 0.78),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.90),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            border: customBorder ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.5,
                ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D3B8A).withValues(alpha: isDark ? 0.30 : 0.08),
                blurRadius: 36,
                offset: const Offset(0, 16),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Floating Top-Right iOS Frosted Glass Language Switcher Button with Interactive Hover
class IosGlassLanguageButton extends StatefulWidget {
  final String flag;
  final String languageCode;
  final VoidCallback onTap;
  final bool isDark;

  const IosGlassLanguageButton({
    super.key,
    required this.flag,
    required this.languageCode,
    required this.onTap,
    this.isDark = false,
  });

  @override
  State<IosGlassLanguageButton> createState() => _IosGlassLanguageButtonState();
}

class _IosGlassLanguageButtonState extends State<IosGlassLanguageButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.95 : (_isHovered ? 1.06 : 1.0);
    final borderGlow = _isHovered
        ? const Color(0xFF1D3B8A).withValues(alpha: 0.5)
        : (widget.isDark ? Colors.white.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.8));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDark
                        ? [
                            Colors.white.withValues(alpha: _isHovered ? 0.18 : 0.10),
                            Colors.white.withValues(alpha: _isHovered ? 0.10 : 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: _isHovered ? 0.95 : 0.80),
                            const Color(0xFFEBF0FA).withValues(alpha: _isHovered ? 0.90 : 0.65),
                          ],
                  ),
                  border: Border.all(color: borderGlow, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? const Color(0xFF1D3B8A).withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: _isHovered ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: widget.isDark ? Colors.white : const Color(0xFF1D3B8A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: widget.isDark ? Colors.white70 : const Color(0xFF1D3B8A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive Hover Button with Scale, Lift, Elevation Bloom, and Spring Feedback
class IosHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? hoverColor;
  final double borderRadius;
  final double height;
  final BoxBorder? border;
  final List<BoxShadow>? normalShadows;
  final List<BoxShadow>? hoverShadows;

  const IosHoverButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.hoverColor,
    this.borderRadius = 30.0,
    this.height = 50.0,
    this.border,
    this.normalShadows,
    this.hoverShadows,
  });

  @override
  State<IosHoverButton> createState() => _IosHoverButtonState();
}

class _IosHoverButtonState extends State<IosHoverButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final scale = !isEnabled ? 1.0 : (_isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0));
    final offsetY = !isEnabled ? 0.0 : (_isPressed ? 1.0 : (_isHovered ? -2.0 : 0.0));

    final defaultShadows = widget.normalShadows ?? [
      BoxShadow(
        color: (widget.backgroundColor ?? const Color(0xFF1D3B8A)).withValues(alpha: 0.25),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    final elevatedShadows = widget.hoverShadows ?? [
      BoxShadow(
        color: (widget.backgroundColor ?? const Color(0xFF1D3B8A)).withValues(alpha: 0.40),
        blurRadius: 22,
        offset: const Offset(0, 8),
      ),
    ];

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, offsetY, 0),
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isHovered && widget.hoverColor != null
                  ? widget.hoverColor
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border,
              boxShadow: _isHovered ? elevatedShadows : defaultShadows,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Ambient Apple iOS Background Glow with Luxury Sapphire & Gold Light Orbs
class IosGlassBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const IosGlassBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base Theme Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: isDark ? const Color(0xFF0F141E) : const Color(0xFFF3F5FA),
        ),

        // Ambient Orb 1: Luxury Royal Sapphire (Top Left)
        Positioned(
          top: -screenSize.width * 0.25,
          left: -screenSize.width * 0.2,
          child: Container(
            width: screenSize.width * 0.9,
            height: screenSize.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFF1D3B8A) : const Color(0xFF3860C4)).withValues(alpha: isDark ? 0.35 : 0.16),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),

        // Ambient Orb 2: Champagne Amber Gold (Bottom Right)
        Positioned(
          bottom: -screenSize.width * 0.2,
          right: -screenSize.width * 0.2,
          child: Container(
            width: screenSize.width * 0.85,
            height: screenSize.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFFB8860B) : const Color(0xFFE5A63B)).withValues(alpha: isDark ? 0.22 : 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
        ),

        // Ambient Orb 3: Soft Cyan/Turquoise Accent (Center/Bottom Left)
        Positioned(
          top: screenSize.height * 0.45,
          left: -screenSize.width * 0.15,
          child: Container(
            width: screenSize.width * 0.6,
            height: screenSize.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00B4D8).withValues(alpha: isDark ? 0.12 : 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
        ),

        // Foreground Content
        child,
      ],
    );
  }
}

/// Generic Interactive Hover Card Wrapper with Spring Elevation and Glass Highlight
class IosHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isDark;

  const IosHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 20.0,
    this.padding,
    this.isDark = false,
  });

  @override
  State<IosHoverCard> createState() => _IosHoverCardState();
}

class _IosHoverCardState extends State<IosHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: _isHovered ? 0.10 : 0.06)
                  : Colors.white.withValues(alpha: _isHovered ? 0.95 : 0.85),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF1D3B8A).withValues(alpha: 0.4)
                    : (widget.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.7)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFF1D3B8A).withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
