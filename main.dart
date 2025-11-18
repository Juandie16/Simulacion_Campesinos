import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'campesinos_simulacion.dart';
import 'game_state.dart';
import 'info_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final gameState = GameState();

  final game = CampesinosSimulacion(gameState: gameState, dayDurationSeconds: 120.0);

  runApp(MyApp(game: game, gameState: gameState));
}

class MyApp extends StatelessWidget {
  final CampesinosSimulacion game;
  final GameState gameState;
  const MyApp({required this.game, required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.amber),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Campesinos · Simulación'),
          elevation: 4,
        ),
        body: Row(
          children: [
            // Parte del juego
            Expanded(
              flex: 3,
              child: GameWidget(game: game),
            ),
            // Panel de información
            Expanded(
              flex: 1,
              child: SafeArea(child: InfoPanel(gameState: gameState)),
            ),
          ],
        ),
      ),
    );
  }
}
