// Low-level drawing and vector utilities
import 'dart:ui';
// Flame components (PositionComponent, Anchor, Vector2, etc.)
import 'package:flame/components.dart';
// Shared game state used to read activity durations and report estado
import 'game_state.dart';

/// Estructura para punto de recorrido con nombre
class Waypoint {
  final Vector2 pos;
  final String name;
  Waypoint(this.pos, this.name);
}

/// Campesino: entidad que recorre una lista de `Waypoint`.
/// Comportamiento:
/// - Se desplaza entre waypoints con una velocidad fija.
/// - Al llegar a waypoints que representan actividades (cultivo/mercado/hogar)
///   inicia un periodo de espera cuya duración se toma desde `GameState`.
/// - Mientras espera puede reportar horas efectivas de actividad a `GameState`
///   (p. ej. para producir recursos cuando esté 'Plantar').
class Campesino extends PositionComponent {
  double speed = 60; // px/s
  final List<Waypoint> waypoints;
  int currentTarget = 0;
  final GameState gameState;
  final double dayDurationSeconds;

  // Estado de espera
  bool isWaiting = false;
  double remainingWaitReal = 0.0; // en segundos reales
  // Actividad actual mientras espera (p. ej. 'Plantar', 'Comprar', 'Dormir')
  String? currentActivity;
  // Indica que el campesino está regresando al hogar y debe
  // seguir la secuencia de waypoints hasta llegar al hogar.
  bool returningHome = false;
  // Dirección del recorrido: +1 avanza hacia adelante en la lista,
  // -1 retrocede por la lista. Esto evita saltos directos del último
  // waypoint al primero y permite hacer el recorrido del camino.
  int direction = 1;

  Campesino(this.waypoints, this.gameState, {this.dayDurationSeconds = 120.0}) {
    if (waypoints.isNotEmpty) {
      position = waypoints.first.pos.clone();
    } else {
      position = Vector2.zero();
    }
    size = Vector2.all(16);
    anchor = Anchor.center;
    priority = 200; // dibujar encima del mapa
    // Inicializar el estado textual según el waypoint en el que se inicia
    _updateEstadoForCurrentWaypoint();
  }

  // Helpers para detectar palabras clave en nombres de waypoints
  bool _nameContainsAny(String name, List<String> keys) {
    return keys.any((k) => name.contains(k));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF0000FF);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (waypoints.isEmpty) return;

    // Obtener hora simulada actual
    final horaActual = gameState.hora.split(':');
    final horaInt = int.tryParse(horaActual[0]) ?? 0;
    // minuto no usado actualmente

    // Si llega la hora de dormir (20:00 o más)
    if (!isWaiting && (horaInt >= 20)) {
      final homeKeywords = ['hogar', 'casa', 'home'];
      final hogarIndex = waypoints.indexWhere((w) => _nameContainsAny(w.name.toLowerCase(), homeKeywords));
      if (hogarIndex != -1 && currentTarget != hogarIndex) {
        // Activar modo "regresando a casa" y ajustar la dirección. Esto
        // hará que el campesino avance paso a paso hacia el waypoint hogar
        // en lugar de saltar directamente.
        _setReturningHome(hogarIndex);
        gameState.setEstado("Regresando al hogar para dormir");
      }
    }

    //  Si está esperando (durmiendo u otra actividad)
    if (isWaiting) {
      // Mientras espera, reportar las horas simuladas efectivas a GameState
      // para que se produzcan recursos solo si la actividad lo requiere.
      // `simulatedHoursDelta` convierte segundos reales `dt` a horas simuladas.
      final simulatedHoursDelta = (dt / dayDurationSeconds) * 24.0;
      if (currentActivity != null) {
        // Reporta solo la actividad actual (ej. 'Plantar')
        gameState.addHorasActividad(currentActivity!, simulatedHoursDelta);
      }

      // Restar tiempo real y comprobar si terminó la espera
      remainingWaitReal -= dt;
      if (remainingWaitReal <= 0) {
        isWaiting = false;
        remainingWaitReal = 0;
        // Limpiar actividad actual al terminar la espera
        currentActivity = null;
        // Actualizar estado textual y comportamiento tras finalizar
        gameState.setEstado("Despertando y preparándose para el trabajo");
        returningHome = false;
        _advanceTarget();
        _updateEstadoForCurrentWaypoint();
      }
      return;
    }

    // Movimiento normal
    final target = waypoints[currentTarget].pos;
    final dir = (target - position);

    // Si está suficientemente cerca del waypoint objetivo, iniciar la lógica
    // de espera/actividad en ese waypoint; en caso contrario continuar moviendo.
    if (dir.length < 2) {
      _startWaitingIfNeededForCurrentWaypoint();
    } else {
      position += dir.normalized() * speed * dt;
      gameState.setEstado("Caminando hacia ${waypoints[currentTarget].name}");
    }
  }

  // Decide si al llegar debe iniciar un periodo de espera (según activityDurations)
  // Decide si al llegar debe iniciar un periodo de espera (según activityDurations)
  // y si esa espera debe reportar actividad (p.ej. Plantar) al GameState.
 void _startWaitingIfNeededForCurrentWaypoint() {
  final name = waypoints[currentTarget].name.toLowerCase();

  String? actividad;
  // Palabras clave más tolerantes para los distintos tipos de waypoint
  final plantKeywords = ['cultiv', 'cultivo', 'cultivos', 'campo', 'parcela', 'siembra', 'siembras'];
  final marketKeywords = ['mercad', 'market', 'plaza'];
  final homeKeywords = ['hogar', 'casa', 'home'];

  // Detectar tipo de waypoint por palabras clave
  if (_nameContainsAny(name, plantKeywords)) {
    actividad = 'Plantar';
  } else if (_nameContainsAny(name, marketKeywords)) {
    actividad = 'Comprar';
  } else if (_nameContainsAny(name, homeKeywords)) {
    actividad = 'Dormir';
  }

  if (actividad != null) {
    final horasSim = gameState.activityDurations[actividad] ?? 0;
    // Si estamos regresando a casa no debemos iniciar actividades intermedias
    // (salvo que el waypoint actual sea el hogar)
    final homeKeywords = ['hogar', 'casa', 'home'];
    final isHome = _nameContainsAny(name, homeKeywords);
    if (returningHome && !isHome) {
      // Avanzar al siguiente paso hacia el hogar; no iniciar actividad.
      _advanceTarget();
      _updateEstadoForCurrentWaypoint();
      return;
    }

    // Si la actividad tiene horas asignadas, iniciar la espera y registrar
    // el tipo de actividad para que el `update` reporte horas efectivas.
    if (horasSim > 0) {
      final secondsPerSimHour = dayDurationSeconds / 24.0;
      remainingWaitReal = horasSim * secondsPerSimHour;
      isWaiting = true;
      currentActivity = actividad; // recordar la actividad que se realiza
      gameState.setEstado("${_actividadLabel(actividad)} ($horasSim h)");
      return;
    }
  }

  _advanceTarget();
  _updateEstadoForCurrentWaypoint();
}
  // Actualiza gameState.estado según el waypoint actual (sin iniciar espera)
  // Actualiza solo la etiqueta `estadoCampesino` en `GameState` según el
  // waypoint actual sin iniciar períodos de espera.
  void _updateEstadoForCurrentWaypoint() {
    final name = waypoints[currentTarget].name.toLowerCase();
    String estado;
    final plantKeywords = ['cultiv', 'cultivo', 'cultivos', 'campo', 'parcela', 'siembra', 'siembras'];
    final marketKeywords = ['mercad', 'market', 'plaza'];
    final homeKeywords = ['hogar', 'casa', 'home'];

    if (_nameContainsAny(name, homeKeywords)) {
      estado = 'En hogar';
    } else if (_nameContainsAny(name, plantKeywords)) {
      estado = 'En cultivo';
    } else if (_nameContainsAny(name, marketKeywords)) {
      estado = 'En mercado';
    } else if (name.contains('corral')) {
      estado = 'En corral';
    } else {
      estado = 'En ${waypoints[currentTarget].name}';
    }
    gameState.setEstado(estado);
  }

  // Traduce la clave de actividad a una etiqueta legible para mostrar en UI.
  String _actividadLabel(String actividadKey) {
    // etiquetas legibles para GameState
    switch (actividadKey) {
      case 'Plantar':
        return 'Plantando';
      case 'Comprar':
        return 'Comprando';
      case 'Dormir':
        return 'Durmiendo';
      default:
        return actividadKey;
    }
  }

  // Avanza el índice `currentTarget` en la dirección indicada.
  // Si llega a un extremo invierte la dirección en lugar de saltar
  // directamente al otro extremo (evita "teletransportes").
  // Avanza el índice `currentTarget` respetando la dirección y evitando
  // "teletransportes": al llegar a un extremo invierte la dirección.
  void _advanceTarget() {
    if (waypoints.isEmpty) return;
    final next = currentTarget + direction;
    if (next < 0) {
      // Estamos antes del inicio: invertir dirección y mover hacia adelante
      direction = 1;
      currentTarget = 1.clamp(0, waypoints.length - 1);
    } else if (next >= waypoints.length) {
      // Llegamos al extremo final: invertir dirección y moverse hacia atrás
      direction = -1;
      currentTarget = (waypoints.length - 2).clamp(0, waypoints.length - 1);
    } else {
      currentTarget = next;
    }
  }

  // Configura el modo "regresando a casa" estableciendo `direction`
  // para avanzar paso a paso hacia `hogarIndex` y moviéndose al primer
  // paso en esa dirección.
  // Prepara al campesino para regresar al hogar avanzando paso a paso hacia
  // `hogarIndex` (no salta directamente).
  void _setReturningHome(int hogarIndex) {
    if (waypoints.isEmpty) return;
    returningHome = true;
    if (hogarIndex == currentTarget) return; // ya estamos en casa
    // Determinar dirección hacia el hogar
    direction = hogarIndex > currentTarget ? 1 : -1;
    // avanzar un paso en esa dirección (no saltar)
    final candidate = currentTarget + direction;
    if (candidate >= 0 && candidate < waypoints.length) {
      currentTarget = candidate;
    }
  }
}
