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
        block.hit();
        debugPrint('Block hit player!');
      }
    }
  }

  @override
  Color backgroundColor() {
    return const Color(0xFF1a1a2e);
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
    block.position = Vector2(size.x / 2, size.y / 2);
    addBlock(block);
  }

  @override
  void onPanUpdate(info) {
    // Move player ship based on drag
    player.position += info.delta.global;
    
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
    
    // Update shoot timer
    shootTimer += dt;
    
    // Shoot at 6 per second
    if (shootTimer >= shootInterval) {
      _shoot();
      shootTimer = 0;
    }
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
  static const double blockSize = 40;
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
    anchor = Anchor.center;
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
      Rect.fromLTWH(-blockSize / 2, -blockSize / 2, blockSize, blockSize),
      paint,
    );
    // Draw outline
    canvas.drawRect(
      Rect.fromLTWH(-blockSize / 2, -blockSize / 2, blockSize, blockSize),
      outlinePaint,
    );
    // Draw inner border for 3D effect
    canvas.drawRect(
      Rect.fromLTWH(-blockSize / 2 + 5, -blockSize / 2 + 5, blockSize - 10, blockSize - 10),
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
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  Rect toRect() {
    return Rect.fromLTWH(
      position.x - blockSize / 2,
      position.y - blockSize / 2,
      blockSize,
      blockSize,
    );
  }
}
