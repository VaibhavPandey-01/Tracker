import 'package:flutter/material.dart';

const List<Color> rainbowColors = [
  Color(0xFF7C3AED), // Violet
  Color(0xFF2563EB), // Blue
  Color(0xFF0D9488), // Teal
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
];

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final bool isInset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showRainbowBorder;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.borderRadius = 24.0,
    this.isInset = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showRainbowBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color surfaceColor = isDark ? const Color(0xFF0A0A0C) : const Color(0xFFF0F0F3);
    final Color topHighlight = isDark ? const Color(0x662A2A30) : const Color(0xE6FFFFFF);
    final Color bottomShadow = isDark ? const Color(0x99000000) : const Color(0x4FA3B1C6);

    Widget content = child ?? const SizedBox();
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }

    Widget container;
    if (isInset) {
      container = CustomPaint(
        painter: _InsetNeumorphicPainter(
          borderRadius: borderRadius,
          baseColor: surfaceColor,
          isDark: isDark,
        ),
        child: content,
      );
    } else {
      container = AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: margin,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: topHighlight,
              offset: const Offset(-6, -6),
              blurRadius: 16,
            ),
            BoxShadow(
              color: bottomShadow,
              offset: const Offset(6, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              content,
              if (showRainbowBorder)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: rainbowColors,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return margin != null ? Padding(padding: margin!, child: container) : container;
  }
}

class _InsetNeumorphicPainter extends CustomPainter {
  final double borderRadius;
  final Color baseColor;
  final bool isDark;

  _InsetNeumorphicPainter({
    required this.borderRadius,
    required this.baseColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Draw base color background
    final basePaint = Paint()..color = baseColor;
    canvas.drawRRect(rrect, basePaint);

    canvas.save();
    canvas.clipRRect(rrect);

    // Inner shadow colors
    final Color innerShadowColor = isDark ? const Color(0xB3000000) : const Color(0x66A3B1C6);
    final Color innerHighlightColor = isDark ? const Color(0x332A2A30) : const Color(0xE6FFFFFF);

    // Draw top-left dark inner shadow
    final darkPaint = Paint()
      ..color = innerShadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final darkPath = Path()
      ..moveTo(-3, size.height + 3)
      ..lineTo(-3, -3)
      ..lineTo(size.width + 3, -3);
    canvas.drawPath(darkPath, darkPaint);

    // Draw bottom-right light inner shadow
    final lightPaint = Paint()
      ..color = innerHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final lightPath = Path()
      ..moveTo(-3, size.height + 3)
      ..lineTo(size.width + 3, size.height + 3)
      ..lineTo(size.width + 3, -3);
    canvas.drawPath(lightPath, lightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InsetNeumorphicPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius || oldDelegate.baseColor != baseColor || oldDelegate.isDark != isDark;
  }
}

class NeumorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final bool showRainbowBorder;
  final double? width;
  final double? height;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 28.0,
    this.showRainbowBorder = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      onTap: onTap,
      borderRadius: borderRadius,
      showRainbowBorder: showRainbowBorder,
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(child: child),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isNumeric;

  const NeumorphicTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            labelText,
            style: tt.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        NeumorphicContainer(
          isInset: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: tt.bodyLarge?.copyWith(
                color: const Color(0xFF8A8A93).withOpacity(0.4),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}

class NeumorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 60,
        height: 34,
        child: Stack(
          children: [
            // Track (Inset)
            NeumorphicContainer(
              isInset: true,
              borderRadius: 17,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: value
                      ? [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.15),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            // Knob (Raised)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: value ? 28.0 : 4.0,
              top: 4.0,
              child: NeumorphicContainer(
                width: 26,
                height: 26,
                borderRadius: 13,
                child: const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RainbowGauge extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final Widget centerWidget;
  final double size;
  final double strokeWidth;

  const RainbowGauge({
    super.key,
    required this.percentage,
    required this.centerWidget,
    this.size = 200,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft inset ring track
          NeumorphicContainer(
            width: size - 4,
            height: size - 4,
            borderRadius: size / 2,
            isInset: true,
            child: const SizedBox(),
          ),
          // Gradient arc drawing
          SizedBox(
            width: size - strokeWidth - 10,
            height: size - strokeWidth - 10,
            child: CustomPaint(
              painter: _RainbowArcPainter(
                percentage: percentage,
                strokeWidth: strokeWidth,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
          // Inner content
          Positioned(
            child: centerWidget,
          ),
        ],
      ),
    );
  }
}

class _RainbowArcPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final bool isDark;

  _RainbowArcPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track line
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF141416) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159 * 1.25, 3.14159 * 1.5, false, trackPaint);

    if (percentage <= 0) return;

    // Draw active gradient arc
    final sweepAngle = (3.14159 * 1.5) * percentage.clamp(0.0, 1.0);
    final startAngle = -3.14159 * 1.25;

    final gradient = SweepGradient(
      colors: rainbowColors,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(startAngle),
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RainbowArcPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.strokeWidth != strokeWidth || oldDelegate.isDark != isDark;
  }
}
