import 'package:flame/components.dart';
import 'game_state.dart';

class SimClock extends Component {
  final GameState gameState;
  final double dayDurationSeconds; // p.ej. 120.0

  double elapsed = 0.0;
  int lastWholeSimulatedHour = -1;

  SimClock({required this.gameState, this.dayDurationSeconds = 120.0});

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;
    if (elapsed >= dayDurationSeconds) {
      elapsed -= dayDurationSeconds;
      lastWholeSimulatedHour = -1; // reinicia conteo horario
    }

    final fraction = (elapsed / dayDurationSeconds).clamp(0.0, 1.0);
    final simulated24 = fraction * 24.0;
    int hour = simulated24.floor();
    int minute = ((simulated24 - hour) * 60).floor();

    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');

    // Actualiza GameState en tiempo real cada frame
    gameState.setHora('$hourStr:$minStr');

    // Detectar saltos de hora entera para acumulación de horas reales
    if (hour != lastWholeSimulatedHour) {
      int delta = hour - (lastWholeSimulatedHour < 0 ? hour : lastWholeSimulatedHour);
      if (lastWholeSimulatedHour >= 0) {
        // caso normal dentro del día
        delta = hour - lastWholeSimulatedHour;
        if (delta < 0) delta += 24;
      } else {
        delta = 0; // primer frame del día no suma
      }
      if (delta > 0) {
        lastWholeSimulatedHour = hour;
        gameState.addHorasSimuladas(delta);
      } else {
        lastWholeSimulatedHour = hour;
      }
    }
  }
}
