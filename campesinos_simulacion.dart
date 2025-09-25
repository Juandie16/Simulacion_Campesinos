import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:campesinos_simulacion/mapa.dart';
import 'package:campesinos_simulacion/campesino.dart';

class CampesinosSimulacion extends FlameGame {
  late final CameraComponent cam;
  final world = Mapa();
  late Campesino campesino;

  @override
  FutureOr<void> onLoad() async {
    // Cámara
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.center;
    cam.viewfinder.position = Vector2(250, 170);

    //  Definir waypoints (ajusta las coordenadas a tu mapa)
    final waypoints = [
      Vector2(80, 240), // hogar
      Vector2(165, 240), // camino 
      Vector2(165, 170), // camino
      Vector2(230, 170), // camino
      Vector2(230, 260), // camino
      Vector2(240, 130), // camino
      Vector2(410, 130), // camino
      Vector2(410, 80), // camino
      Vector2(410, 130), // camino
      Vector2(240, 130), // camino
      Vector2(230, 170), // camino
      Vector2(165, 170), // mercado
      Vector2(165, 240), // camino
    ];
      

    

    // Crear campesino en el primer waypoint
    campesino = Campesino(waypoints.first, waypoints);
    world.add(campesino);

    addAll([world, cam]);
    return super.onLoad();
  }
}

