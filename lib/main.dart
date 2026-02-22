import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
// import 'dart:gmath' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockBlaster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: BlockBlasterGame(),
      ),
    );
  }
}

class BlockBlasterGame extends FlameGame with PanDetector {
  late PlayerShip player;
  late List<Shot> shots;
  late List<Block> blocks;
  int lives = 5;
  bool isGameOver = false;
  double respawnTimer = 0;
  static const double respawnDelay = 2.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    shots = [];
    blocks = [];
    
    debugPrint('Game size: ${size.x} x ${size.y}');
    
    // Create the player ship on the left side, vertically centered
    player = PlayerShip(
      gameRef: this,
    );
    player.position = Vector2(10, size.y / 2 - PlayerShip.shipHeight / 2);
    add(player);
    
    // Spawn some blocks
    _spawnBlocks();
    
    debugPrint('BlockBlasterGame loaded!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle game over state
    if (isGameOver) {
      respawnTimer -= dt;
      if (respawnTimer <= 0) {
        // Respawn the player
        lives = 5;
        isGameOver = false;
        player.position = Vector2(10, size.y / 2 - PlayerShip.shipHeight / 2);
        player.damageTimer = 0; // Reset invincibility
        debugPrint('Player respawned!');
      }
      return; // Don't update game while waiting to respawn
    }
    
    // Remove off-screen shots
    shots.removeWhere((shot) {
      if (shot.position.x > size.x) {
        remove(shot);
        return true;
      }
      return false;
    });
    
    // Check bullet-block collisions
    for (var shot in shots.toList()) {
      for (var block in blocks.toList()) {
        if (shot.toRect().overlaps(block.toRect()) && block.isVisible) {
          debugPrint('Bullet hit block! Shot: ${shot.toRect()}, Block: ${block.toRect()}');
          remove(shot);
          shots.remove(shot);
          block.hit();
          break;
        }
      }
    }
    
    // Check block-player collisions
    for (var block in blocks.toList()) {
      if (block.toRect().overlaps(player.toRect()) && block.isVisible) {
        // Only damage player if invincibility timer is expired
        if (player.canTakeDamage()) {
          lives--;
          player.takeDamage();
          debugPrint('Block hit player! Lives remaining: $lives');
        }
      }
    }
  }

  @override
  Color backgroundColor() {
    return const Color(0xFF1a1a2e);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderLives(canvas);
  }

  void _renderLives(Canvas canvas) {
    const miniShipWidth = 20.0;
    const miniShipHeight = 10.0;
    const padding = 10.0;
    const spacing = 25.0;

    if (lives <= 3) {
      // Show individual mini-ships
      for (int i = 0; i < lives; i++) {
        final x = padding + (i * spacing);
        final y = padding;
        _drawMiniShip(canvas, x, y, miniShipWidth, miniShipHeight);
      }
    } else {
      // Show one mini-ship with "x #" indicator
      _drawMiniShip(canvas, padding, padding, miniShipWidth, miniShipHeight);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'x $lives',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        const Offset(padding + miniShipWidth + 5, padding + 2),
      );
    }
  }

  void _drawMiniShip(Canvas canvas, double x, double y, double width, double height) {
    final paint = Paint()..color = Colors.blue;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw left half
    canvas.drawRect(
      Rect.fromLTWH(x, y, width / 2, height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(x, y, width / 2, height),
      outlinePaint,
    );

    // Draw right half
    canvas.drawRect(
      Rect.fromLTWH(x + width / 2, y, width / 2, height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + width / 2, y, width / 2, height),
      outlinePaint,
    );
  }

  void addShot(Shot shot) {
    shots.add(shot);
    add(shot);
  }

  void addBlock(Block block) {
    blocks.add(block);
    add(block);
  }

  void _spawnBlocks() {
    // Spawn a single block in the middle of the screen
    final block = Block(
      gameRef: this,
    );
    block.position = Vector2(size.x / 2 - Block.blockSize / 2, size.y / 2 - Block.blockSize / 2);
    addBlock(block);
  }

  @override
  void onPanUpdate(info) {
    // Calculate new position
    final newPosition = player.position + info.delta.global;
    
    // Create a test rect for the new position
    final testRect = Rect.fromLTWH(
      newPosition.x,
      newPosition.y,
      PlayerShip.shipWidth,
      PlayerShip.shipHeight,
    );
    
    // Check if new position would collide with any blocks
    bool canMove = true;
    Block? collidingBlock;
    for (var block in blocks) {
      if (block.isVisible && testRect.overlaps(block.toRect())) {
        canMove = false;
        collidingBlock = block;
        break;
      }
    }
    
    if (canMove) {
      player.position = newPosition;
    } else if (collidingBlock != null) {
      // Player is being blocked by a block - apply damage
      if (player.canTakeDamage()) {
        lives--;
        player.takeDamage();
        debugPrint('Player hit block while moving! Lives remaining: $lives');
        
        // Check if game over
        if (lives <= 0) {
          isGameOver = true;
          respawnTimer = respawnDelay;
          debugPrint('Game Over! Respawning in $respawnDelay seconds...');
        }
      }
    }
    
    // Keep ship within bounds
    player.position.x = player.position.x.clamp(0, size.x - PlayerShip.shipWidth);
    player.position.y = player.position.y.clamp(0, size.y - PlayerShip.shipHeight);
  }
}

class PlayerShip extends PositionComponent {
  final BlockBlasterGame gameRef;
  double shootTimer = 0;
  final double shootInterval = 1 / 6; // 6 shots per second
  static const double shipWidth = 100;  // Width now spans horizontally
  static const double shipHeight = 50;  // Height is vertical depth
  static const double damageInvincibilityTime = 1.0; // 1 second invincibility
  
  double damageTimer = 0; // Starts at 0, can take damage immediately

  PlayerShip({
    required this.gameRef,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(shipWidth, shipHeight);
    anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Don't shoot if game is over
    if (gameRef.isGameOver) return;
    
    // Update damage timer
    if (damageTimer > 0) {
      damageTimer -= dt;
    }
    
    // Update shoot timer
    shootTimer += dt;
    
    // Shoot at 6 per second
    if (shootTimer >= shootInterval) {
      _shoot();
      shootTimer = 0;
    }
  }

  bool canTakeDamage() {
    return damageTimer <= 0;
  }

  void takeDamage() {
    damageTimer = damageInvincibilityTime;
  }

  void _shoot() {
    final shot = Shot(
      gameRef: gameRef,
    );
    // Spawn from the front (right side) center of the ship
    shot.position = Vector2(
      position.x + shipWidth,
      position.y + shipHeight / 2,
    );
    gameRef.addShot(shot);
  }

  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, shipWidth, shipHeight);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Don't render if game is over
    if (gameRef.isGameOver) return;
    
    final paint = Paint()..color = Colors.blue;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw left half of ship (left side, horizontal)
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        shipWidth / 2,
        shipHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        shipWidth / 2,
        shipHeight,
      ),
      outlinePaint,
    );

    // Draw right half of ship (right side, horizontal)
    canvas.drawRect(
      Rect.fromLTWH(
        shipWidth / 2,
        0,
        shipWidth / 2,
        shipHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        shipWidth / 2,
        0,
        shipWidth / 2,
        shipHeight,
      ),
      outlinePaint,
    );
  }
}

class Shot extends PositionComponent {
  final BlockBlasterGame gameRef;
  static const double shotRadius = 8;
  static const double shotSpeed = 1200; // pixels per second

  Shot({
    required this.gameRef,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(shotRadius * 2, shotRadius * 2);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move shot rightward
    position.x += shotSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..color = Colors.yellow;
    
    // Draw shot as a circle
    canvas.drawCircle(
      Offset.zero,
      shotRadius,
      paint,
    );
  }

  Rect toRect() {
    return Rect.fromLTWH(
      position.x - shotRadius,
      position.y - shotRadius,
      shotRadius * 2,
      shotRadius * 2,
    );
  }
}

class Block extends PositionComponent {
  final BlockBlasterGame gameRef;
  static const double blockSize = 120; // Larger than the ship
  static const double blockSpeed = 0; // Block doesn't move
  static const int maxHealth = 4;
  static const double respawnTime = 2.0;

  int health = maxHealth;
  bool isVisible = true;
  double respawnTimer = 0;

  Block({
    required this.gameRef,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(blockSize, blockSize);
    anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle respawn timer
    if (!isVisible) {
      respawnTimer -= dt;
      if (respawnTimer <= 0) {
        // Respawn the block
        health = maxHealth;
        isVisible = true;
        respawnTimer = 0;
        debugPrint('Block respawned!');
      }
    }
  }

  void hit() {
    health--;
    debugPrint('Block hit! Health: $health');
    
    if (health <= 0) {
      isVisible = false;
      respawnTimer = respawnTime;
      debugPrint('Block disappeared! Will respawn in $respawnTime seconds');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Don't render if invisible
    if (!isVisible) return;
    
    final paint = Paint()..color = const Color(0xFF808080);
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw block as a filled square
    canvas.drawRect(
      Rect.fromLTWH(0, 0, blockSize, blockSize),
      paint,
    );
    // Draw outline
    canvas.drawRect(
      Rect.fromLTWH(0, 0, blockSize, blockSize),
      outlinePaint,
    );
    // Draw inner border for 3D effect
    canvas.drawRect(
      Rect.fromLTWH(5, 5, blockSize - 10, blockSize - 10),
      outlinePaint,
    );
    
    // Draw health indicator
    final healthText = health.toString();
    final textPainter = TextPainter(
      text: TextSpan(
        text: healthText,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(blockSize / 2 - textPainter.width / 2, blockSize / 2 - textPainter.height / 2),
    );
  }

  Rect toRect() {
    return Rect.fromLTWH(
      position.x,
      position.y,
      blockSize,
      blockSize,
    );
  }
}
