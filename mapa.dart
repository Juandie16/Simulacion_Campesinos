import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Mapa extends World{

  late TiledComponent mapa;


  @override
  FutureOr<void> onLoad() async{
    // Vector2.all() indica el tamaño del tile
    mapa= await TiledComponent.load("mapa1.tmx", Vector2.all(16));
    // Añade el mapa a este World para que se renderice.
    add (mapa);
    // Llamamos al onLoad de la clase padre para completar la inicialización.
    return super.onLoad();
  }

}