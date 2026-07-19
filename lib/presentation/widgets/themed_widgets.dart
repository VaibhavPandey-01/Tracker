import 'package:flutter/material.dart';

// Neumorphic Theme Colors (Soft off-white base)
const Color neuBgColor = Color(0xFFE9E9F2);
const Color textColor = Color(0xFF2D3748); // Dark charcoal gray for headings
const Color subColor = Color(0xFF8A8A93);  // Medium gray for secondary text

const List<Color> rainbowColors = [
  Color(0xFF7C3AED), // Violet
  Color(0xFF2563EB), // Blue
  Color(0xFF0D9488), // Teal
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
];

// ─── AppBackground ───────────────────────────────────────────────────────────

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neuBgColor,
      body: SafeArea(child: child),
    );
  }
}

// ─── AppCard ──────────────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showAccentTopBorder;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.showAccentTopBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final finalPadding = padding ?? const EdgeInsets.all(20);

    Widget innerContent = Padding(
      padding: finalPadding,
      child: child,
    );

    if (onTap != null) {
      innerContent = InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: innerContent,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: neuBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFFA3B1C6).withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            innerContent,
            if (showAccentTopBorder)
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
}

// ─── AppButton ───────────────────────────────────────────────────────────────

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isPrimary;

  const AppButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: neuBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFFA3B1C6).withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          if (isPrimary)
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
    );
  }
}

// ─── AppGauge ────────────────────────────────────────────────────────────────

class AppGauge extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final Widget centerWidget;
  final double size;

  const AppGauge({
    super.key,
    required this.percentage,
    required this.centerWidget,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inset shadow track
          Container(
            width: size - 6,
            height: size - 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neuBgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFFA3B1C6).withOpacity(0.5),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          // Rainbow progress painter
          CustomPaint(
            size: Size(size - 18, size - 18),
            painter: _RainbowArcPainter(percentage: percentage),
          ),
          centerWidget,
        ],
      ),
    );
  }
}

class _RainbowArcPainter extends CustomPainter {
  final double percentage;

  _RainbowArcPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    final basePaint = Paint()
      ..color = const Color(0xFFDCDCE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, basePaint);

    if (percentage <= 0) return;

    final sweepAngle = 3.14159 * 2 * percentage;
    const gradient = SweepGradient(
      colors: [
        Color(0xFF7C3AED),
        Color(0xFF2563EB),
        Color(0xFF0D9488),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF7C3AED),
      ],
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RainbowArcPainter oldDelegate) => true;
}

// ─── AppTextField ────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              labelText,
              style: tt.labelMedium?.copyWith(
                color: subColor,
                fontSize: 13,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: neuBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFFA3B1C6).withOpacity(0.5),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: textColor, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: subColor.withOpacity(0.4)),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
