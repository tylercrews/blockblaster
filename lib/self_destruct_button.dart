import 'package:flutter/material.dart';
// import 'package:flame/components.dart';
// import 'dart:math' as math;

/// A self-destruct button HUD element rendered on the Flame canvas.
///
/// Visual: Yellow/black caution stripes border → red circle button with skull →
/// translucent glass cover that slides up/down via vertical swipe.
///
/// Interaction is handled externally by the game (touch events forwarded here).
/// The button reports state via [isGlassOpen] and accepts presses via [tryPress].
class SelfDestructButton {
  // Layout
  final double x;
  final double y;
  static const double totalSize = 44.0; // overall square size
  static const double stripeWidth = 5.0; // caution border thickness
  static const double buttonRadius = 13.0; // red button radius
  static const double glassHeight = totalSize - stripeWidth * 2; // inner area
  static const double glassWidth = totalSize - stripeWidth * 2;

  // State
  /// 0.0 = fully closed (glass down), 1.0 = fully open (glass up)
  double glassOpenAmount = 0.0;
  bool _isDraggingGlass = false;
  double _dragStartY = 0;
  double _dragStartAmount = 0;

  /// Cooldown so the button can't be spammed.
  double cooldownTimer = 0;
  static const double cooldownDuration = 3.0;

  /// Whether the button is currently available to press.
  bool get isGlassOpen => glassOpenAmount >= 0.95;
  bool get isOnCooldown => cooldownTimer > 0;
  bool get canPress => isGlassOpen && !isOnCooldown;

  SelfDestructButton({required this.x, required this.y});

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  void update(double dt) {
    if (cooldownTimer > 0) {
      cooldownTimer -= dt;
      if (cooldownTimer < 0) cooldownTimer = 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Touch interaction
  // ---------------------------------------------------------------------------

  /// Returns true if the point is within the button's bounding box.
  bool containsPoint(double px, double py) {
    return px >= x && px <= x + totalSize && py >= y && py <= y + totalSize;
  }

  /// Returns true if this component handled the touch-down.
  bool handleTouchDown(double px, double py) {
    if (!containsPoint(px, py)) return false;
    _isDraggingGlass = true;
    _dragStartY = py;
    _dragStartAmount = glassOpenAmount;
    return true;
  }

  /// Returns true if this component is currently handling a drag.
  bool handleTouchMove(double px, double py) {
    if (!_isDraggingGlass) return false;
    // Swipe up to open (negative dy = open), swipe down to close
    final dy = py - _dragStartY;
    // Map pixels to open amount: ~30px swipe = full open/close
    final delta = -dy / 30.0;
    glassOpenAmount = (_dragStartAmount + delta).clamp(0.0, 1.0);
    return true;
  }

  void handleTouchUp() {
    _isDraggingGlass = false;
    // Snap to open or closed
    if (glassOpenAmount > 0.5) {
      glassOpenAmount = 1.0;
    } else {
      glassOpenAmount = 0.0;
    }
  }

  /// Attempts to press the button. Returns true if successful.
  bool tryPress() {
    if (!canPress) return false;
    cooldownTimer = cooldownDuration;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(x, y);

    // 1. Background (dark grey)
    final bgPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), bgPaint);

    // 2. Yellow/black caution stripes border
    _drawCautionBorder(canvas);

    // 3. Inner area
    final innerX = stripeWidth;
    final innerY = stripeWidth;
    final innerW = totalSize - stripeWidth * 2;
    final innerH = totalSize - stripeWidth * 2;

    // Dark inner background
    final innerBg = Paint()..color = const Color(0xFF222222);
    canvas.drawRect(Rect.fromLTWH(innerX, innerY, innerW, innerH), innerBg);

    // 4. Red button circle
    final buttonCenterX = totalSize / 2;
    final buttonCenterY = totalSize / 2;
    
    // Button shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF660000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(buttonCenterX, buttonCenterY + 1),
      buttonRadius,
      shadowPaint,
    );

    // Main button
    final buttonPaint = Paint()
      ..color = isOnCooldown ? const Color(0xFF666666) : const Color(0xFFCC0000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(buttonCenterX, buttonCenterY),
      buttonRadius,
      buttonPaint,
    );

    // Button highlight
    final highlightPaint = Paint()
      ..color = isOnCooldown
          ? const Color(0xFF888888)
          : const Color(0xFFFF3333)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(buttonCenterX - 2, buttonCenterY - 2),
      buttonRadius * 0.5,
      highlightPaint,
    );

    // Button outline
    final buttonOutline = Paint()
      ..color = const Color(0xFF880000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
      Offset(buttonCenterX, buttonCenterY),
      buttonRadius,
      buttonOutline,
    );

    // 5. Skull icon on button
    _drawSkull(canvas, buttonCenterX, buttonCenterY);

    // 6. Glass cover (slides up based on glassOpenAmount)
    _drawGlass(canvas, innerX, innerY, innerW, innerH);

    // 7. Outer border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), borderPaint);

    canvas.restore();
  }

  void _drawCautionBorder(Canvas canvas) {
    final yellowPaint = Paint()..color = const Color(0xFFFFCC00);
    // final blackPaint = Paint()..color = Colors.black;

    // Draw yellow base for all four sides
    // Top
    canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, stripeWidth), yellowPaint);
    // Bottom
    canvas.drawRect(
        Rect.fromLTWH(0, totalSize - stripeWidth, totalSize, stripeWidth),
        yellowPaint);
    // Left
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeWidth, totalSize), yellowPaint);
    // Right
    canvas.drawRect(
        Rect.fromLTWH(totalSize - stripeWidth, 0, stripeWidth, totalSize),
        yellowPaint);

    // Draw diagonal black stripes on border
    final stripePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, totalSize, stripeWidth)); // top
    for (double i = -totalSize; i < totalSize * 2; i += 6) {
      canvas.drawLine(Offset(i, 0), Offset(i + stripeWidth, stripeWidth), stripePaint);
    }
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, totalSize - stripeWidth, totalSize, stripeWidth)); // bottom
    for (double i = -totalSize; i < totalSize * 2; i += 6) {
      canvas.drawLine(
        Offset(i, totalSize - stripeWidth),
        Offset(i + stripeWidth, totalSize),
        stripePaint,
      );
    }
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, stripeWidth, stripeWidth, totalSize - stripeWidth * 2)); // left
    for (double i = -totalSize; i < totalSize * 2; i += 6) {
      canvas.drawLine(Offset(0, i), Offset(stripeWidth, i + stripeWidth), stripePaint);
    }
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        totalSize - stripeWidth, stripeWidth, stripeWidth, totalSize - stripeWidth * 2)); // right
    for (double i = -totalSize; i < totalSize * 2; i += 6) {
      canvas.drawLine(
        Offset(totalSize - stripeWidth, i),
        Offset(totalSize, i + stripeWidth),
        stripePaint,
      );
    }
    canvas.restore();
  }

  void _drawSkull(Canvas canvas, double cx, double cy) {
    final skullPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final s = buttonRadius * 0.7; // skull scale

    // Head (rounded rect approximation via circle)
    canvas.drawCircle(Offset(cx, cy - s * 0.15), s * 0.55, skullPaint);

    // Jaw
    canvas.drawRect(
      Rect.fromLTWH(cx - s * 0.35, cy + s * 0.1, s * 0.7, s * 0.3),
      skullPaint,
    );

    // Eyes
    canvas.drawCircle(Offset(cx - s * 0.2, cy - s * 0.2), s * 0.15, eyePaint);
    canvas.drawCircle(Offset(cx + s * 0.2, cy - s * 0.2), s * 0.15, eyePaint);

    // Nose (small triangle approximation)
    canvas.drawCircle(Offset(cx, cy + s * 0.05), s * 0.07, eyePaint);

    // Teeth lines
    final teethPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double tx = -s * 0.15; tx <= s * 0.15; tx += s * 0.15) {
      canvas.drawLine(
        Offset(cx + tx, cy + s * 0.1),
        Offset(cx + tx, cy + s * 0.4),
        teethPaint,
      );
    }
  }

  void _drawGlass(
      Canvas canvas, double innerX, double innerY, double innerW, double innerH) {
    // Glass slides up: at 0.0 it covers the full inner area,
    // at 1.0 it's fully above the inner area.
    final glassY = innerY - (glassOpenAmount * innerH);
    // final glassVisibleTop = math.max(glassY, innerY);
    final glassVisibleBottom = glassY + innerH;

    if (glassVisibleBottom <= innerY) return; // fully off-screen (open)

    // Clip to inner area so glass doesn't draw outside
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(innerX, innerY, innerW, innerH));

    // Glass body
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(innerX, glassY, innerW, innerH),
      glassPaint,
    );

    // Glass reflection line
    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(innerX + 4, glassY + 3),
      Offset(innerX + 4, glassY + innerH - 3),
      reflectionPaint,
    );

    // Glass outline
    final glassOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(
      Rect.fromLTWH(innerX, glassY, innerW, innerH),
      glassOutline,
    );

    // Small tab/handle at bottom of glass
    final tabPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final tabY = glassY + innerH - 3;
    canvas.drawRect(
      Rect.fromLTWH(innerX + innerW / 2 - 4, tabY, 8, 3),
      tabPaint,
    );

    canvas.restore();
  }
}
