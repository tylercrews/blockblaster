import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

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
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Game initialization code goes here
    debugPrint('BlockBlasterGame loaded!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Game update logic goes here
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF1a1a2e),
    );
  }
}
