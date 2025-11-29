// Widgets de Flutter para la interfaz de usuario
import 'package:flutter/material.dart';
// Modelo de estado compartido del juego
import 'game_state.dart';

class InfoPanel extends StatefulWidget {
  final GameState gameState;
  const InfoPanel({required this.gameState, super.key});

  @override
  State<InfoPanel> createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> {
  // 🔹 Actividades disponibles
  final List<String> activities = ['Plantar', 'Comprar', 'Dormir'];

  // Copia local de las duraciones
  late Map<String, int> durations;

 @override
  void initState() {
    super.initState();
    durations = {
      for (var a in activities) a: widget.gameState.activityDurations[a] ?? 0,
    };
    _normalizeIfNeeded();
    // Suscribirse a cambios en GameState para refrescar hora/estado
    widget.gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted)setState(() {});
  }

  int get totalHours => durations.values.fold(0, (s, v) => s + v);
  int get remainingHours => 24 - totalHours;

  void _normalizeIfNeeded() {
    final sum = totalHours;
    if (sum <= 24) return;
    // Reducir proporcinalmente (simple estrategia)
    final factor = 24 / sum;
    final newDur = <String, int>{};
    var acc = 0;
    for (final a in activities) {
      final v = (durations[a]! * factor).floor();
      newDur[a] = v;
      acc += v;
    }
    // compensar faltante por redondeo
    var need = 24 - acc;
    for (final a in activities) {
      if (need <= 0) break;
      newDur[a] = newDur[a]! + 1;
      need--;
    }
    durations = newDur;
    _applyToGameState();
  }

    void _applyToGameState() {
    // Actualiza GameState con las nuevas duraciones
    for (final a in activities) {
      widget.gameState.setActivityDuration(a, durations[a]!);
    }
  }

    void _resetDurations() {
      setState(() {
        durations = {
          for (var a in activities)
            a: (a == 'Dormir' ? 8 : 0),
        };
        _applyToGameState();
      });
    }

    void _onSliderChanged(String activity, double value) {
    // value es double; lo convertimos a int horas
    final newVal = value.round();
    // Calcular suma de los otros
    final othersSum = totalHours - durations[activity]!;
    // max permitido para este slider
    final maxAllowed = 24 - othersSum;
    final clamped = newVal.clamp(0, maxAllowed);
    setState(() {
      durations[activity] = clamped;
      _applyToGameState();
    });
  }



  @override
  Widget build(BuildContext context) {
    // Colores principales del panel (se usan repetidamente)
    final primary = Colors.teal.shade600;
    final accent = Colors.amber.shade600;

    // El panel principal contiene una zona desplazable con ajustes y
    // controles, y un panel de recursos fijo en la parte inferior.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Encabezado y contenido desplazable (ajustes)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del panel
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.terrain, color: primary, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Campesinos · Simulación',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Caja con hora y estado actuales
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: primary),
                              const SizedBox(width: 8),
                              Text('Hora: ', style: TextStyle(color: Colors.grey[700])),
                              Text(widget.gameState.hora,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                              const Spacer(),
                              Icon(Icons.person, color: primary),
                              const SizedBox(width: 6),
                              Flexible(
                                  child: Text(widget.gameState.estadoCampesino,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text('Ajuste de horas por actividad (máx. 24)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Sliders en tarjetas separadas
                  ...activities.map((act) {
                    final others = totalHours - durations[act]!;
                    final maxForThis = (24 - others);
                    final icon = act == 'Dormir'
                        ? Icons.bedtime
                        : (act == 'Plantar' ? Icons.grass : Icons.shopping_bag);
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [Icon(icon, color: primary), const SizedBox(width: 8), Text(act)]),
                                Text('${durations[act]} h', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: primary,
                                thumbColor: accent,
                                overlayColor: accent.withOpacity(0.2),
                                valueIndicatorColor: primary,
                              ),
                              child: Slider(
                                value: durations[act]!.toDouble(),
                                min: 0,
                                max: maxForThis.toDouble().clamp(1, 24).toDouble(),
                                divisions: maxForThis > 0 ? maxForThis : 1,
                                label: '${durations[act]} h',
                                onChanged: (v) => _onSliderChanged(act, v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Horas asignadas', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$totalHours / 24 h'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _resetDurations,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Restablecer'),
                        style: ElevatedButton.styleFrom(backgroundColor: primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (totalHours / 24.0).clamp(0.0, 1.0),
                      minHeight: 10,
                      color: primary,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Panel de recursos fijo en la parte inferior
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: [
                Chip(
                  avatar: const Icon(Icons.local_pizza, size: 18),
                  label: Text('${widget.gameState.papas} papas'),
                  backgroundColor: Colors.yellow.shade100,
                ),
                Chip(
                  avatar: const Icon(Icons.crop, size: 18),
                  label: Text('${widget.gameState.yucaKg} yuca'),
                  backgroundColor: Colors.orange.shade50,
                ),
                Chip(
                  avatar: const Icon(Icons.emoji_food_beverage, size: 18),
                  label: Text('${widget.gameState.zanahoriaKg} zanah.'),
                  backgroundColor: Colors.deepOrange.shade50,
                ),
                Chip(
                  avatar: const Icon(Icons.grass, size: 18),
                  label: Text('${widget.gameState.lechugaKg} lech.'),
                  backgroundColor: Colors.green.shade50,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
