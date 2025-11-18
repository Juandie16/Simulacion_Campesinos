import 'package:flutter/foundation.dart';

/// Estado compartido entre el juego (Flame) y el panel (Flutter).
class GameState extends ChangeNotifier {
  String hora = "06:00";
  String estadoCampesino = "Despertando";
  int papas = 0;
  int yucaKg = 0;
  int zanahoriaKg = 0;
  int lechugaKg = 0;

  /// Horas simuladas acumuladas desde el inicio (entero).
  int horasSimuladasTotales = 0;
  // Acumuladores específicos para producir recursos con distintos umbrales
  double _horasAcumPapas = 0.0;
  double _horasAcumYuca = 0.0;
  double _horasAcumZanahoria = 0.0;
  double _horasAcumLechuga = 0.0;

  void setHora(String nuevaHora) {
    hora = nuevaHora;
    notifyListeners();
  }

  void setEstado(String nuevoEstado) {
    estadoCampesino = nuevoEstado;
    notifyListeners();
  }

  void addPapas(int cantidad) {
    papas += cantidad;
    notifyListeners();
  }

  void addYuca(int kg) {
    yucaKg += kg;
    notifyListeners();
  }

  void addZanahoria(int kg) {
    zanahoriaKg += kg;
    notifyListeners();
  }

  void addLechuga(int kg) {
    lechugaKg += kg;
    notifyListeners();
  }

  Map<String, int> activityDurations = {
  'Plantar': 0,
  'Comprar': 0,
  'Dormir': 8,
  };

/// Actualiza la duración de una actividad (en horas).
void setActivityDuration(String activity, int hours) {
  activityDurations[activity] = hours;
  notifyListeners();
  }

  /// Llamar cuando se acumulen horas simuladas (ej. al pasar de hora).
  void addHorasSimuladas(int horas) {
    // Solo actualizamos el contador global; la producción de recursos
    // se realiza únicamente cuando una entidad (ej. Campesino) reporta
    // horas efectivas de actividad (p. ej. Plantar) mediante
    // `addHorasActividad`.
    horasSimuladasTotales += horas;
    notifyListeners();
  }

  /// Añade horas simuladas efectivas para una actividad concreta.
  /// Actualmente solo la actividad 'Plantar' genera recursos.
  void addHorasActividad(String actividad, double horas) {
    if (actividad != 'Plantar') return;

    _horasAcumPapas += horas;
    _horasAcumYuca += horas;
    _horasAcumZanahoria += horas;
    _horasAcumLechuga += horas;

    // Papas: cada 120 horas -> +1000 papas
    while (_horasAcumPapas >= 120.0) {
      _horasAcumPapas -= 120.0;
      addPapas(1000);
    }

    // Yuca: cada 150 horas -> +1 kg
    while (_horasAcumYuca >= 150.0) {
      _horasAcumYuca -= 150.0;
      addYuca(1);
    }

    // Zanahoria: cada 20 hours -> +1 kg
    while (_horasAcumZanahoria >= 20.0) {
      _horasAcumZanahoria -= 20.0;
      addZanahoria(1);
    }

    // Lechuga: cada 10 hours -> +1 kg
    while (_horasAcumLechuga >= 10.0) {
      _horasAcumLechuga -= 10.0;
      addLechuga(1);
    }

    notifyListeners();
  }
}
