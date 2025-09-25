import 'package:campesinos_simulacion/campesinos_simulacion.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  CampesinosSimulacion game = CampesinosSimulacion();
  runApp(GameWidget(game: kDebugMode ? CampesinosSimulacion(): game));
}
