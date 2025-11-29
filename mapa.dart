import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

/// `Mapa` es el `World` que carga un Tiled map (`mapa1.tmx`) y lo agrega
/// al árbol de componentes para ser renderizado y colisionado según sea
/// necesario. Mantiene una referencia a `TiledComponent` cargado.
class Mapa extends World {

  // Componente Tiled que representa el mapa cargado
  late TiledComponent mapa;

  @override
  FutureOr<void> onLoad() async {
    // Vector2.all(16) indica el tamaño (px) por tile al cargar el TMX
    mapa = await TiledComponent.load("mapa1.tmx", Vector2.all(16));
    // Añadir el mapa al world para que se renderice y participe en la escena
    add(mapa);
    // Delegar al onLoad del padre para completar la inicialización
    return super.onLoad();
  }

}