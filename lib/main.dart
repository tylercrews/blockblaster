import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
// import 'dart:math' as math;

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
      body: GameWidget(game: BlockBlasterGame()),
    );
  }
}

class BlockBlasterGame extends FlameGame {
  late PlayerShip player;
  late List<Shot> shots;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    shots = [];
    
    debugPrint('Game size: ${size.x} x ${size.y}');
    
    // Create the player ship on the left side, vertically centered
    player = PlayerShip(
      gameRef: this,
    );
    player.position = Vector2(10, size.y / 2 - PlayerShip.shipHeight / 2);
    add(player);
    
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
  }

  @override
  Color backgroundColor() {
    return const Color(0xFF1a1a2e);
  }

  void addShot(Shot shot) {
    shots.add(shot);
    add(shot);
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
    shot.position = Vector2(position.x + shipWidth + 10, position.y + shipHeight / 2);
    gameRef.addShot(shot);
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
  static const double shotSpeed = 400; // pixels per second

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
}
