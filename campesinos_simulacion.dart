import 'dart:async';
// Flame components and helpers
import 'package:flame/components.dart';
// Tiled map support
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/game.dart';

// Local modules
import 'mapa.dart';
import 'campesino.dart';
import 'sim_clock.dart';
import 'game_state.dart';

/// Clase principal del juego que combina el `World`/mapa, entidades y reloj.
/// - Carga el `Mapa` (Tiled) y extrae los waypoints definidos en la capa
///   'Waypoints' para crear el `Campesino`.
class CampesinosSimulacion extends FlameGame {
  final GameState gameState;
  final double dayDurationSeconds;
  late Campesino campesino;
  final Mapa world = Mapa();

  CampesinosSimulacion({required this.gameState, this.dayDurationSeconds = 120.0});

  @override
  FutureOr<void> onLoad() async {
    // Añadir el world (que, a su vez, cargará el Tiled map)
    add(world);

    // Esperar a que el mapa esté completamente cargado en el world
    await world.onLoad();

    // Extraer waypoints desde la capa de objetos 'Waypoints'
    final mapa = world.mapa;
    mapa.priority = 0;
    final objectLayer = mapa.tileMap.getLayer<ObjectGroup>('Waypoints');
    final waypoints = <Waypoint>[];
    if (objectLayer != null) {
      for (final obj in objectLayer.objects) {
        if ((obj.name).isEmpty) continue;
        waypoints.add(Waypoint(Vector2(obj.x.toDouble(), obj.y.toDouble()), obj.name));
        // Log para depuración: lista de waypoints leídos
        print('Waypoint: ${obj.name} -> (${obj.x}, ${obj.y})');
      }
    }

    // Crear y agregar el campesino con la lista de waypoints
    campesino = Campesino(waypoints, gameState);
    campesino.priority = 100; // prioridad de render para dibujarlo encima
    world.add(campesino);

    // Agregar reloj que actualiza GameState (hora y producción) al world
    final clock = SimClock(gameState: gameState, dayDurationSeconds: dayDurationSeconds);
    world.add(clock);

    // Cámara: fijada con resolución fija (opcional)
    final cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.center;
    cam.viewfinder.position = Vector2(440 / 2, 360 / 2);
    add(cam);

    return super.onLoad();
  }
}
