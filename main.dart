// Importaciones de Flutter (widgets y material design)
import 'package:flutter/material.dart';
// Importaciones de Flame (motor de juego)
import 'package:flame/game.dart';
// Módulos locales del juego
import 'campesinos_simulacion.dart';
import 'game_state.dart';
import 'info_panel.dart';

/// Punto de entrada de la aplicación.
/// - Inicializa los bindings de Flutter necesarios para algunos plugins y
///   canales de plataforma.
/// - Crea una instancia compartida de `GameState` que usan tanto el juego
///   (Flame) como el panel Flutter para mantener el estado sincronizado.
/// - Instancia el juego `CampesinosSimulacion` y arranca la aplicación.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Estado compartido entre la vista del juego y la UI Flutter
  final gameState = GameState();

  // Crear la instancia principal del juego. `dayDurationSeconds` indica cuántos
  // segundos reales equivalen a un día simulado (p.ej. 120s -> 24h simuladas).
  final game = CampesinosSimulacion(gameState: gameState, dayDurationSeconds: 120.0);

  // Iniciar la app Flutter pasando la referencia al juego y al estado compartido
  runApp(MyApp(game: game, gameState: gameState));
}

/// Widget raíz de la aplicación. Recibe la instancia del juego (Flame) y el
/// `gameState` compartido y compone la interfaz Flutter alrededor del juego.
class MyApp extends StatelessWidget {
  // The Flame game instance to render inside the UI
  final CampesinosSimulacion game;
  // Shared application state between game and UI
  final GameState gameState;

  const MyApp({required this.game, required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp proporciona el tema y la estructura básica de la app
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.amber),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: Scaffold(
        // Barra superior con el título de la aplicación
        appBar: AppBar(
          title: const Text('Campesinos · Simulación'),
          elevation: 4,
        ),
        // Diseño principal: división horizontal entre la vista del juego y el panel
        body: Row(
          children: [
            // Área del juego (izquierda) — ocupa 3/4 del ancho disponible
            Expanded(
              flex: 3,
              child: GameWidget(game: game),
            ),
            // Panel de información (derecha) — ocupa 1/4 del ancho
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
