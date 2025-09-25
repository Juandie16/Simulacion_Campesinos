import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Mapa extends World{

  late TiledComponent mapa;


  @override
  FutureOr<void> onLoad() async{

    mapa= await TiledComponent.load("mapa1.tmx", Vector2.all(16));
    add (mapa);
    return super.onLoad();
  }

}