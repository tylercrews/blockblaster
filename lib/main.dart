import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'dart:math' as math;

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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BlockBlasterGame game;
  final Map<int, Offset> activePointers = {};

  @override
  void initState() {
    super.initState();
    game = BlockBlasterGame();
  }

  void _handlePointerDown(PointerDownEvent event) {
    activePointers[event.pointer] = event.localPosition;
    game.handleTouchDown(event.pointer, Vector2(event.localPosition.dx, event.localPosition.dy));
  }

  void _handlePointerMove(PointerMoveEvent event) {
    activePointers[event.pointer] = event.localPosition;
    game.handleTouchUpdate(event.pointer, Vector2(event.localPosition.dx, event.localPosition.dy));
  }

  void _handlePointerUp(PointerUpEvent event) {
    activePointers.remove(event.pointer);
    game.handleTouchUp(event.pointer);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    activePointers.remove(event.pointer);
    game.handleTouchCancel(event.pointer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        child: SizedBox.expand(
          child: GameWidget(
            game: game,
          ),
        ),
      ),
    );
  }
}

class BlockBlasterGame extends FlameGame {
  late PlayerShip player;
  late List<Shot> shots;
  late List<Block> blocks;
  int lives = 5;
  bool isGameOver = false;
  double respawnTimer = 0;
  static const double respawnDelay = 2.0;
  
  // Multi-touch rotation tracking
  final Map<int, Offset> touchPoints = {};
  final Map<int, Offset> previousTouchPoints = {};
  double lastRotation = 0;
  bool isTwoFingerMode = false;
  
  // Public touch handlers
  void handleTouchDown(int pointerId, Vector2 localPosition) {
    onTouchDown(pointerId, localPosition);
  }
  
  void handleTouchUpdate(int pointerId, Vector2 localPosition) {
    onTouchUpdate(pointerId, localPosition);
  }
  
  void handleTouchUp(int pointerId) {
    onTouchUp(pointerId);
  }
  
  void handleTouchCancel(int pointerId) {
    onTouchCancel(pointerId);
  }

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
    player.position = Vector2(20, size.y / 2 - PlayerShip.shipHeight / 2);
    add(player);
    
    // Spawn some blocks
    _spawnBlocks();
    
    debugPrint('Player spawned at: ${player.position}');
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
    // Spawn 5 blocks in a row on the right side of the screen
    const blockGap = 10.0;
    const blockSize = 50.0;
    const totalBlockHeight = blockSize * 5 + blockGap * 4;
    final x = size.x - blockSize - 50; // Right side with margin
    final startY = (size.y - totalBlockHeight) / 2;
    
    debugPrint('Spawning blocks: gameSize=${size.x}x${size.y}, totalBlockHeight=$totalBlockHeight, x=$x, startY=$startY');
    
    for (int i = 0; i < 5; i++) {
      final block = Block(
        gameRef: this,
      );
      final yPos = startY + i * (blockSize + blockGap);
      block.position = Vector2(x, yPos);
      debugPrint('Block $i spawned at position: ($x, $yPos)');
      addBlock(block);
      debugPrint('Block $i added to game');
    }
    debugPrint('Total blocks in game: ${blocks.length}');
  }


  
  void onTouchDown(int pointerId, Vector2 localPosition) {
    debugPrint('Touch down: ID=$pointerId, pos=$localPosition');
    touchPoints[pointerId] = localPosition.toOffset();
  }
  
  void onTouchUpdate(int pointerId, Vector2 localPosition) {
    final previousPosition = previousTouchPoints[pointerId];
    touchPoints[pointerId] = localPosition.toOffset();
    debugPrint('Touch update: ID=$pointerId, current=$localPosition, previous=$previousPosition, touchCount=${touchPoints.length}');
    
    // Check if we're transitioning to 2-finger mode
    if (touchPoints.length == 2 && !isTwoFingerMode) {
      isTwoFingerMode = true;
      // Store current positions as previous for next calculation
      for (var entry in touchPoints.entries) {
        previousTouchPoints[entry.key] = entry.value;
      }
      // Don't apply rotation on first frame of 2-finger mode
      final points = touchPoints.values.toList();
      lastRotation = math.atan2(points[1].dy - points[0].dy, points[1].dx - points[0].dx);
      debugPrint('Entering two-finger mode, initialized lastRotation to $lastRotation');
      return;
    }
    
    // Check if we're transitioning from 2-finger mode back to 1 finger
    if (isTwoFingerMode && touchPoints.length == 1) {
      isTwoFingerMode = false;
      previousTouchPoints.clear(); // Reset so we can drag with the remaining finger
      debugPrint('Exiting two-finger mode, back to single touch');
      return;
    }
    
    if (isTwoFingerMode && touchPoints.length == 2) {
      // Multi-touch - check if we should drag or rotate
      final points = touchPoints.values.toList();
      final p1 = points[0];
      final p2 = points[1];
      
      final prevPoints = previousTouchPoints.values.toList();
      
      // Check movement: if both fingers exist in previous and current
      if (prevPoints.length == 2) {
        final prevP1 = prevPoints[0];
        final prevP2 = prevPoints[1];
        
        // Calculate deltas for each finger
        final delta1 = p1 - prevP1;
        final delta2 = p2 - prevP2;
        
        // Calculate average movement
        final avgMovement = ((delta1.dx.abs() + delta1.dy.abs() + delta2.dx.abs() + delta2.dy.abs()) / 4);
        
        // Calculate change in distance between fingers (rotation indicator)
        final prevDist = math.sqrt(math.pow(prevP2.dx - prevP1.dx, 2) + math.pow(prevP2.dy - prevP1.dy, 2));
        final currDist = math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));
        final distChange = (currDist - prevDist).abs();
        
        debugPrint('Two-finger: avgMovement=$avgMovement, distChange=$distChange');
        
        // If movement is larger than distance change, prioritize movement
        if (avgMovement > distChange && avgMovement > 0.25) { // TWO TOUCH DRAG SENSITIVITY
          debugPrint('Two-finger drag - moving ship');
          final avgDelta = Offset((delta1.dx + delta2.dx) / 2, (delta1.dy + delta2.dy) / 2);
          _moveShip(Vector2(avgDelta.dx, avgDelta.dy));
          // Update previous positions for next frame
          for (var entry in touchPoints.entries) {
            previousTouchPoints[entry.key] = entry.value;
          }
          return;
        }
      }
      
      // Not a movement gesture, so calculate rotation
      debugPrint('Two-touch rotation: p1=$p1, p2=$p2');
      
      // Calculate angle between the two touch points
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      
      // Calculate delta from last rotation
      double rotationDelta = angle - lastRotation;
      
      // Normalize rotation delta to [-pi, pi]
      while (rotationDelta > math.pi) rotationDelta -= 2 * math.pi;
      while (rotationDelta < -math.pi) rotationDelta += 2 * math.pi;
      
      debugPrint('Rotation delta: $rotationDelta rad');
      
      // Apply rotation to ship
      player.shipAngle += rotationDelta * 4.0;
      
      lastRotation = angle;
      // Update previous positions for next frame
      for (var entry in touchPoints.entries) {
        previousTouchPoints[entry.key] = entry.value;
      }
    } else if (touchPoints.length == 1) {
      // Single touch - move player
      if (previousPosition != null) {
        final delta = localPosition.toOffset() - previousPosition;
        debugPrint('Single touch delta: $delta');
        _moveShip(Vector2(delta.dx, delta.dy));
      }
      // Store previous position for next single-touch update
      previousTouchPoints[pointerId] = localPosition.toOffset();
    }
  }
  
  void _moveShip(Vector2 delta) {
    final newPosition = player.position + delta;
    
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
  
  void onTouchUp(int pointerId) {
    touchPoints.remove(pointerId);
    previousTouchPoints.remove(pointerId);
    if (touchPoints.isEmpty) {
      lastRotation = 0;
      isTwoFingerMode = false;
    }
  }
  
  void onTouchCancel(int pointerId) {
    touchPoints.remove(pointerId);
    previousTouchPoints.remove(pointerId);
    if (touchPoints.isEmpty) {
      lastRotation = 0;
      isTwoFingerMode = false;
    }
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
  double shipAngle = 0; // Rotation angle in radians

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
    // Spawn from the front of the ship in the direction it's pointing
    final shipCenterX = position.x + shipWidth / 2;
    final shipCenterY = position.y + shipHeight / 2;
    final distance = 80.0; // Distance from center to spawn point
    
    shot.position = Vector2(
      shipCenterX + distance * math.cos(shipAngle),
      shipCenterY + distance * math.sin(shipAngle),
    );
    shot.angle = shipAngle; // Set bullet angle
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
    
    // Save canvas state
    canvas.save();
    
    // Translate to ship center, rotate, then translate back
    canvas.translate(shipWidth / 2, shipHeight / 2);
    canvas.rotate(shipAngle);
    canvas.translate(-shipWidth / 2, -shipHeight / 2);
    
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
    
    // Restore canvas state
    canvas.restore();
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
    // Move shot in the direction of its angle
    position.x += shotSpeed * dt * math.cos(angle);
    position.y += shotSpeed * dt * math.sin(angle);
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
  static const double blockSize = 50; // Smaller blocks
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
