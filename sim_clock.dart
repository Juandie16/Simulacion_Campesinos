import 'package:flame/components.dart';
import 'game_state.dart';

/// SimClock es un componente que convierte tiempo real (segundos) en hora
/// simulada de 24h y actualiza `GameState.hora` continuamente.
/// - `dayDurationSeconds` controla cuántos segundos reales equivalen a 24h simuladas.
/// - Además detecta saltos de hora entera para notificar progreso de horas simuladas.
class SimClock extends Component {
  final GameState gameState;
  final double dayDurationSeconds; // duración en segundos de un día simulado

  // Tiempo real transcurrido dentro del día simulado
  double elapsed = 0.0;
  // Última hora entera notificada (para detectar cambios de hora)
  int lastWholeSimulatedHour = -1;

  SimClock({required this.gameState, this.dayDurationSeconds = 120.0});

  @override
  void update(double dt) {
    super.update(dt);

    // Sumar tiempo real y ajustar si se supera un día simulado completo
    elapsed += dt;
    if (elapsed >= dayDurationSeconds) {
      elapsed -= dayDurationSeconds;
      lastWholeSimulatedHour = -1; // reinicia conteo horario al empezar día
    }

    // Convertir elapsed -> fracción del día -> hora y minuto simulados
    final fraction = (elapsed / dayDurationSeconds).clamp(0.0, 1.0);
    final simulated24 = fraction * 24.0;
    int hour = simulated24.floor();
    int minute = ((simulated24 - hour) * 60).floor();

    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');

    // Actualiza GameState en cada frame para que la UI muestre la hora
    gameState.setHora('$hourStr:$minStr');

    // Detectar cambios en la hora entera para acumular horas simuladas
    if (hour != lastWholeSimulatedHour) {
      int delta;
      if (lastWholeSimulatedHour >= 0) {
        // cálculo normal dentro del día
        delta = hour - lastWholeSimulatedHour;
        if (delta < 0) delta += 24; // manejar wrap-around
      } else {
        // primer frame del día no suma horas
        delta = 0;
      }
      if (delta > 0) {
        lastWholeSimulatedHour = hour;
        // Añadir horas simuladas al GameState (estadísticas globales)
        gameState.addHorasSimuladas(delta);
      } else {
        lastWholeSimulatedHour = hour;
      }
    }
  }
}
