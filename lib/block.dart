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
  static GameBlock? create({
    required int level,
    required Vector2 position,
  }) {
    assert(level >= 0 && level <= 10, 'Block level must be 0–10.');
    if (level == 0) return null;
    return GameBlock(level: level, spawnPosition: position);
  }
}

// ---------------------------------------------------------------------------

class GameBlock extends PositionComponent {
  static const double blockSize = 50.0;
  static const double respawnTime = 2.0;

  /// Level this block was created at (1–10).
  final int level;

  /// Maximum health for this block, derived from [health][level].
  late final int maxHealth;

  /// Current remaining health.
  int remainingHealth = 0;

  bool isVisible = true;
  double respawnTimer = 0;

  GameBlock({required this.level, required Vector2 spawnPosition})
      : assert(level >= 1 && level <= 10) {
    maxHealth = health[level];
    remainingHealth = maxHealth;
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
    if (!isVisible) {
      respawnTimer -= dt;
      if (respawnTimer <= 0) {
        remainingHealth = maxHealth;
        isVisible = true;
        respawnTimer = 0;
      }
    }
  }

  /// Register a hit on this block.  Returns true if the block was destroyed.
  bool hit() {
    if (!isVisible) return false;
    remainingHealth--;
    if (remainingHealth <= 0) {
      isVisible = false;
      respawnTimer = respawnTime;
      return true;
    }
    return false;
  }

  Rect toRect() =>
      Rect.fromLTWH(position.x, position.y, blockSize, blockSize);

  // ---------------------------------------------------------------------------
  // Color logic
  // ---------------------------------------------------------------------------

  /// Maps [hp] to a color slot (1–10), resolving the user's stored color from
  /// localStorage first, falling back to [defaultColors].
  ///
  /// Thresholds mirror the [health] list:
  ///   hp >= 512  → slot 10
  ///   hp >= 256  → slot 9
  ///   hp >= 128  → slot 8
  ///   hp >= 64   → slot 7
  ///   hp >= 32   → slot 6
  ///   hp >= 16   → slot 5
  ///   hp >= 8    → slot 4
  ///   hp >= 4    → slot 3
  ///   hp >= 2    → slot 2
  ///   hp >= 1    → slot 1
  ///   hp <= 0    → transparent
  static Color colorForHealth(int hp) {
    if (hp <= 0) return Colors.transparent;

    final int slot;
    if (hp >= 512) {
      slot = 10;
    } else if (hp >= 256) {
      slot = 9;
    } else if (hp >= 128) {
      slot = 8;
    } else if (hp >= 64) {
      slot = 7;
    } else if (hp >= 32) {
      slot = 6;
    } else if (hp >= 16) {
      slot = 5;
    } else if (hp >= 8) {
      slot = 4;
    } else if (hp >= 4) {
      slot = 3;
    } else if (hp >= 2) {
      slot = 2;
    } else {
      slot = 1;
    }

    // Prefer user-saved color; fall back to defaultColors.
    return LocalStorageProperties.getColor(slot) ??
        defaultColors[slot] ??
        Colors.grey;
  }

  /// The current display color based on [remainingHealth].
  Color get currentColor => colorForHealth(remainingHealth);

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
