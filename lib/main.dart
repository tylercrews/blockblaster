import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
// import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
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
      appBar: AppBar(
        title: const Text('BlockBlaster'),
        centerTitle: true,
      ),
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
    
    // Create the player ship in the center-bottom of the screen
    player = PlayerShip(
      gameRef: this,
    );
    player.position = Vector2(size.x / 2, size.y - 100);
    add(player);
    
    debugPrint('BlockBlasterGame loaded!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Remove off-screen shots
    shots.removeWhere((shot) {
      if (shot.position.y < 0) {
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
  static const double shipWidth = 60;
  static const double shipHeight = 50;

  PlayerShip({
    required this.gameRef,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(shipWidth, shipHeight);
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
    shot.position = Vector2(position.x, position.y - shipHeight / 2);
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

    // Draw left half of ship
    canvas.drawRect(
      Rect.fromLTWH(
        -shipWidth / 2,
        -shipHeight / 2,
        shipWidth / 2,
        shipHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        -shipWidth / 2,
        -shipHeight / 2,
        shipWidth / 2,
        shipHeight,
      ),
      outlinePaint,
    );

    // Draw right half of ship
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        -shipHeight / 2,
        shipWidth / 2,
        shipHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        -shipHeight / 2,
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move shot upward
    position.y -= shotSpeed * dt;
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
