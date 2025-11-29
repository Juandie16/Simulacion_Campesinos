import 'package:flutter/foundation.dart';

/// GameState mantiene el estado compartido entre la parte de juego (Flame)
/// y la interfaz Flutter. Es un `ChangeNotifier` para que la UI pueda
/// suscribirse y redibujarse cuando cambien valores clave.
class GameState extends ChangeNotifier {
  // Hora simulada actual en formato HH:MM
  String hora = "06:00";
  // Estado textual del campesino (ej. "Caminando hacia ...")
  String estadoCampesino = "Despertando";
  // Contadores de recursos disponibles en inventario
  int papas = 0;
  int yucaKg = 0;
  int zanahoriaKg = 0;
  int lechugaKg = 0;

  /// Horas simuladas acumuladas desde el inicio (entero).
  // Horas simuladas totales desde el inicio (útil para estadísticas)
  int horasSimuladasTotales = 0;
  // Acumuladores por recurso: almacenan horas efectivas de trabajo que se
  // van sumando y consumen umbrales para producir el recurso correspondiente.
  double _horasAcumPapas = 0.0;
  double _horasAcumYuca = 0.0;
  double _horasAcumZanahoria = 0.0;
  double _horasAcumLechuga = 0.0;

  /// Actualiza la hora simulada y notifica a los listeners para actualizar UI.
  void setHora(String nuevaHora) {
    hora = nuevaHora;
    notifyListeners();
  }

  /// Actualiza una etiqueta de estado para el campesino (texto que se muestra en UI).
  void setEstado(String nuevoEstado) {
    estadoCampesino = nuevoEstado;
    notifyListeners();
  }

  /// Incrementa el contador de papas y notifica a la UI.
  void addPapas(int cantidad) {
    papas += cantidad;
    notifyListeners();
  }

  /// Añade kilos de yuca al inventario.
  void addYuca(int kg) {
    yucaKg += kg;
    notifyListeners();
  }

  /// Añade kilos de zanahoria al inventario.
  void addZanahoria(int kg) {
    zanahoriaKg += kg;
    notifyListeners();
  }

  /// Añade kilos de lechuga al inventario.
  void addLechuga(int kg) {
    lechugaKg += kg;
    notifyListeners();
  }

    // Duraciones (en horas) que el usuario asigna a cada actividad. Estas
    // duraciones influyen en cuánto tiempo el campesino permanecerá en un
    // waypoint marcado como cultivo/mercado/hogar.
    Map<String, int> activityDurations = {
      'Plantar': 0,
      'Comprar': 0,
      'Dormir': 8,
    };

    /// Actualiza la duración para una actividad en horas.
    void setActivityDuration(String activity, int hours) {
      activityDurations[activity] = hours;
      notifyListeners();
    }

  /// Llamar cuando se acumulen horas simuladas (ej. al pasar de hora).
  /// Suma horas simuladas al contador global. NO dispara producción directa
  /// de recursos: la producción solo ocurre por horas de actividad reportadas
  /// (ver `addHorasActividad`). Esto permite distinguir tiempo que pasa en
  /// la simulación del tiempo que efectivamente se dedica a plantar.
  void addHorasSimuladas(int horas) {
    horasSimuladasTotales += horas;
    notifyListeners();
  }

  /// Añade horas simuladas efectivas para una actividad concreta.
  /// Actualmente solo la actividad 'Plantar' genera recursos.
  /// Añade horas efectivas dedicadas a una actividad concreta. Actualmente
  /// solo `Plantar` genera recursos; la función acumula horas por recurso
  /// y consume los umbrales para generar el producto.
  /// - `actividad`: nombre de la actividad (se utiliza 'Plantar')
  /// - `horas`: horas simuladas efectivas (puede ser fraccional)
  void addHorasActividad(String actividad, double horas) {
    if (actividad != 'Plantar') return;

    _horasAcumPapas += horas;
    _horasAcumYuca += horas;
    _horasAcumZanahoria += horas;
    _horasAcumLechuga += horas;

    // Consumir umbrales y producir recursos cuando corresponda
    while (_horasAcumPapas >= 120.0) {
      _horasAcumPapas -= 120.0;
      addPapas(1000);
    }
    while (_horasAcumYuca >= 150.0) {
      _horasAcumYuca -= 150.0;
      addYuca(1);
    }
    while (_horasAcumZanahoria >= 20.0) {
      _horasAcumZanahoria -= 20.0;
      addZanahoria(1);
    }
    while (_horasAcumLechuga >= 10.0) {
      _horasAcumLechuga -= 10.0;
      addLechuga(1);
    }

    notifyListeners();
  }
}
