import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import 'settings_constants.dart';
import 'localstorage_properties.dart';

/// Factory that creates a [GameBlock] from a level value (0–10).
///
/// Level 0 → returns null (no block created).
/// Levels 1–10 → creates a block whose maximum health equals
/// [health][level] from [settings_constants.dart].
///
/// Block color is determined by the current [remainingHealth] via
/// [GameBlock.colorForHealth], which checks the matching localStorage
/// color slot and falls back to [defaultColors].
abstract class BlockFactory {
  /// Returns a [GameBlock] for the given [level], or null if [level] is 0.
  /// [screenWidth] is used to calculate movement speed (60s traverse time).
  static GameBlock? create({
    required int level,
    required Vector2 position,
    required double screenWidth,
  }) {
    assert(level >= 0 && level <= 10, 'Block level must be 0–10.');
    if (level == 0) return null;
    return GameBlock(
      level: level,
      spawnPosition: position,
      screenWidth: screenWidth,
    );
  }
}

// ---------------------------------------------------------------------------

class GameBlock extends PositionComponent {
  static const double blockSize = 50.0;
  static const double traverseTime = 30.0; // seconds to cross screen

  /// Level this block was created at (1–10).
  final int level;

  /// Movement speed in pixels/second (left, toward player).
  final double moveSpeed;

  /// Maximum health for this block, derived from [health][level].
  final int maxHealth;

  /// Current remaining health.
  int remainingHealth;

  bool isVisible = true;

  GameBlock({
    required this.level,
    required Vector2 spawnPosition,
    required double screenWidth,
  })  : assert(level >= 1 && level <= 10),
        maxHealth = health[level],
        moveSpeed = screenWidth / traverseTime,
        remainingHealth = health[level] {
    position = spawnPosition;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(blockSize, blockSize);
    anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move left toward player
    if (isVisible) {
      position.x -= moveSpeed * dt;
    }
  }

  /// Register a hit on this block. Returns maxHealth if destroyed, 0 otherwise.
  int hit() {
    if (!isVisible) return 0;
    remainingHealth--;
    if (remainingHealth <= 0) {
      isVisible = false;
      return maxHealth;
    }
    return 0;
  }

  Rect toRect() =>
      Rect.fromLTWH(position.x, position.y, blockSize, blockSize);

  // ---------------------------------------------------------------------------
  // Color logic
  // ---------------------------------------------------------------------------

  /// Maps [hp] and [maxHp] to a color slot (1–10), resolving the user's stored color from
  /// localStorage first, falling back to [defaultColors].
  ///
  /// Color stays at the breakpoint level until health drops below it:
  ///   maxHp >= 512 (slot 10) stays until hp < 256
  ///   maxHp >= 256 (slot 9) stays until hp < 128
  ///   maxHp >= 128 (slot 8) stays until hp < 64
  ///   maxHp >= 64 (slot 7) stays until hp < 32
  ///   maxHp >= 32 (slot 6) stays until hp < 16
  ///   maxHp >= 16 (slot 5) stays until hp < 8
  ///   maxHp >= 8 (slot 4) stays until hp < 4
  ///   maxHp >= 4 (slot 3) stays until hp < 2
  ///   maxHp >= 2 (slot 2) stays until hp < 1
  ///   hp <= 0 → transparent
  static Color colorForHealth(int hp, int maxHp) {
    if (hp <= 0) return Colors.transparent;

    final int slot;
    if (hp >= 257) { // 512 -- 512 is double impossible, might remove later
      slot = 10;
    } else if (hp >= 129) { // 256
      slot = 9;
    } else if (hp >= 65) { // 128
      slot = 8;
    } else if (hp >= 33) { // 64
      slot = 7;
    } else if (hp >= 17) { // 32
      slot = 6;
    } else if (hp >= 9) { // 16
      slot = 5;
    } else if (hp >= 5) { // 8
      slot = 4;
    } else if (hp >= 3) { // 4
      slot = 3;
    } else if (hp >= 2) { // 2
      slot = 2;
    } else { // should be less than or equal to 1 health left
      slot = 1;
    }

    // Prefer user-saved color; fall back to defaultColors.
    return LocalStorageProperties.getColor(slot) ??
        defaultColors[slot] ??
        Colors.grey;
  }

  /// The current display color based on [remainingHealth] and [maxHealth].
  Color get currentColor => colorForHealth(remainingHealth, maxHealth);

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isVisible) return;

    final fillPaint = Paint()..color = currentColor;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0, 0, blockSize, blockSize), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, blockSize, blockSize), outlinePaint);
    canvas.drawRect(
        Rect.fromLTWH(5, 5, blockSize - 10, blockSize - 10), innerPaint);

    // Health label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$remainingHealth',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        blockSize / 2 - textPainter.width / 2,
        blockSize / 2 - textPainter.height / 2,
      ),
    );
  }
}
