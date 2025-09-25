import 'package:flame/components.dart';

class SimClock extends TextComponent {
  double elapsed = 0; // tiempo acumulado en segundos
  final double dayDuration = 120; // un día dura 120s (2 minutos)

  SimClock() : super(priority: 10) {
    // Posición del texto en pantalla
    position = Vector2(10, 10);
    text = "Hora: 06:00";
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Acumulamos el tiempo
    elapsed += dt;

    // Si pasa un "día completo", reiniciamos
    if (elapsed > dayDuration) {
      elapsed = 0;
    }

    // Convertir tiempo transcurrido a hora simulada (06:00 → 18:00)
    final startHour = 6; // campesino empieza a las 6 AM
    final totalHours = 12; // simulamos de 6 AM a 6 PM
    final currentHour = startHour + (elapsed / dayDuration * totalHours);

    // Convertimos a formato hh:mm
    int h = currentHour.floor();
    int m = ((currentHour - h) * 60).floor();

    // Ajustamos formato bonito
    final hourStr = h.toString().padLeft(2, '0');
    final minStr = m.toString().padLeft(2, '0');

    text = "Hora: $hourStr:$minStr";
  }
}
