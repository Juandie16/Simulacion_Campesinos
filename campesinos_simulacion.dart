import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/game.dart';
import 'mapa.dart';
import 'campesino.dart';
import 'sim_clock.dart';
import 'game_state.dart';

class CampesinosSimulacion extends FlameGame {
  final GameState gameState;
  final double dayDurationSeconds;
  late Campesino campesino;
  final Mapa world = Mapa();

  CampesinosSimulacion({required this.gameState, this.dayDurationSeconds = 120.0});

  @override
  FutureOr<void> onLoad() async {
    add(world); // añade el world (que carga el mapa)
    

    // Esperar a que el mapa esté cargado en el World
    await world.onLoad();

    // Extraer waypoints del mapa cargado en el World
    final mapa = world.mapa;
    mapa.priority = 0;
    final objectLayer = mapa.tileMap.getLayer<ObjectGroup>('Waypoints');
    final waypoints = <Waypoint>[];
    if (objectLayer != null) {
      for (final obj in objectLayer.objects) {
        if ((obj.name).isEmpty) continue;
        waypoints.add(Waypoint(Vector2(obj.x.toDouble(), obj.y.toDouble()), obj.name));
        print('Waypoint: ${obj.name} -> (${obj.x}, ${obj.y})');
      }
    }
  // crear campesino con esos waypoints
  campesino = Campesino(waypoints, gameState);
  campesino.priority = 100; // valor alto para dibujarse encima
  world.add(campesino);
  // Agregar reloj que actualiza GameState (hora y producción) al world para sincronizar updates
  final clock = SimClock(gameState: gameState, dayDurationSeconds: dayDurationSeconds);
  
  world.add(clock);

    // Cámara (opcional): fijarla sobre el campesino al inicio
    final cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.center;
    cam.viewfinder.position = Vector2(440 / 2, 360 / 2);
    add(cam);

    return super.onLoad();
  }
}
