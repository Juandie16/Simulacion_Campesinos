import 'dart:ui';
import 'package:flame/components.dart';

class Campesino extends PositionComponent {
  double speed = 60; // píxeles por segundo
  List<Vector2> waypoints; // puntos del recorrido
  int currentTarget = 0;

  Campesino(Vector2 startPosition, this.waypoints) {
    position = startPosition.clone();
    size = Vector2.all(16);
    anchor = Anchor.center;
    priority = 1; // siempre encima del mapa
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF0000FF); // azul
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (waypoints.isEmpty) return;

    // punto objetivo actual
    final target = waypoints[currentTarget];
    final dir = (target - position);

    if (dir.length < 2) {
      // llegó al punto, pasar al siguiente
      currentTarget = (currentTarget + 1) % waypoints.length;
    } else {
      // mover hacia el objetivo
      position += dir.normalized() * speed * dt;
    }
  }
}
